# Token-efficiency benchmark — spine-on vs spine-off

Measures whether the spine actually saves tokens by loading chapters on-demand
versus a hypothetical "stuff everything into the prompt" alternative.

The skill-trigger benchmark in [`tests/skill-triggers/`](../../tests/skill-triggers/)
measures *whether* skills fire on the right queries. This benchmark measures
*what they cost per call.*

## Layout

```
benchmarks/tokens/
├── eval-set.json       19 prompts (15 spine-relevant + 4 negative controls)
├── run.sh              stash + restore harness; runs claude -p in both conditions
├── aggregate.py        results/results.jsonl → REPORT.md
├── results/
│   ├── results.jsonl   one line per call (rolling log, written by run.sh)
│   └── raw/            per-call <id>__<cond>__r<run>.json (full claude -p output)
├── REPORT.md           generated comparison report
└── README.md           this file
```

## Prerequisites

- `claude` CLI installed and authenticated (`claude --version`).
- `jq` for parsing the JSON output (`brew install jq`).
- Python 3.10+ for `aggregate.py`.

## Run it

```bash
# Default: 19 prompts × 3 runs × 2 conditions = 114 calls on Sonnet 4.6.
./run.sh

# Then:
python3 aggregate.py
```

`run.sh`:

1. Stashes `~/.claude/CLAUDE.md` to a `mktemp -d` dir and replaces it with a
   one-line stub.
2. Stashes every `~/.claude/skills/op-*` directory to the same stash root.
3. Runs each prompt N times against `claude -p --output-format json`,
   capturing `usage.{input,output,cache_creation_input,cache_read_input}_tokens`
   and `total_cost_usd` per call. This is the **spine-off** batch.
4. Restores the spine.
5. Runs every prompt N times again — the **spine-on** batch.

The trap restores the spine on `EXIT` / `INT` / `TERM` / `HUP`, so Ctrl-C in
the middle of a run still leaves your `~/.claude/` in a consistent state.

### Options

```
--runs N           Runs per prompt per condition (default: 3).
--model NAME       claude --model passthrough (default: claude-sonnet-4-6).
--timeout N        Per-call timeout in seconds (default: 90).
--only-prompt ID   Run just one prompt id from eval-set.json (debugging).
--only-cond CND    'on' or 'off' — run only one condition.
--dry-run          Print intent; don't call claude.
```

## Cost

Single full pass on Sonnet 4.6 (`--runs 3`):

- 19 prompts × 3 runs × 2 conditions ≈ **114 calls.**
- ≈ $0.08–$0.13 per call (varies with spine-on context cost).
- **Total ≈ $9–$15.** Within the L4c spec's $15 cap.

Opus 4.7 is roughly 10× more expensive — full sweep ≈ $90–$150. Use only when
the per-prompt nuance matters more than budget. Haiku 4.5 is cheaper but may
under-respond on the spine-on context volume; it's not the reference target.

`--only-prompt <id>` or `--runs 1` are the right way to spot-check changes
between full runs.

## What "passing" means

There's no pass/fail here — it's a measurement, not a regression check. The
report surfaces three things:

1. **Δ tokens per prompt** — how much extra input the spine carries on each
   prompt. The control rows (`ctrl-*`) should show **near-zero** Δ; if they
   don't, the spine is loading more than necessary on prompts it can't help.
2. **Cache creation vs read** — the first spine-on call in each batch pays
   `cache_creation_input_tokens`; subsequent ones pay `cache_read_input_tokens`
   (~10% of fresh-input price). The realistic steady-state per-call cost is
   the cache-read row.
3. **Per-condition variance** — high σ on the spine-on column means cache
   timing is dominating the measurement; rerun with `--runs 5+` if the noise
   is hiding the signal.

## When to re-run

- Before a public release tag.
- When a meaningful chunk of context is added or removed (new chapters, skill
  count change, CLAUDE.md rewrite).
- After major model upgrades (Sonnet 4.6 → 5, Opus 4.7 → 5, etc).
- Before claiming a token number on the landing page or demo.

Move the previous `results/results.jsonl` and `REPORT.md` aside if you want a
diff between baselines.

## Why this isn't in CI

Same reason as the skill-trigger benchmark: it costs real API spend, requires
an authenticated `claude` CLI, and the runtime is minutes not seconds. Run it
manually before releases. See [`tests/run.sh`](../../tests/run.sh) for the
deterministic suite that *does* run in CI.

## Caveats

See the **What this doesn't measure** section at the bottom of [`REPORT.md`](REPORT.md).
Key points:

- Single-shot `claude -p` measures per-call input cost; it doesn't capture
  per-turn cost in long interactive sessions, where the spine's overhead
  amortizes.
- Spine-on calls share a long prefix and hit the prompt cache after the first
  call in each batch — that's the realistic steady-state.
- For skill *triggering* accuracy, see [`tests/skill-triggers/README.md`](../../tests/skill-triggers/README.md).
