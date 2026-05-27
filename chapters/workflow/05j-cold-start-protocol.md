# 05j — Cold-start protocol: how every fresh terminal must behave

The planning model only works if cold sessions follow the protocol. This chapter is the hard rules. If only one chapter is ever read by Claude in a plan-driven project, it should be this one.

## The protocol (in order)

Every fresh terminal in a plan-driven project runs these steps before writing a single line of code:

### 1. Load orientation

- `~/.claude/CLAUDE.md` — already loaded by the harness.
- Project `.claude/CLAUDE.md` — already loaded by the harness.
- `docs/PROGRESS.md` — read to find the active section and active session.
- `docs/plans/<active-section>.md` — read, then locate the active session entry.
- The session entry's "Files to read" list — read each.

If `docs/plans/` doesn't exist or `PROGRESS.md` doesn't point at a session: **stop**. The project hasn't been planned. Tell the user to run `/prep` first.

### 2. Confirm scope (mandatory)

Output to the user, in 4 lines:

```
Active section: <name>
Active session:  <session number + goal>
In scope:        <files-to-write list, comma-separated>
Out of scope:    <relevant exclusions from done-criteria>
```

Then ask: **"Confirm scope before I start?"**

**Wait for explicit "yes / go / confirmed" before any `Edit`, `Write`, or state-mutating `Bash` command.** This is the hard rule. No coding without scope confirmation.

### 3. Plan-if-needed

If the session entry's build steps are vague (e.g., "implement X"), draft a 3-5 step breakdown and confirm before building. Use plan mode for sessions touching >5 files or >1 architectural boundary (see [04b](../foundations/04b-plan-and-fast-mode.md)).

### 4. Build

Execute the session entry's build steps. Stay inside the scope list. If a needed change falls outside scope: stop, surface it, decide together whether to extend this session or capture it for a future one.

### 5. Verify

Walk the session entry's verify list. Don't skip — "it compiled" is not "it works." See [05d](05d-stage-3-build.md) and [11d](../signaling/11d-verification-signals.md). If a check wasn't possible (no device, no env), say so plainly — don't claim it works.

### 6. End-of-session writeback (mandatory)

Before the terminal closes:

- Update the session entry's status to `done` (or `blocked` with one-line reason, or `in-progress` if paused mid-work).
- Add to the section's "Cross-session notes" if anything was discovered that affects later sessions.
- Update `PROGRESS.md`: last-session-outcome paragraph + next-active-session pointer + next session reading list.
- Stage changes (`git add` specific files, never `-A` or `.`).
- Suggest a one-line imperative commit message. Do NOT commit unless the user says to.

`/session-end` automates this. Prefer it over from-memory writes.

## The hard rules (no exceptions for speed)

1. **No code before scope confirmation.** If user says "just start coding," push back once: "We agreed the protocol — confirm scope first." If they insist, proceed but log `scope confirmation skipped` in `PROGRESS.md`.
2. **No closing the terminal without writeback.** End-of-session updates are not optional. If user tries to close mid-session, write status `in-progress` with a one-line resume note.
3. **No silent scope expansion.** If the session entry's scope list says files A, B, C — touching D requires a pause and explicit decision.
4. **No claiming "done" without verification.** Walk the verify list, or name which checks weren't possible and why.
5. **No editing the plan without saying so.** If the plan needs to change mid-session, say "I need to update the section plan because X" and update it before continuing.
6. **No bundling.** One feature per session, one bug per change. Adjacent issues get captured in cross-session notes, not silently bundled.

## Failure modes to watch for

- **"I'll just check one thing in another section."** Context-leak. Stay in the active session — note the cross-section question for later.
- **"This session is bigger than I thought."** Split it. Mark current session done at a clean break, draft a new session entry for the rest.
- **"`PROGRESS.md` is out of date so I'll skip reading it."** No. Read it anyway. If stale, ask the user before proceeding — see [08a](08a-discovery-sequence.md) for brownfield discovery.
- **"User wants to skip scope-confirm because they're in a hurry."** Flag the cost (drift risk). Comply if they insist. Log it.
- **"Verify list is generic ('test it works'), so I'll skip."** No — say the verify list is vague and ask the user for the concrete check before claiming done.

## When a session deviates from its plan

Three outcomes are healthy:

1. **In scope, completes as planned.** Mark `done`. Move on.
2. **In scope, discovers something requiring a new session.** Note in cross-session notes. Don't bundle.
3. **Out of scope by necessity (blocker upstream).** Pause. Decide: extend this session, or close as `blocked` and open a new one for the dependency?

**Unhealthy:** scope creeps silently and the session "completes" with twice the planned changes. This is exactly what plan-driven sessions exist to prevent.

## Slash commands that enforce the protocol

| Command | Step covered | What it does |
|---|---|---|
| `/prep` | Pre-protocol (no plan yet) | Runs the planning pass — see [05h](05h-multi-session-planning.md) |
| `/session-start` | Steps 1-2 | Loads active session entry, refuses code until scope is confirmed |
| `/session-end` | Step 6 | Updates section plan + `PROGRESS.md`, stages changes, suggests commit message |

These commands close the gap between "we know the protocol" and "the protocol fires every time." Prefer them over from-memory rituals.

## What this protocol guarantees

When followed:

- Cold sessions never start without orientation.
- Scope is never silently expanded.
- Plans and code never drift apart undetected.
- "Done" always means verified.
- Next session always has a clean handoff.

The protocol is what makes the planning model robust. Skipping any step leaks one of the guarantees above.

## TL;DR

- Every fresh session: load orientation → confirm scope → plan-if-needed → build → verify → writeback.
- Six steps. Six hard rules. No exceptions for speed.
- `/session-start` and `/session-end` make the protocol the default, not the exception.
- If no plan exists: stop. Run `/prep` first.
