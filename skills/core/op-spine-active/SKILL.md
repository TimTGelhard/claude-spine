---
name: op-spine-active
description: Auto-fires at the start of every conversation in a plan-driven project — a directory containing `docs/plans/` AND `docs/PROGRESS.md`. Silently loads the active session entry, announces scope in 3-4 lines, then proceeds to build per Option A (no "confirm scope?" gate). Ambient replacement for `/session-start`. If no plan exists or the active section file is missing, suggests `/prep`. Does NOT fire if scope has already been announced in this conversation, or if the user has explicitly invoked `/session-start`.
---

# op-spine-active — ambient cold-start

This is the ambient replacement for `/session-start`. Fires at the start of every conversation in a plan-driven project so the user doesn't have to type a command before each session.

Cold-start protocol reference: `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md`. This skill executes steps 1, 2, and 4 of that protocol (load orientation → announce → build) but skips step 2's *gate* — announcement only, no "confirm scope?" prompt.

## When this fires

- The current working directory has `docs/plans/` AND `docs/PROGRESS.md`.
- This is the start of a conversation — no prior orientation announcement has happened.

If you've already announced scope earlier in this conversation, or if the user invoked `/session-start` explicitly (the legacy gated flow), do not re-announce. Skip the skill body.

## What to do

### Step 1 — Load the active session entry

Read in order:

1. `docs/PROGRESS.md` — find active section name + active session number.
2. `docs/plans/<active-section>.md` — locate the active session entry.
3. Every file in the session entry's "Files to read" list.

Do NOT pull `ARCHITECTURE.md`, `PROJECT_PLAN.md`, or unrelated repo files. The session entry defines exactly what's needed.

### Step 2 — Handle missing pieces gracefully

- **`PROGRESS.md` missing active section field** → tell the user: *"No active section in `docs/PROGRESS.md`. Run `/prep` to plan one before starting."* Stop here.
- **Section file missing** → tell the user: *"Section `<name>` has no plan file. Run `/prep <name>` to plan it before starting."* Stop here.
- **Session entry marked `done` already** → tell the user: *"Active session is marked `done`. Run `/done` to advance the pointer (or `/prep <next-section>` if the section finished)."* Stop here.

### Step 3 — Announce scope (3-4 lines max)

Output to the user:

```
Active section: <section name>
Active session:  <session number — session goal>
In scope:        <files-to-write list>
Out of scope:    <relevant exclusions from done-criteria>
```

That's the announcement. Do NOT ask "confirm scope?" — this is the ambient default. The legacy gated flow lives in `/session-start`.

### Step 4 — Proceed to build

Continue immediately to the session's build steps. The user interrupts if the announcement is wrong.

Stay inside the scope list. If a needed change falls outside scope, pause and ask (per the cold-start protocol's hard rules).

## Hard rules

1. **No re-announcement.** If scope was already announced this conversation, skip.
2. **No silent scope expansion.** Touching files outside the scope list requires a pause + explicit decision.
3. **No claiming done without verification.** Walk the session's verify list before declaring done.
4. **No editing the plan without saying so.** If the plan needs to change mid-session, surface it before editing.

## Differences from `/session-start`

The legacy `/session-start` is still available. Compare:

| `/session-start` (legacy / power-user) | `op-spine-active` (ambient default) |
|---|---|
| User types the command to begin | Skill auto-fires |
| Refuses code until "yes / go / confirmed" | Proceeds immediately; user interrupts if wrong |
| Used in regulated / team contexts | Used in solo / MVP / vibecoder contexts |

If the user invokes `/session-start` explicitly in the same conversation, defer to the gated flow — do not double-announce.

## Sibling skills

- `op-prepare` — planning pass (creates the plan files this skill reads)
- `op-workflow` — per-session execution discipline
- `/done` — explicit session-complete bump (advance PROGRESS pointer + verify walk). Counterpart to this skill's ambient announcement.
