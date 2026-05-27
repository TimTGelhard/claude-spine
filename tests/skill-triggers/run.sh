#!/usr/bin/env bash
# Runs skill-creator's run_eval.py against each op-* skill's eval set.
# Saves per-skill JSON to results/. Use aggregate.py for the summary report.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPINE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
EVAL_SETS_DIR="$SCRIPT_DIR/eval-sets"
RESULTS_DIR="$SCRIPT_DIR/results"
SKILL_CREATOR_DIR="$HOME/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator"

RUNS_PER_QUERY=1
NUM_WORKERS=10
TIMEOUT=30
MODEL=""
FILTER=""
ISOLATE_LEGACY=1
STASH_DIR=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [skill-name]

Runs the skill-trigger benchmark for the given skill, or all 18 if none given.

Options:
  --runs N        Runs per query (default: 1; 3 gives stable stats at 3x cost)
  --workers N     Parallel workers (default: 10)
  --timeout N     Per-query timeout in seconds (default: 30)
  --model NAME    Model id for claude -p (default: user's configured default)
  --keep-legacy   Don't stash legacy ~/.claude/skills/op-manual-* during the run
                  (default: stash so the temp eval command doesn't compete)
  -h, --help      Show this help

Examples:
  ./run.sh                         # run all 18 skills, single run per query
  ./run.sh op-anti-patterns        # run just one
  ./run.sh --runs 3 op-recovery    # rerun with 3-of-3 for stability
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --runs)     RUNS_PER_QUERY=$2; shift 2;;
    --workers)  NUM_WORKERS=$2;    shift 2;;
    --timeout)  TIMEOUT=$2;        shift 2;;
    --model)    MODEL=$2;          shift 2;;
    --keep-legacy) ISOLATE_LEGACY=0; shift;;
    -h|--help)  usage; exit 0;;
    op-*)       FILTER=$1;         shift;;
    *)          echo "unknown option: $1"; usage; exit 1;;
  esac
done

if [[ ! -d "$SKILL_CREATOR_DIR" ]]; then
  echo "ERROR: skill-creator plugin not found at $SKILL_CREATOR_DIR" >&2
  echo "Install it via the Claude Code plugin marketplace first." >&2
  exit 1
fi

PYTHON_CMD=""
for candidate in python3.13 python3.12 python3.11 python3.10 python3 python; do
  if command -v "$candidate" >/dev/null 2>&1; then
    if "$candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>/dev/null; then
      PYTHON_CMD="$candidate"
      break
    fi
  fi
done
if [[ -z "$PYTHON_CMD" ]] && command -v uv >/dev/null 2>&1; then
  echo "System python < 3.10 — using uv-managed Python 3.12"
  PYTHON_CMD="uv run --python 3.12 --no-project python"
fi
if [[ -z "$PYTHON_CMD" ]]; then
  echo "ERROR: need Python 3.10+ for the skill-creator scripts." >&2
  echo "Install one of: brew install python@3.12  |  brew install uv" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"

restore_legacy() {
  local sd="${STASH_DIR:-}"
  if [[ -n "$sd" && -d "$sd" ]]; then
    echo
    echo "Restoring stashed legacy skills from $sd"
    shopt -s nullglob
    local items=("$sd"/op-manual-*)
    shopt -u nullglob
    for d in "${items[@]}"; do
      mv "$d" "$HOME/.claude/skills/"
    done
    rmdir "$sd" 2>/dev/null || true
    STASH_DIR=""
  fi
}
trap restore_legacy EXIT INT TERM

if [[ "$ISOLATE_LEGACY" == "1" && -d "$HOME/.claude/skills" ]]; then
  shopt -s nullglob
  legacy=("$HOME"/.claude/skills/op-manual-*)
  shopt -u nullglob
  if (( ${#legacy[@]} > 0 )); then
    STASH_DIR="$HOME/.claude/skills/.eval-stash-$$"
    mkdir -p "$STASH_DIR"
    echo "Stashing ${#legacy[@]} legacy op-manual-* skills to $STASH_DIR for the run"
    for d in "${legacy[@]}"; do mv "$d" "$STASH_DIR/"; done
  fi
fi

if [[ -n "$FILTER" ]]; then
  files=("$EVAL_SETS_DIR/$FILTER.json")
  if [[ ! -f "${files[0]}" ]]; then
    echo "ERROR: no eval set at ${files[0]}" >&2; exit 1
  fi
else
  shopt -s nullglob
  files=("$EVAL_SETS_DIR"/op-*.json)
  shopt -u nullglob
fi

EXTRA_MODEL_ARGS=""
[[ -n "$MODEL" ]] && EXTRA_MODEL_ARGS="--model $MODEL"

echo "Running skill-trigger benchmark"
echo "  runs/query=$RUNS_PER_QUERY  workers=$NUM_WORKERS  timeout=${TIMEOUT}s"
echo

cd "$SKILL_CREATOR_DIR"

for f in "${files[@]}"; do
  skill_name="$(basename "${f%.json}")"
  skill_path="$SPINE_DIR/skills/core/$skill_name"
  out="$RESULTS_DIR/$skill_name.json"
  log="$RESULTS_DIR/$skill_name.log"

  if [[ ! -d "$skill_path" ]]; then
    echo "WARN: no skill at $skill_path — skipping $skill_name"
    continue
  fi

  echo "=== $skill_name ==="
  # shellcheck disable=SC2086  # word-splitting on PYTHON_CMD/EXTRA_MODEL_ARGS is intentional
  if $PYTHON_CMD -m scripts.run_eval \
       --eval-set "$f" \
       --skill-path "$skill_path" \
       --num-workers "$NUM_WORKERS" \
       --timeout "$TIMEOUT" \
       --runs-per-query "$RUNS_PER_QUERY" \
       --verbose \
       $EXTRA_MODEL_ARGS \
       > "$out" 2> "$log"; then
    passed=$(jq -r '.summary.passed' "$out" 2>/dev/null || echo "?")
    total=$(jq -r '.summary.total' "$out" 2>/dev/null || echo "?")
    echo "  $skill_name: $passed/$total"
  else
    echo "  $skill_name: FAILED (see $log)"
  fi
  echo
done

echo "Done. Per-skill results in $RESULTS_DIR/."
echo "Next: $SCRIPT_DIR/aggregate.py"
