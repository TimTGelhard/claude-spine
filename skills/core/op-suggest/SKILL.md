---
name: op-suggest
description: Use to capture a high-signal moment to the user's personal queue at `~/.claude-spine/bucket/SUGGESTIONS.md`. Fires on four narrow conditions only — (1) explicit user signal ("we should add this to the manual," "remember this," "next time we hit this, let's…," "let's not forget this"); (2) repeated friction — Claude was corrected on the same pattern 2+ times in this session; (3) end-of-session reflection ("what did we learn here?," "anything worth capturing?," natural stopping point with a learning frame); (4) the user invokes `/suggest`. Never fires on speculation ("it'd be cool if…"), one-off friction, mid-task ideation, or Claude's own hunches without user reaction. Appends one entry to the queue and gets out of the way — never modifies `chapters/` or `skills/core/`, never edits existing bucket files, never interrupts the task in progress.
---

# op-suggest — capture to the queue

Append one entry to `~/.claude-spine/bucket/SUGGESTIONS.md` and stop. Curation (`/curate`) acts later. Rationale (why the threshold is high, why missed signals are free): [`chapters/personalization/19c-suggestion-loop.md`](../../../chapters/personalization/19c-suggestion-loop.md). Expand `~` to `$HOME` before reading; `install.sh` makes `~/.claude-spine` resolve to the spine clone.

## Bucket-loop gate

Before doing anything else: read `~/.claude/claude-spine-profile.md` `## Spine defaults` → `Bucket loop:`. If `off`:

- Implicit triggers (friction-counter, end-of-session reflection) → silently exit; do not append.
- Explicit triggers (`/suggest` slash command, user said "remember this") → still append. Treat explicit user invocation as overriding the profile setting one-shot; the user knows they're capturing.

Default if the field is absent: `off` (the audit-recommended default after the round-6 flip — a user who never ran `/onboard` shouldn't have the bucket loop firing in the background; the spine + profile still work without it).

## When to fire — exactly four conditions

| Trigger | Confirm before logging |
|---|---|
| Explicit user signal — "we should add this," "remember this," "next time…" | User named it. Log it. |
| Same friction 2+ times this session — same mistake, same direction, same correction | You can quote both corrections. If not, it's not a pattern yet. |
| End-of-session reflection — "what did we learn?," "anything to capture?" | Review the session; propose a small batch; user confirms each. |
| `/suggest` slash command | Ask for the one-line title + type; log it. |

## When NOT to fire — silence is free

- **Speculation** ("it'd be cool if…") — wait until the pattern actually fires.
- **One-off friction** — one correction is a correction; two is a pattern. Don't round up.
- **Mid-task ideation** ("that reminds me…") — note it mentally; let it resurface if it matters.
- **Claude's own hunches** without user reaction — capture requires user confirmation.
- **Already-pending duplicates** — do NOT dedupe at capture time. Let it land; curation merges.

When unsure whether a second correction counts, **prefer silence over capture**. Missed signal is $0; queue noise wrecks curation.

## Entry schema — pinned

Append exactly this shape to `SUGGESTIONS.md`, above the `<!-- op-suggest appends new entries above this comment. -->` marker:

```markdown
## [YYYY-MM-DD] short title

- **Type:** new-skill | new-chapter | profile-update | observation
- **Trigger:** [quote the user, or describe the repeated friction, or name the closing reflection]
- **Proposed change:** [concrete; sketch where it would live in the bucket]
- **Status:** pending
```

- **Types:** `new-skill` / `new-chapter` propose a file under `bucket/`; `profile-update` is logged for awareness only (user runs `/onboard`); `observation` is the catch-all.
- **Trigger** is the audit trail — quote the user or describe the repetition concretely. **Proposed change** must be one concrete line; if you can't write one, the suggestion isn't ready — say so instead of logging.

## Steps

1. Read `~/.claude-spine/bucket/SUGGESTIONS.md` and confirm the append marker is intact.
2. Build the entry with today's absolute date.
3. Append above the marker, one blank line above the new `##` header. If the Pending section body holds only the `_(no pending suggestions yet)_` placeholder, **remove** the placeholder before appending — it exists only so the section renders before any real entries land.

   **If the append marker is missing** (a user hand-edited and removed `<!-- op-suggest appends new entries above this comment. -->` thinking it was cruft): append the new entry at the end of the `## Pending` section instead, then re-insert the marker line immediately after the new entry. Do not fail; do not skip. One line of acknowledgement should also note that the marker was restored, so the user understands what happened.

   **If neither the marker nor a `## Pending` heading exists** (the file was rewritten beyond recognition): emit one warning line — *"spine: `bucket/SUGGESTIONS.md` is missing the `## Pending` section. Recreate it (or run `/refresh-bucket`) and retry."* — and skip the append. Don't crash, don't append to the bottom of a malformed file.
4. Acknowledge in one line — file path + entry title. No discussion, no "also want to…".

## Rules

- **One entry per fire** (end-of-session can produce multiple, each a separate append with user confirmation).
- **Never write outside `bucket/SUGGESTIONS.md`** — not `chapters/`, not `skills/core/`, not existing bucket files.
- **Append-only.** Never delete or edit existing entries.
- **Don't interrupt mid-task.** Append silently and continue; save discussion for end of session.
- **Profile-update entries are logs, not actions.** Never touch `~/.claude/claude-spine-profile.md` — that's `op-onboard`.
