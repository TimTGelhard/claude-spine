---
description: Explicitly mark the active session done. Walks the verify checklist, rolls up Stop-hook heartbeats, updates section plan + PROGRESS.md, stages doc changes, suggests a commit message. Primary writeback command in the ambient workflow.
---

You are **closing the active build session** explicitly. The Stop hook `spine-writeback.sh` only logs per-turn heartbeats — it does NOT advance the PROGRESS pointer. This command does.

Follow the writeback protocol from `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md` (Step 6).

## What to do

### Step 1 — Walk the verify list

Open `docs/plans/<active-section>.md` and find the active session entry's "Verify" list. Walk it with the user, item by item:

- For each check: confirm it passed, OR ask the user to confirm (for checks Claude can't run, like "tested on iPhone").
- If any check failed or wasn't possible, name which and why. Don't paper over.

If a critical check failed: stop. Don't write `done`. Either fix this session or mark `blocked`.

### Step 2 — Update the section plan

Edit `docs/plans/<active-section>.md`:

1. **Session status** — change from `in-progress` to:
   - `done` — verify list passed.
   - `blocked` — with a one-line reason in the entry.
   - `in-progress` — if pausing mid-work; add a one-line "resume here" note.
2. **Cross-session notes** — anything discovered this session that affects later sessions in this section.
3. **Pending cross-session notes** (auto-captured) — the Stop hook `spine-writeback.sh` appends turn-level cue-phrase matches to a `## Pending cross-session notes` block. If the block exists in this section file:
   - Read each entry to the user verbatim.
   - For each: ask **promote** (move to "Cross-session notes" above, edit if needed), **dismiss** (drop), or **edit-then-promote**. Default to dismiss for noise — the hook biases toward capture.
   - After review, delete the entire `## Pending cross-session notes` block from the section file. Promoted entries now live in "Cross-session notes"; dismissed entries are gone.
   - If the block is empty (header but no entries), just delete the empty block.
4. **Section-level open questions** — any new decision-point that wasn't planned.

### Step 3 — Roll up heartbeats

If the section file has a `## Session log` block populated by the Stop hook, distill the heartbeats into ONE summary line for PROGRESS.md's session log. Don't paste raw heartbeats — collapse to "what shipped, what carried over."

The raw heartbeat block stays in the section file as a trace. You can prune it down to the most recent ~5 entries if it grew long this session.

### Step 4 — Update PROGRESS.md

Edit `docs/PROGRESS.md`:

1. **Active section / active session**:
   - Section has more pending sessions → point at the next session in the same file.
   - Section done → point at section N+1, session 1. If section N+1 has no plan file yet, also (a) note in PROGRESS.md: *"Section N+1 needs `/prep <name>` before next session."* and (b) remember this for Step 9 — you will offer to run `/prep <name>` now rather than letting the next cold-start halt on it.
2. **Last session outcome** — one paragraph. What shipped. What carried over. What's notable.
3. **Blockers** — anything stopping the next session. Empty if none.
4. **Next session reading list** — copy from the next session entry's "Files to read" block.
5. **Session log** — append a one-line entry under today's date: `Session <N.M>: <goal> — <outcome>`.

### Step 5 — Check for plan-level updates

If a major change happened (a new section needed, a section's done-criteria changed, a risk materialized):

1. Propose the change to the user. Don't edit `docs/PROJECT_PLAN.md` silently.
2. If approved, update `PROJECT_PLAN.md` (section status, new section, etc.) and add an entry to its status log.

### Step 6 — DECISIONS.md if applicable

If a non-obvious decision was made this session (architecture choice, tradeoff, why-not-X), add an entry to `docs/DECISIONS.md`. One paragraph per decision.

### Step 7 — Stage changes

1. Run `git status` to show what changed.
2. Run `git diff` to show the actual content.
3. Stage specifically the files you intend to commit. **Never `git add -A` or `git add .`** — pick by name.

### Step 8 — Suggest a commit message

Output a one-line imperative commit message. Format:

```
<verb> <what>: <one-line summary>
```

Example: `add: email + Google login wired with RLS baseline`

Do NOT commit. The user reviews the diff and commits.

### Step 9 — Hand back

Tell the user:

- Session marked `<done|blocked|in-progress>`.
- PROGRESS.md now points at section/session `<N+1.1>` (next session goal).
- N files staged. Suggested commit message above.
- Next: review diff, commit. Reopen Claude in this directory — `op-spine-active` will auto-load the next session.

**If the next section has no plan file yet** (the condition you flagged in Step 4), append one more line:

> Section `<next-section>` has no plan file. Run `/prep <next-section>` now? (Y/n)

- **Y** → hand off to `op-prepare` scoped to that section (`/prep <next-section>`). Don't wait for the user to type — invoke it as the next action. Their commit + reopen still happens after.
- **N or no answer** → leave the PROGRESS.md note in place. The next ambient `op-spine-active` will halt cleanly with the same suggestion. No silent state.

Rationale: a section-boundary `/done` followed by a fresh terminal that halts on "no plan" is the exact cold-start friction this offer prevents. Asking once at writeback time avoids the mid-next-session interruption.

## Hard rules

1. **No closing without writeback.** If the user tries to skip, push back once. If they insist, write a minimal note (mark `in-progress`, resume-here note) — never close with nothing written.
2. **No committing for the user.** Stage only.
3. **No silent plan changes.** If `PROJECT_PLAN.md` needs editing, propose first.
4. **No `git add -A` or `git add .`.** Stage by name only.

## Relation to other commands

- **Ambient cold-start counterpart**: `op-spine-active` skill (auto-loads scope at the start of each conversation).
- **Per-turn writeback**: `spine-writeback.sh` Stop hook (logs heartbeats only — never advances PROGRESS).
- **Pre-`/done` planning**: `/prep <section-name>` plans the next section just-in-time when the current one finishes.
