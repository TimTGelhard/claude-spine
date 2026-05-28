---
name: op-spine-active
description: Auto-fires at the start of every conversation in a plan-driven project. Detects plan/progress files at any of four common conventions (`docs/plans/` + `docs/PROGRESS.md`, `docs/specs/` + `docs/PROGRESS.md`, `plans/` + `PROGRESS.md`, `specs/` + `PROGRESS.md`), or whatever the project's `CLAUDE.md` declares under a `Plan layout:` line. Silently loads the active session entry, announces scope in 3-4 lines, then proceeds to build (no "confirm scope?" gate — the announcement IS the scope statement; the user interrupts if wrong). If no plan exists or the active section file is missing, suggests `/prep`. Does NOT fire if scope has already been announced in this conversation.
---

# op-spine-active — ambient cold-start

This skill makes plan-driven projects cold-start-resistant without any explicit command. Fires at the start of every conversation in a plan-driven project so the user just opens Claude and keeps working.

Cold-start protocol reference: `~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md`. This skill executes steps 1, 2, and 4 of that protocol — announcement only, no gate. For safety-critical sessions wanting a hard "no code until I confirm" pause, use Claude Code's built-in plan mode (Shift+Tab Tab).

## When this fires

This skill fires when the current working directory has a plan layout the skill recognizes. Try paths in this order; the first match wins:

1. **Project override.** If the project's `CLAUDE.md` or `.claude/CLAUDE.md` contains a line of the form `Plan layout: <plans-dir> <progress-file>` (e.g., `Plan layout: roadmap/ roadmap/STATUS.md`), use those paths.
2. **`docs/plans/` + `docs/PROGRESS.md`** — the canonical spine convention.
3. **`docs/specs/` + `docs/PROGRESS.md`** — common spec-first variant.
4. **`plans/` + `PROGRESS.md`** — repo-root variant.
5. **`specs/` + `PROGRESS.md`** — repo-root spec-first variant.

If none of those match, do NOT fire — let the conversation start cold. (A user without any plan layout is probably doing exploratory or one-off work; ambient cold-start is for repeat plan-driven sessions.)

In the rest of this skill body, `<plans-dir>` and `<progress-file>` refer to whichever pair was selected above.

Also: if you've already announced scope earlier in this conversation, do not re-announce. Skip the skill body.

## What to do

### Step 1 — Load the active session entry

Read in order:

1. `<progress-file>` — find active section name + active session number.
2. `<plans-dir>/<active-section>.md` — locate the active session entry.
3. Every file in the session entry's "Files to read" list.

Do NOT pull `ARCHITECTURE.md`, `PROJECT_PLAN.md`, or unrelated repo files. The session entry defines exactly what's needed.

### Step 2 — Handle missing pieces gracefully

- **`<progress-file>` missing active section field** → tell the user: *"No active section in `<progress-file>`. Run `/prep` to plan one before starting."* Stop here.
- **Section file missing** → tell the user: *"Section `<name>` has no plan file at `<plans-dir>/<name>.md`. Run `/prep <name>` to plan it before starting."* Stop here.
- **Session entry marked `done` already** → tell the user: *"Active session is marked `done`. Run `/done` to advance the pointer (or `/prep <next-section>` if the section finished)."* Stop here.

### Step 3 — Announce scope (3-4 lines max)

Output to the user:

```
Active section: <section name>
Active session:  <session number — session goal>
In scope:        <files-to-write list>
Out of scope:    <relevant exclusions from done-criteria>
```

That's the announcement. Do NOT ask "confirm scope?" — the announcement IS the scope statement; the user interrupts if it's wrong.

### Step 4 — Proceed to build

Continue immediately to the session's build steps. Stay inside the scope list. If a needed change falls outside scope, pause and ask (per the cold-start protocol's hard rules).

## Hard rules

1. **No re-announcement.** If scope was already announced this conversation, skip.
2. **No silent scope expansion.** Touching files outside the scope list requires a pause + explicit decision.
3. **No claiming done without verification.** Walk the session's verify list before declaring done.
4. **No editing the plan without saying so.** If the plan needs to change mid-session, surface it before editing.

## Sibling skills

- `op-prepare` — planning pass (creates the plan files this skill reads)
- `op-workflow` — per-session execution discipline
- `/done` — explicit session-complete (advance PROGRESS pointer + verify walk). Counterpart to this skill's ambient announcement.
