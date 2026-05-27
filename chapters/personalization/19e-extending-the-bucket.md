# 19e — Extending the bucket

The bucket is yours. Phases 6.5 and 8 wire the mechanics; this chapter is the *judgment* layer — when to add what, what shape it should take, when to prune. The bucket has the same anti-patterns as the core spine; this is where they apply to your personal work.

## Bucket structure

```
bucket/
├── INDEX.md          # router map — auto-maintained
├── SUGGESTIONS.md    # capture queue (see 19c)
├── CHANGELOG.md      # audit log of applied changes (see 19d)
├── README.md         # what the bucket is, what NOT to put here
├── skills/           # personal `op-*`-style skill routers
└── chapters/         # personal atomic chapters
```

Two write-targets for actual content: `bucket/skills/` and `bucket/chapters/`. The other files are metadata (INDEX, README) or the loop's plumbing (SUGGESTIONS, CHANGELOG).

## Skill vs chapter — which one?

The most common decision when extending the bucket. The split mirrors core: skills route to content; chapters *are* content.

| Write a **bucket skill** when… | Write a **bucket chapter** when… |
|---|---|
| There's a repeatable procedure you do (3+ times) | There's an explanation / reference you'll re-read |
| You want Claude to *fire* on a trigger | You want Claude to *load and consult* when a topic comes up |
| The pattern is "do these steps in this order" | The pattern is "here's how this works / when to use it" |
| Examples: "deploy this app," "review this kind of migration" | Examples: "how our event ingest pipeline works," "ML model versioning conventions for this lab" |

If a skill ends up >55 lines because it's mostly explanation, the explanation is a chapter and the skill should route to it. Same pattern as `op-onboard` routing to `questions-essential.md`.

If a chapter starts including step-by-step procedures Claude should execute, split — the procedure is a skill, the surrounding explanation is the chapter.

## When to actually create one

Two gates, both required:

1. **The 3+ times rule.** You've reached for the pattern at least three times — copy-pasted the same prompt, given Claude the same explanation, walked through the same procedure. Three times means the pattern earned itself. Two times means *maybe*; one time means *no*. `op-add-skill` enforces this gate explicitly.
2. **The "I always do this here" condition.** Some patterns only fire once but you *know* they're a permanent fixture (a project's deploy command, a team's review style). Naming the durable condition substitutes for the count. Drift here is the trap — "I'm pretty sure I'll do this again" isn't a durable condition.

Both gates exist for the same reason: the speculative-library trap from [13d](../persistence/13d-skill-anti-patterns.md) re-emerges inside the bucket if the gates are skipped. Past these, the addition is justified.

## What absolutely doesn't belong here

- **Project documentation** (`PROGRESS.md`, `DECISIONS.md`, `FEATURES.md`, `ARCHITECTURE.md`). Those live in the project's own `docs/`. The bucket is universal-to-you; project docs are universal-to-one-project.
- **Secrets, API keys, client data, customer names.** Plain markdown, no sensitive data — same rule as everywhere.
- **Universal patterns.** If a pattern would help every Claude Code user, it's a core-spine contribution — open a PR upstream rather than burying it in your bucket. The bucket is for *your* stack, *your* project types, *your* conventions.
- **One-off snippets** you'll never reach for again. If a skill or chapter fires twice ever, delete it — it's pure overhead.
- **Anything that's actually a hook.** Automation-on-event is `~/.claude/settings.json` hook territory, not a skill ([14a](../persistence/14a-settings-cascade.md), [14b](../persistence/14b-hook-recipes.md)).

## Naming and shape

**Skills** follow the core `op-*` naming convention if it makes them feel familiar — `op-deploy-rails`, `op-review-migration`. The prefix isn't required; what matters is sharp triggers and slow-aging content (same rule as core skills).

**Chapters** use whatever atomic-file shape fits — short slug, single concept, ≤150 lines. The numbering convention from core (`NNx-slug.md`) isn't necessary for bucket chapters; a plain `<topic-slug>.md` is fine. Don't try to match the core numbering — the bucket is a flat namespace, not a continuation of the chapter numbering.

The atomic-file cap (~150 lines) applies. If you're writing a 300-line bucket chapter, you're writing two chapters that always get read together — or one that has a real seam.

## The bucket INDEX as the gatekeeper

The bucket only works if `bucket/INDEX.md` is accurate. Two ways the index stays right:

1. **`op-add-skill`** appends a row automatically when you write a new skill via the skill flow.
2. **`/refresh-bucket`** rescans `bucket/skills/` and `bucket/chapters/` and rewrites the index from disk — for cases where you dropped a file in by hand or hand-edited the structure.

`op-bucket-router` *trusts* the INDEX. It does not scan the bucket folder at fire time. If the index is stale, the router won't find your skill, and Claude will silently fall back to "no bucket skill matched." Run `/refresh-bucket` if behavior surprises you.

## Garbage collection

Bucket entries decay when:

- You move stacks (the Rails skills don't fire on a Go project).
- A project type abandons you (the freelance-quote skills don't fire when you're full-time in-house).
- A pattern was wrong about itself (you wrote it after 3 paste-ins but it never fires in practice).

No auto-archival by default. The bucket is yours; the spine doesn't decide when your patterns expire. Two opt-in tools (Phase 8d):

- `/curate --review-stale` — walk through entries that haven't fired in N months, prune-or-keep one at a time.
- Manual delete — find the file, `rm` it, run `/refresh-bucket`.

Project-shift detection (Claude noticing you moved domains) is similarly explicit, not automatic. When your work changes meaningfully, run `/onboard --refresh` and then a stale-review pass.

## How bucket additions interact with `git pull`

The bucket lives inside your spine clone, but maintainers never write to `bucket/`. `git pull` from upstream:

- Updates `chapters/`, `skills/core/`, `templates/`, `global/`, `install.sh`, top-level docs.
- **Never touches** `bucket/skills/`, `bucket/chapters/`, `bucket/INDEX.md`, `bucket/SUGGESTIONS.md`, `bucket/CHANGELOG.md`, `bucket/README.md`.

Your bucket additions are safe. If you want to back up your bucket: fork the repo, push to your own remote, pull from upstream into your fork. Don't push your bucket *back* upstream — bucket sharing is not the spine's model ([19a](19a-overview.md)).

## TL;DR

- Skills are procedures; chapters are explanations. Same split as core.
- Two gates before creating: 3+ paste-ins, or a named durable "I always do this here" condition. Anything past one needs justification.
- Don't put project docs, secrets, universal patterns, one-offs, or hook-shaped automation here.
- `op-add-skill` and `/refresh-bucket` keep `bucket/INDEX.md` accurate. The router trusts the index.
- No auto-GC. Stale review is opt-in via `/curate --review-stale`. Your bucket, your call.
- `git pull` never touches `bucket/`. Upgrades are conflict-free.
