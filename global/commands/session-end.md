---
description: End a build session in a plan-driven project. Updates the section plan and PROGRESS.md, stages changes, suggests a commit message. Follows the writeback protocol from chapter 05j.
---

You are **ending a build session** in a plan-driven project. Follow the writeback protocol from `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md` (Step 6).

## What to do

### Step 1 — Walk the verify list

Open `docs/plans/<active-section>.md` and find the active session entry's "Verify" list.

Walk it with the user, item by item:

- For each check: confirm it passed, OR ask the user to confirm (for checks Claude can't run, like "tested on iPhone").
- If any check failed or wasn't possible, name which and why. Don't paper over.

If a critical check failed: stop. Don't write `done` status. Either fix the issue this session or mark `blocked`.

### Step 2 — Update the section plan

Edit `docs/plans/<active-section>.md`:

1. **Session status**: change from `in-progress` to:
   - `done` — verify list passed.
   - `blocked` — with one-line reason in the entry.
   - `in-progress` — if pausing mid-work; add a one-line "resume here" note.

2. **Cross-session notes**: if anything was discovered this session that affects later sessions in this section, add a one-line entry to the "Cross-session notes" list at the top of the section file.

3. **Section-level open questions**: if a new decision-point emerged that wasn't planned, add to the open questions list.

### Step 3 — Update PROGRESS.md

Edit `docs/PROGRESS.md`:

1. **Active section / active session**:
   - If the section has more pending sessions: point at the next session in the same file.
   - If the section is done: point at section N+1, session 1. If section N+1 has no plan file yet, note: *"Section N+1 needs `/prep <name>` before next session."*

2. **Last session outcome**: one paragraph. What shipped. What carried over. What's notable.

3. **Blockers**: anything stopping the next session. Empty if none.

4. **Next session reading list**: copy from the next session entry's "Files to read" section.

5. **Session log**: append a one-line entry under today's date: `Session <N.M>: <goal> — <outcome>`.

### Step 4 — Check for plan-level updates

If a major change happened (a new section needed, a section's done-criteria changed, a risk materialized):

1. Propose the change to the user. Don't edit `docs/PROJECT_PLAN.md` silently.
2. If approved, update `PROJECT_PLAN.md` (section status, new section, etc.) and add an entry to its status log.

### Step 5 — DECISIONS.md if applicable

If a non-obvious decision was made this session (architecture choice, tradeoff, why-not-X), add an entry to `docs/DECISIONS.md`. One paragraph per decision.

### Step 6 — Stage changes

1. Run `git status` to show what changed.
2. Run `git diff` to show the actual content.
3. Stage specifically the files you intend to commit. **Never `git add -A` or `git add .`** — pick by name. This catches accidentally-staged secrets or large unrelated changes.

### Step 7 — Suggest commit message

Output a one-line imperative commit message that describes what shipped this session. Format:

```
<verb> <what>: <one-line summary>
```

Example: `add: email + Google login wired with RLS baseline`

Do NOT commit. The user reviews the diff and commits.

### Step 8 — Hand back

Tell the user:

- Session marked `<done|blocked|in-progress>`.
- PROGRESS.md updated to point at session `<N.M>` (next session goal).
- N files staged. Suggested commit message above.
- Next: review diff, commit, close terminal. Open a fresh terminal and run `/session-start` for the next session.

## Hard rules

1. **No closing the session without writeback.** If user tries to skip, push back once. If they insist, write a minimal note (session marked `in-progress`, resume-here note) — never close with nothing written.
2. **No committing for the user.** Stage only. User reviews and commits.
3. **No silent plan changes.** If `PROJECT_PLAN.md` needs editing, propose first.
4. **No `git add -A` or `git add .`.** Stage by name only.
