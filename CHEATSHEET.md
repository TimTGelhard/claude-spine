# Cheatsheet

One page. Bookmark it.

The spine has 22 skills, 9 slash commands, ~80 chapters. Most of the time you don't need to know any of them by name — the right one loads on demand. Use this when you *do* want to reach for something explicitly.

## Five things to know

1. `/onboard` calibrates the spine to you. Run it first; re-run when something about you shifts.
2. `/prep` plans a new project or section. Files only — no code that session.
3. `/done` closes the active build session: verify, roll up heartbeats, stage, suggest commit message.
4. Skills auto-load. You don't pick them — Claude does, based on what you ask.
5. The personal **bucket** (capture/curate loop) is opt-in. Set `Bucket loop: off` in `~/.claude/claude-spine-profile.md` to disable.

## When to reach for what

| Situation | What to do |
|---|---|
| Stuck / things went wrong / lost context | Say "we're stuck — let's recover" → `op-recovery` |
| Prompts not landing how you wanted | Say "rewrite this prompt" → `op-prompting` or `/refine` |
| Don't know which file a behavior lives in | `op-persistence` answers it |
| Big new project | `cd` into a fresh repo, run `/prep` |
| Mid-project, starting a new section | `/prep <section-name>` |
| Wrapping up a build session | `/done` |
| Saw a pattern Claude should remember | `/suggest` |
| Curation queue ≥5 entries | `/curate` |
| Need a personal skill | `/add-skill` |
| Hand-dropped a bucket file | `/refresh-bucket` |
| Want to see what's loaded | `/spine` |
| Want to see configured hooks | `/hooks` |

## Slash commands at a glance

```
/onboard         /spine           /prep         /suggest
/onboard --deep  /hooks           /done         /curate
                                                /curate --review-stale
                                                /add-skill
                                                /refresh-bucket
```

## Files you'll touch

```
~/.claude/CLAUDE.md                  # global stub — points at the spine
~/.claude/claude-spine-profile.md    # your profile (op-onboard writes this)
~/.claude/settings.json              # permissions, hooks, plugins
~/.claude-spine/                     # the spine repo (this clone, symlinked)
~/.claude-spine/bucket/              # your personal skill + chapter library
```

## When you want to read instead of run

- New here? Open [`README.md`](README.md) and skim. Then [`EXPLAINER.md`](EXPLAINER.md) for the plain-English version.
- Want the architecture? [`chapters/foundations/01a-llm-loop.md`](chapters/foundations/01a-llm-loop.md) → `01b-three-levers.md` → `01c-failure-modes.md`.
- Want the workflow discipline? [`chapters/workflow/05-overview.md`](chapters/workflow/05-overview.md) → `06-feature-sizing.md`.
- Want the chapter map? [`INDEX.md`](INDEX.md).

## When in doubt

Just ask. Plain language. The right skill loads.
