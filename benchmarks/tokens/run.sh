#!/usr/bin/env bash
# Token-efficiency benchmark — spine-on vs spine-off.
#
# For each prompt in eval-set.json, runs `claude -p --output-format json`
# N times in each of two conditions:
#
#   spine-off : ~/.claude/CLAUDE.md is replaced with a one-line stub and
#               all ~/.claude/skills/op-* directories are stashed.
#   spine-on  : the spine is in its installed state.
#
# Captures usage.{input,output,cache_creation_input,cache_read_input}_tokens,
# total_cost_usd, and timing per call. Raw per-call JSON lands in results/raw/
# and a one-line-per-call summary lands in results/results.jsonl. Use
# aggregate.py to produce REPORT.md.
#
# Batching note: spine-off runs first as a batch, then spine-on as a batch.
# Within a batch the prompt cache amortizes the shared prefix; that mirrors
# real steady-state usage. Alternating conditions would cold-cache every call
# and over-report spine cost.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVAL_SET="$SCRIPT_DIR/eval-set.json"
RESULTS_DIR="$SCRIPT_DIR/results"
RAW_DIR="$RESULTS_DIR/raw"
SUMMARY="$RESULTS_DIR/results.jsonl"

# Defaults — override via flags. The L4c spec's $15 cost cap assumes these.
RUNS=3
MODEL="claude-sonnet-4-6"
TIMEOUT=90
DRY_RUN=0
ONLY_PROMPT=""
ONLY_COND=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Runs the token-efficiency benchmark against eval-set.json.

Options:
  --runs N           Runs per prompt per condition (default: $RUNS).
                     Cost scales linearly. The L4c \$15 cap on Sonnet 4.6
                     assumes --runs 3 over 19 prompts (= 114 calls).
  --model NAME       claude --model passthrough (default: $MODEL).
                     'sonnet' / 'opus' / 'haiku' aliases work too.
  --timeout N        Per-call timeout in seconds (default: $TIMEOUT).
  --only-prompt ID   Run just one prompt id from eval-set.json (debugging).
  --only-cond CND    'on' or 'off' — run only one condition.
  --dry-run          Show what would happen; don't call claude.
  -h, --help         This text.

After the run:  python3 aggregate.py
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --runs)         RUNS=$2; shift 2 ;;
    --model)        MODEL=$2; shift 2 ;;
    --timeout)      TIMEOUT=$2; shift 2 ;;
    --only-prompt)  ONLY_PROMPT=$2; shift 2 ;;
    --only-cond)    ONLY_COND=$2; shift 2 ;;
    --dry-run)      DRY_RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              echo "unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

# ---------- preflight ----------

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: 'claude' CLI not found in PATH. Install Claude Code first." >&2
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required to inspect claude -p output." >&2
  exit 1
fi

# `timeout` is GNU coreutils — present on Linux, missing on default macOS.
# Resolve to whichever is available; fall back to no-op if neither exists
# (the caller still sees runaway calls but the harness doesn't crash with
# exit 127 on every call). On macOS: `brew install coreutils` → gtimeout.
TIMEOUT_CMD=""
if command -v timeout >/dev/null 2>&1; then
  TIMEOUT_CMD="timeout"
elif command -v gtimeout >/dev/null 2>&1; then
  TIMEOUT_CMD="gtimeout"
fi
if [[ -z "$TIMEOUT_CMD" ]]; then
  echo "NOTE: 'timeout' / 'gtimeout' not on PATH — running without per-call timeout." >&2
  echo "      brew install coreutils gives you gtimeout if you want this." >&2
fi
if [[ ! -f "$EVAL_SET" ]]; then
  echo "ERROR: eval set not found at $EVAL_SET" >&2
  exit 1
fi
if [[ -n "$ONLY_COND" && "$ONLY_COND" != "on" && "$ONLY_COND" != "off" ]]; then
  echo "ERROR: --only-cond must be 'on' or 'off' (got: $ONLY_COND)" >&2
  exit 1
fi

mkdir -p "$RAW_DIR"

# ---------- stash / restore ----------

STASH_ROOT=""

