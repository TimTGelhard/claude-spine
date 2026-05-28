---
name: op-curate-nudge
description: Auto-fires once at the start of any conversation when the user's bucket has 5+ pending suggestions AND it's been >30 days since the last `/curate` run (or no `/curate` has ever run). Emits one quiet line at the top of the first turn suggesting `/curate`, then continues with the user's request. Silent otherwise — do not load the body when the conditions don't match.
---

# op-curate-nudge — close the capture/curate loop

The capture/curate flywheel ([19c](../../../chapters/personalization/19c-suggestion-loop.md), [19d](../../../chapters/personalization/19d-curation-session.md)) only works if curation actually happens. `op-suggest` quietly appends entries to `bucket/SUGGESTIONS.md` during normal work; without a periodic nudge, the queue grows unread and becomes a graveyard. This skill is the single nudge that prevents that — one line at conversation start when the queue is meaningfully behind.

## When this fires

ALL four conditions must be true:

0. **Bucket loop is on.** Read `~/.claude/claude-spine-profile.md` `## Spine defaults` → `Bucket loop:`. If the value is `off`, silently exit. Default if the field is absent: `on`.
1. `~/.claude-spine/bucket/SUGGESTIONS.md` exists.
2. The file has **N+ pending entries**, where **N = `Curate nudge pending threshold`** in `~/.claude/claude-spine-profile.md`'s `## Spine defaults` section, or **5** if the profile doesn't set it. Count lines that match `- **Status:** pending` (case-insensitive). The `Status:` field is mandatory in every entry — `op-suggest` writes it on every append. If a file has `## ` entries under the **Pending** section but zero `Status:` lines, the file shape is unrecognized: emit one warning line at conversation start and skip the nudge:

   > spine: `bucket/SUGGESTIONS.md` exists but no entries carry `Status:` markers. Run `/curate` once to migrate to the current schema, then re-runs of `op-curate-nudge` will see the queue.

   One warning per conversation maximum, same as the nudge itself.
3. The last `/curate` run was **>D days ago**, OR no `/curate` has ever run, where **D = `Curate nudge cooldown days`** in the profile's `## Spine defaults`, or **30** if unset. Read `~/.claude-spine/bucket/CHANGELOG.md` and take the most recent `## YYYY-MM-DD` heading as the last-curate date. If no dated headings exist, treat as never-curated → threshold met.

If any condition fails: skip the body silently. No emission. No follow-up.

## What to emit

One line at the very top of your first turn, before answering whatever the user asked. Pick the right phrasing:

**If a previous `/curate` date exists:**

> Your suggestion queue has **N** pending entries; last `/curate` was on **YYYY-MM-DD** (X days ago). Consider running `/curate` when you have ~10 minutes.

**If no `/curate` has ever run:**

> Your suggestion queue has **N** pending entries and no `/curate` has been run yet. Consider running `/curate` when you have ~10 minutes.

That is the whole emission. No follow-up question, no "run it now?" gate, no preview of what's pending. The user reads `bucket/SUGGESTIONS.md` themselves and runs `/curate` when ready.

## Hard rules

1. **Once per conversation.** Once emitted, never re-emit in the same conversation — even on later turns, even if the user adds more captures.
2. **Silent below threshold.** Fewer than 5 pending, or last `/curate` within 30 days → no emission, no acknowledgement, nothing.
3. **No prompting.** The line is informational. Do not ask "want to do that now?" — the user decides.
4. **No expansion.** Do not list pending entries, sample titles, or estimate review time. The brevity is the point.
5. **Co-firing.** If `op-welcome` and/or `op-spine-active` also fire this conversation, emit in this order: welcome → spine-active scope → curate-nudge. Each is one block; do not merge them.
6. **No write to disk.** This skill reads only — `SUGGESTIONS.md` and `CHANGELOG.md`. Stamping `Last fired` or modifying the queue is out of scope.

## Sibling skills

- `op-suggest` — the capture half (writes to `SUGGESTIONS.md`).
- `op-curate` — the curation half (fires on `/curate`).
- `op-welcome` — first-run greeting (orthogonal trigger: profile file missing).
- `op-spine-active` — plan-driven cold-start (orthogonal trigger: `docs/plans/` + `docs/PROGRESS.md` present).

## Why this threshold

5 pending and 30 days mirrors the implicit guidance in [19c](../../../chapters/personalization/19c-suggestion-loop.md): past ~5 pending the user should schedule a curation session; past ~10 it should be the current session. The 30-day cooldown is what keeps the nudge from being a per-capture nag — if the user curated last week and dropped a few entries in since, no reminder fires. The point is to prevent the graveyard outcome, not to remind the user about something they're already on top of.
