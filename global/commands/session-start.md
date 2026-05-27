---
description: Start a fresh build session in a plan-driven project. Loads the active session entry, confirms scope with the user, refuses to start coding until scope is confirmed. Follows the cold-start protocol from chapter 05j.
---

You are starting a **fresh build session** in a plan-driven project. Follow the cold-start protocol from `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md`.

## What to do

### Step 1 — Verify plan exists

Check that `docs/plans/` exists and `docs/PROGRESS.md` exists and points at a session.

- If `docs/PROGRESS.md` is missing or its active-section field is empty: **STOP**. Output: *"No project plan found. Run `/prep` first to plan the project."* Do not proceed.
- If `docs/plans/<active-section>.md` is missing: **STOP**. Output: *"Section `<name>` has no plan yet. Run `/prep <name>` to plan it before starting."* Do not proceed.

### Step 2 — Load orientation

Read these files in order:

1. `docs/PROGRESS.md` — to find active section + active session.
2. `docs/plans/<active-section>.md` — locate the active session entry.
3. Every file listed in the session entry's "Files to read" section.

Do NOT load any other project files. The session entry defines exactly what's needed.

### Step 3 — Confirm scope (mandatory)

Output a 4-line scope summary:

```
Active section: <section name>
Active session:  <session number — session goal>
In scope:        <files-to-write list>
Out of scope:    <relevant exclusions, derived from section done-criteria>
```

Then ask: **"Confirm scope before I start?"**

### Step 4 — Wait for explicit confirmation

**Do NOT call `Edit`, `Write`, or any state-mutating `Bash` command until the user says "yes / go / confirmed".**

Implicit signals (silence, follow-up questions, "OK", "sure") are NOT confirmation. Wait for explicit.

If the user says "just start" without confirming scope:

- Push back once: *"The cold-start protocol requires explicit scope confirmation. Want me to proceed without it? I'll log that the confirmation was skipped."*
- If they insist, proceed but add a one-line note to `docs/PROGRESS.md`: `scope confirmation skipped on YYYY-MM-DD`.

### Step 5 — Plan-if-needed

If the session entry's build steps are vague (e.g., "implement X"), draft a 3-5 step breakdown and confirm before building. Use plan mode for sessions touching >5 files or >1 architectural boundary.

### Step 6 — Build

Execute the session entry's build steps. **Stay inside the scope list.** If a needed change falls outside scope:

- Pause.
- Surface the deviation: *"This needs touching file X, which is outside scope. Three options: (a) extend this session, (b) capture for a future session, (c) make it a new session now."*
- Wait for decision before continuing.

### Step 7 — When build is done

Run the session entry's verify list with the user. Then prompt the user to run `/session-end` to write back. Don't auto-end — the user signals completion.

## Hard rules

1. **No code before scope confirmation.** Step 4 is not optional.
2. **No silent scope expansion.** Files outside the scope list require explicit decision.
3. **No skipping verification.** Walk the verify list before declaring done.
4. **No loading files outside the orient list.** The session entry defines exactly what's read.

If the protocol can't be followed because the plan is missing or stale: stop and surface the problem. Don't paper over it.
