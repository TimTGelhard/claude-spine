---
name: op-curate
description: Use to run a curation session — review pending entries in `~/.claude-spine/bucket/SUGGESTIONS.md` and turn approved ones into new or modified files under `bucket/`. Fires on (1) `/curate` slash command (with optional `--review-stale` for stale-entry review instead of pending curation); (2) the user explicitly asks to curate the bucket — "let's curate," "go through pending suggestions," "review what we captured," "process the queue," "let's review stale bucket entries." Reads `~/.claude-spine/bucket/INDEX.md` plus any overlapping bucket files before any proposal — read-before-write is mandatory. Shows a unified diff or full file body before every write — explicit per-change approval, no batch. On apply: writes the bucket file, updates the matching table (Skills or Chapters) in `bucket/INDEX.md`, appends to `bucket/CHANGELOG.md`, moves the entry to the archive section with `Status: applied`. On reject: moves to archive with `Status: rejected`. Hard-refuses to touch `chapters/`, `skills/core/`, the global stub, or the profile — bucket-only.
---

# op-curate — turn pending suggestions into bucket files

One curation pass over `bucket/SUGGESTIONS.md`. Each pending entry exits as `applied` or `rejected`. Full rationale: [`chapters/personalization/19d-curation-session.md`](../../../chapters/personalization/19d-curation-session.md). Expand `~` to `$HOME`; `install.sh` makes `~/.claude-spine` resolve to the spine clone.

## When to fire

- `/curate` → normal mode (this file).
- `/curate --review-stale` → **stop reading here, read `stale-review.md` instead** — the stale-entry prune-or-keep walk over `bucket/INDEX.md`.
- User says "let's curate," "review pending," "go through suggestions" → normal mode.

## When NOT to fire

- Mid-task work — curation is its own session. If `/curate` lands mid-task, confirm the mode switch first.
- No pending entries → tell the user, stop. Don't invent work.
- Anything outside `bucket/` (see hard-refusal table below).

## Read-before-write — hard rule

Before any proposal: (1) `~/.claude-spine/bucket/SUGGESTIONS.md` — pull `Status: pending` only; (2) `~/.claude-spine/bucket/INDEX.md` — both Skills and Chapters tables; (3) any bucket file whose name, type, or trigger keyword overlaps with the current entry's topic. If you're about to propose a write without having opened the bucket INDEX this session, that's the bug. No exceptions.

## Flow — one pending entry at a time

1. Decide: **extend** an existing file, **split** one into two, write **new**, or **reject** as duplicate/noise. (Overlap responses: [19d §Handling overlap](../../../chapters/personalization/19d-curation-session.md).)
2. Show the proposal as a **unified diff** (modify) or a **full file body in a code block** (new). No "approve in principle."
3. Wait for explicit approval, rejection, or edits. One change per cycle.
4. **On approve** — apply the write, then:
   - New skill → append a row above the Skills marker in `bucket/INDEX.md`: `| <trigger> | <path-from-bucket/> | <YYYY-MM-DD> |`.
   - New chapter → append a row above the Chapters marker, same shape: `| <topic> | <path-from-bucket/> | <YYYY-MM-DD> |`. The router discovers chapters via this table.
   - Append one line under today's date in `bucket/CHANGELOG.md` above its marker.
   - In `SUGGESTIONS.md`: remove from Pending; append under "Applied / rejected (archive)" with `Status: applied` + `- **Resolved:** YYYY-MM-DD`.
5. **On reject** — same archive move, `Status: rejected`. Audit-only; never deleted.
6. Move to the next. Close with one line: N applied, N rejected.

## Hard refusal

| Path | Why off-limits |
|---|---|
| `~/.claude-spine/chapters/` | Core spine — upstream PR only. |
| `~/.claude-spine/skills/core/` | Core skill — upstream PR only. |
| `~/.claude/claude-spine-profile.md` | Profile — `op-onboard` / `/onboard` territory. |
| `~/.claude/CLAUDE.md` | Global stub — install-time territory. |

If asked to write outside `bucket/`, decline and name the right path (PR, `/onboard`, re-run install).

## Rules

- One change per approval. No batches.
- SUGGESTIONS.md and CHANGELOG.md are append + status-flip + archive-move only; never delete entries.
- Two pending entries describing the same thing? Surface it when you reach the second; the user decides merge or reject.
- "Stop" / "we're done" halts the session — never auto-process remaining entries.