restore_spine() {
  local sr="${STASH_ROOT:-}"
  [[ -z "$sr" ]] && return 0
  [[ ! -d "$sr" ]] && return 0
  echo
  echo "Restoring spine from $sr"
  if [[ -f "$sr/CLAUDE.md" ]]; then
    rm -f "$HOME/.claude/CLAUDE.md"
    mv "$sr/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  fi
  if [[ -d "$sr/skills" ]]; then
    shopt -s nullglob
    local items=("$sr"/skills/op-*)
    shopt -u nullglob
    for d in "${items[@]}"; do
      mv "$d" "$HOME/.claude/skills/"
    done
    rmdir "$sr/skills" 2>/dev/null || true
  fi
  rmdir "$sr" 2>/dev/null || true
  STASH_ROOT=""
}
trap restore_spine EXIT INT TERM HUP

stash_spine() {
  STASH_ROOT="$(mktemp -d -t claude-spine-bench-XXXXXX)"
  mkdir -p "$STASH_ROOT/skills"
  echo "Stashing spine to $STASH_ROOT"
  if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
    mv "$HOME/.claude/CLAUDE.md" "$STASH_ROOT/CLAUDE.md"
    printf '%s\n' "# (empty for spine-off benchmark)" > "$HOME/.claude/CLAUDE.md"
  fi
  if [[ -d "$HOME/.claude/skills" ]]; then
    shopt -s nullglob
    local skills=("$HOME"/.claude/skills/op-*)
    shopt -u nullglob
    if (( ${#skills[@]} > 0 )); then
      for d in "${skills[@]}"; do
        mv "$d" "$STASH_ROOT/skills/"
      done
      echo "  stashed ${#skills[@]} op-* skill(s)"
    fi
  fi
}

# ---------- per-call ----------

# Appends one JSON object to $SUMMARY. Fields:
#   id, cond, run, model, ok, input_tokens, output_tokens,
#   cache_creation_input_tokens, cache_read_input_tokens,
#   total_cost_usd, ttft_ms, duration_ms, num_turns, is_error, raw_path
run_one() {
  local prompt_id="$1"
  local cond="$2"
  local run_idx="$3"
  local prompt="$4"
  local out_path="$RAW_DIR/${prompt_id}__${cond}__r${run_idx}.json"
  local err_path="$out_path.err"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  DRY  $prompt_id  $cond  run=$run_idx"
    jq -c -n \
      --arg id "$prompt_id" --arg cond "$cond" --argjson run "$run_idx" \
      --arg model "$MODEL" --arg raw "$out_path" \
      '{id:$id, cond:$cond, run:$run, model:$model, ok:false, dry_run:true, raw_path:$raw}' \
      >> "$SUMMARY"
    return 0
  fi

  local rc=0
  if [[ -n "$TIMEOUT_CMD" ]]; then
    "$TIMEOUT_CMD" "$TIMEOUT" claude -p --output-format json --model "$MODEL" "$prompt" \
      > "$out_path" 2>"$err_path" || rc=$?
  else
    claude -p --output-format json --model "$MODEL" "$prompt" \
      > "$out_path" 2>"$err_path" || rc=$?
  fi

  local ok=true
  if [[ $rc -ne 0 ]]; then ok=false; fi

  # Pull fields from the raw JSON. If the call failed and stdout isn't JSON,
  # jq's `// 0` fallback returns 0 — but only when the JSON parses at all.
  # If stdout is empty or non-JSON, jq returns the empty string and the
  # subsequent --argjson rejects it. Sanitize with a default-on-empty here.
  local it ot cc cr cost ttft dur turns is_err
  jget() {
    local v
    v=$(jq -r "$1" "$out_path" 2>/dev/null)
    [[ -z "$v" || "$v" == "null" ]] && echo "${2:-0}" || echo "$v"
  }
  it=$(jget '.usage.input_tokens // 0' 0)
  ot=$(jget '.usage.output_tokens // 0' 0)
  cc=$(jget '.usage.cache_creation_input_tokens // 0' 0)
  cr=$(jget '.usage.cache_read_input_tokens // 0' 0)
  cost=$(jget '.total_cost_usd // 0' 0)
  ttft=$(jget '.ttft_ms // 0' 0)
  dur=$(jget '.duration_ms // 0' 0)
  turns=$(jget '.num_turns // 0' 0)
  is_err=$(jget '.is_error // false' false)

  jq -c -n \
    --arg id "$prompt_id" --arg cond "$cond" --argjson run "$run_idx" \
    --arg model "$MODEL" --argjson ok "$ok" \
    --argjson it "$it" --argjson ot "$ot" \
    --argjson cc "$cc" --argjson cr "$cr" \
    --argjson cost "$cost" --argjson ttft "$ttft" --argjson dur "$dur" \
    --argjson turns "$turns" --argjson ierr "$is_err" \
    --arg raw "$out_path" \
    '{id:$id, cond:$cond, run:$run, model:$model, ok:$ok,
      input_tokens:$it, output_tokens:$ot,
      cache_creation_input_tokens:$cc, cache_read_input_tokens:$cr,
      total_cost_usd:$cost, ttft_ms:$ttft, duration_ms:$dur,
      num_turns:$turns, is_error:$ierr, raw_path:$raw}' \
    >> "$SUMMARY"

  if [[ "$ok" == "true" ]]; then
    printf "  OK    %-26s  %-3s  run=%d  in=%s out=%s cc=%s cr=%s cost=\$%s\n" \
      "$prompt_id" "$cond" "$run_idx" "$it" "$ot" "$cc" "$cr" "$cost"
  else
    echo "  FAIL  $prompt_id  $cond  run=$run_idx  (exit=$rc, see $err_path)"
  fi
}

# ---------- condition runner ----------

run_condition() {
  local cond="$1"
  local label="$2"
  local prompts_jsonl="$3"

  echo
  echo "============================================================"
  echo "  Condition: $label ($cond)"
  echo "============================================================"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local id text
    id=$(jq -r '.id' <<<"$line")
    text=$(jq -r '.prompt' <<<"$line")
    if [[ -n "$ONLY_PROMPT" && "$id" != "$ONLY_PROMPT" ]]; then
      continue
    fi
    for ((r=1; r<=RUNS; r++)); do
      run_one "$id" "$cond" "$r" "$text"
    done
  done <<<"$prompts_jsonl"
}

# ---------- main ----------

prompts_jsonl="$(jq -c '.prompts[]' "$EVAL_SET")"
num_prompts=$(jq '.prompts | length' "$EVAL_SET")

# Surface what the benchmark will actually measure — installed spine, not the repo.
SPINE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
installed_skills=0
repo_skills=0
if [[ -d "$HOME/.claude/skills" ]]; then
  shopt -s nullglob
  installed=("$HOME"/.claude/skills/op-*)
  installed_skills=${#installed[@]}
  shopt -u nullglob
fi
if [[ -d "$SPINE_ROOT/skills/core" ]]; then
  shopt -s nullglob
  on_disk=("$SPINE_ROOT"/skills/core/op-*)
  repo_skills=${#on_disk[@]}
  shopt -u nullglob
fi

echo "Eval-set:  $num_prompts prompts × $RUNS runs × 2 conditions = $((num_prompts * RUNS * 2)) calls"
echo "Model:     $MODEL"
echo "Timeout:   ${TIMEOUT}s"
echo "Spine:     $installed_skills op-* installed at ~/.claude/skills/ (repo has $repo_skills)"
if (( installed_skills != repo_skills )); then
  echo "           ⚠  Installed spine differs from repo. Re-run ./install.sh from"
  echo "              $SPINE_ROOT before the benchmark if you want today's numbers."
fi
[[ "$DRY_RUN" == "1" ]] && echo "Mode:      DRY-RUN (no claude calls)"
echo

# Truncate / start fresh on the summary log.
: > "$SUMMARY"

if [[ -z "$ONLY_COND" || "$ONLY_COND" == "off" ]]; then
  stash_spine
  run_condition "off" "spine OFF" "$prompts_jsonl"
  restore_spine
fi

if [[ -z "$ONLY_COND" || "$ONLY_COND" == "on" ]]; then
  run_condition "on" "spine ON" "$prompts_jsonl"
fi

echo
echo "Done. Summary: $SUMMARY"
echo "       Raw:     $RAW_DIR/"
echo "Next:   python3 $SCRIPT_DIR/aggregate.py"
