---
description: Run a bucket curation session — review pending entries in ~/.claude-spine/bucket/SUGGESTIONS.md, propose diffs, apply approved ones to bucket/skills/ or bucket/chapters/. Read-before-write enforced. One change per approval. Pass --review-stale to walk old bucket/INDEX.md entries for prune-or-keep decisions instead.
argument-hint: [--review-stale]
---

Invoke the `op-curate` skill.

Arguments: `$ARGUMENTS`

- If `$ARGUMENTS` contains `--review-stale`, read `~/.claude-spine/skills/core/op-curate/stale-review.md` and follow it. This is the stale-entry review path — prune-or-keep over `bucket/INDEX.md`, not pending-suggestion curation. Do not read SUGGESTIONS.md in this mode.
- Otherwise, read `~/.claude-spine/skills/core/op-curate/SKILL.md` and follow it. Normal mode: walk pending entries in `bucket/SUGGESTIONS.md`, propose diffs, apply on approval.

In either mode, the slash command IS the entry — you're not interrupting a feature build, you're starting a curation session. If the user was mid-task when they ran this, confirm the mode switch before reading anything.

Normal mode begins by reading `~/.claude-spine/bucket/SUGGESTIONS.md` and `~/.claude-spine/bucket/INDEX.md` before proposing anything. If there are zero pending entries, say so and stop. Stale-review mode begins by reading `~/.claude-spine/bucket/INDEX.md` and filtering rows by the `Added` column; if zero candidates older than the cutoff, say so and stop.
