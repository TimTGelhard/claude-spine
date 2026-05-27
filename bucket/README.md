# `bucket/` — your personal skill library

**This folder is yours.** The rest of `claude-spine` is read-only (you pull upstream updates and the maintainers ship into `chapters/` and `skills/core/`). The bucket is where *you* extend the spine — personal skills, project conventions, stack-specific recipes that don't belong in the universal core.

## Why a bucket exists

The core spine stays general. It avoids stack opinions (those go in the opinionated global), avoids speculative skills (chapter 13's "don't ship libraries" rule), and avoids your project-specific patterns. But you'll discover patterns over time that are worth saving — and they belong somewhere that survives `git pull` and doesn't pollute upstream.

That's the bucket. It's append-mostly, you own it, no one else writes here.

## What goes here

- **Bucket skills** (`bucket/skills/<name>/SKILL.md`) — narrow `op-*`-style routers for your patterns. Triggers fire only on *your* work, content rarely overlaps with the core. Examples: "deploy this app's infrastructure," "run my favorite codegen pipeline," "review a Rails migration the way I like reviews done."
- **Bucket chapters** (`bucket/chapters/<slug>.md`) — personal atomic chapters for explanations and references you'll re-read. Same atomic-file shape as the core: one concept per file, ≤150 lines. See [chapters/personalization/19e](../chapters/personalization/19e-extending-the-bucket.md) for the skill vs chapter split.
- **`bucket/SUGGESTIONS.md`** — the capture queue. `op-suggest` appends high-signal moments during normal work; `op-curate` reads pending entries and proposes bucket changes. See [19c](../chapters/personalization/19c-suggestion-loop.md).
- **`bucket/CHANGELOG.md`** — append-only audit log of applied changes. See [19d](../chapters/personalization/19d-curation-session.md).

## How Claude finds your bucket

Auto-loading from `~/.claude/skills/` is reserved for the **core** skills. Bucket entries are *routed to* by `op-bucket-router` (a core skill that fires when no core router matched the task). It reads `bucket/INDEX.md` — which has separate **Skills** and **Chapters** tables — picks the matching row, loads only that file. Skills get fired; chapters get pulled in as content. Same routing pattern as the core chapters.

## Adding a skill or chapter

Three ways:

1. **Guided skill add** — say "save this as a bucket skill" / "I want a skill for X." `op-add-skill` walks you through naming, the trigger description, and the body, writes the file, and appends a row to the Skills table.
2. **Via curation** — the suggestion loop (`op-suggest` during work → `/curate` to review). Approved `new-skill` or `new-chapter` suggestions land in the right folder and table with one approval each.
3. **By hand** — drop a `bucket/skills/<name>.md` (or `<name>/SKILL.md`) or a `bucket/chapters/<slug>.md` in directly, then run `/refresh-bucket` to rebuild both INDEX tables.

## What NOT to put here

- Anything that should be universal — that belongs in `chapters/` or `skills/core/` (upstream PR territory, not personal bucket).
- Anything that's actually a project doc (`PROGRESS.md`, `DECISIONS.md`, etc.) — those go in the project's own `docs/`.
- Secrets, API keys, client data. Plain markdown only.
- One-off snippets you'll never reach for again. The bucket is for patterns you'll *route to* repeatedly. If a skill fires twice ever, delete it.

## On sharing (or the lack of one)

There's no plan to host a public catalog of bucket entries, and no Discussions board or examples folder for "share your favorite skill." The bucket is intentionally personal: entries reference your stack, your project paths, sometimes your credential layout. A community marketplace would invite people to collect skills they'll never actually fire — the speculative-library trap ([chapter 13d](../chapters/persistence/13d-skill-anti-patterns.md)) — and dilute the discipline the spine is built on.

Fork the repo and shape your own bucket. If a pattern feels genuinely universal — not "useful for my projects" but "useful for any operator running Claude Code" — open an issue or PR upstream to `chapters/` or `skills/core/` instead. That's the path for universal patterns; the bucket stays yours.

## Upstream + git

The bucket sits inside your spine clone. `git pull` from upstream never touches `bucket/` — the maintainers don't ship into it. Your additions stay. If you want to back up your bucket, fork the repo and push to your own remote — but don't push your bucket back to upstream.
