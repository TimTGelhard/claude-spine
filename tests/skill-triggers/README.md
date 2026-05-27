# Skill-trigger benchmarks

Measures whether each `op-*` skill's frontmatter description causes Claude to consult the skill for queries it should match — and to *not* consult it for queries it shouldn't.

## Layout

```
tests/skill-triggers/
├── eval-sets/        one JSON per skill, ~10 queries (5 should-fire, 5 should-not)
├── results/          per-skill <name>.json + <name>.log + REPORT.md + needs-tightening.md
├── run.sh            runs the benchmark
└── aggregate.py      turns results/ into REPORT.md + needs-tightening.md
```

## Prerequisites

- The `skill-creator` plugin installed via Claude Code's plugin marketplace. Its `scripts/run_eval.py` is what we drive — we wrap it. Path expected: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/`.
- Python 3.10+ (PEP 604 union syntax is used by skill-creator). If only system Python is available and < 3.10, `run.sh` falls back to `uv run --python 3.12` automatically. Install `uv` with `brew install uv`.
- `jq` for the pass/total summary print at the end of each skill run.

## Run it

```bash
# All 18 skills, 1 run per query, default model (your CLI config)
./run.sh

# One skill, 3 runs per query for stable stats
./run.sh --runs 3 op-recovery

# Force a specific model (recommended: pin to the model your interactive sessions use)
./run.sh --model sonnet
./run.sh --model opus
./run.sh --model claude-sonnet-4-6

# After: aggregate
python3 aggregate.py
```

`run.sh` stashes any installed `~/.claude/skills/op-manual-*` directories to `~/.claude/skills/.eval-stash-$$` for the duration of the run, then restores on exit (including on Ctrl-C). This isolates the new `op-*` set from the legacy set so the temp eval command is the only matching skill in Claude's `available_skills` list. Pass `--keep-legacy` to opt out.

## What "passing" means

`run_eval.py` writes a unique command file to `.claude/commands/<skill>-skill-<uuid>.md` with the skill's frontmatter description, runs `claude -p <query>`, and counts a trigger only if the first tool call is `Skill` or `Read` referencing that exact unique name. Anything else — a text-only reply, a different tool, no tool call within timeout — counts as "not triggered."

Per-query result:
- `should_trigger=true`, fired ≥ trigger threshold → PASS
- `should_trigger=false`, fired < threshold → PASS
- anything else → FAIL

Default threshold is 0.5. With `--runs 1` (our default), that means a single trigger flips the bit. With `--runs 3`, ≥ 2 of 3.

## The "needs tightening" bar

`aggregate.py` flags a skill if **TP rate < 80%** or **FP rate > 20%**. The threshold comes from the launch plan (`launch.md` L4a). Tightening descriptions is **out of scope** for L4a — the L4a deliverable is the harness + a logged list. Acting on the list is its own session.

## Caveats and known biases

The 2026-05-27 baseline run (Opus 4.7 and Sonnet 4.6, `--runs 1`) showed TP rates of **0–20%** across all 18 skills with FP rates near 0%. That pattern is more about how `claude -p` consults skills than about the descriptions themselves:

- **Routing skills don't fire eagerly in one-shot mode.** Our `op-*` skills are pure routers — they point at chapter content. For task-doing skills (extract tables from PDFs, build a dashboard), Claude consults the skill to learn *how*. For routing skills, Claude often answers conversationally or just acts, skipping the skill entirely. The skill-creator docs warn about this: "simple, one-step queries may not trigger a skill even if the description matches perfectly."
- **Slash-command queries (`/onboard`, `/curate`) are not testing description quality.** They test command resolution, which the eval doesn't simulate — the temp command is named `op-onboard-skill-<uuid>`, not `/onboard`. Treat those rows as no-ops.
- **First-tool-call gating** undercounts borderline cases. If Claude replies with text first ("Good catch — adding Redis here is speculative, here's why…") and *then* reads the skill, the eval has already exited.

So: TP rates from this harness are a lower bound on real-world triggering. Interactive Claude Code sessions (with system prompt, multi-turn context, and the user's installed setup) trigger skills more eagerly than `claude -p` does.

What the benchmark *does* reliably measure: **false-positive rate**. The 0% FP across all 18 skills means descriptions don't pull Claude in on unrelated work — useful baseline to defend in subsequent description edits.

## When to re-run

- Before editing any `op-*` skill's frontmatter description.
- After major model upgrades (Sonnet/Opus version bumps).
- Before a public release tag.

Save the previous `results/` somewhere before re-running if you want a diff.

## Cost

Rough numbers for a full 18-skill sweep with `--runs 1` (≈180 `claude -p` calls):

- **Sonnet 4.6:** ~$5–10
- **Opus 4.7:** ~$20–40
- **Haiku 4.5:** ~$2–3 (untested for this purpose; may under-trigger)

Use `--workers 8` (default 10) and `--timeout 45` for stable runs. Lower workers if you see rate-limit errors.
