# Section: <SECTION NAME>

> One section from `docs/PROJECT_PLAN.md`. Contains N session-plans inside.
> Each session is a single fresh-terminal execution.
>
> Drafted just-in-time, right before this section starts — not all upfront.

## Section goal

<One paragraph. What this section delivers end-to-end.>

## Done criteria

Concrete bullets defining "section complete". A non-developer could check these.

- [ ] <e.g., "Users can sign up with email + Google.">
- [ ] <e.g., "RLS policies enforce per-user access on `quotes` table.">
- [ ] <e.g., "Sign-out clears session and redirects to /.">
- [ ] <e.g., "SMOKE_TESTS.md updated with the section's smoke flows.">

## Cross-session notes

Discoveries from earlier sessions in this section that affect later sessions. Updated at end-of-session.

- (empty — fill as sessions run)

## Section-level open questions

Decisions needed before specific sessions in this section.

- <e.g., "Magic links or password auth? — needed before Session 1">

---

## Session 1 — <ONE-LINE GOAL>

**Status**: pending

**Goal**: <One line. The user-visible or technical outcome of this session.>

**Files to read** (orient before coding — exact list a cold session reads):

- `docs/ARCHITECTURE.md`
- `docs/plans/<previous-section>.md` (if dependent on prior work)
- `<existing-file-1>` <— and why (e.g., "current auth wiring")>
- `<existing-file-2>`

**Files to write/edit** (scope — anything else is out of bounds without explicit decision):

- `<file-1>`
- `<file-2>`
- `<migration-file>`

**Build steps** (high-level, 3-7 items):

1. <Step 1>
2. <Step 2>
3. <Step 3>

**Verify** (concrete checks, not "test it works" — when this session matches a recognized pattern, `op-prepare`'s procedure §6.2 scaffolds these; refine per your stack):

- <e.g., "Sign-up form submits → row appears in `auth.users` table.">
- <e.g., "Sign in with wrong password → returns error toast, no redirect.">
- <e.g., "RLS check: non-owner session cannot read another user's row.">

**Output**:

- Commit message hint: `<imperative one-liner>`
- Update: this section file (mark session `done`), `PROGRESS.md` (next session pointer).

---

## Session 2 — <ONE-LINE GOAL>

**Status**: pending

**Goal**: <one line>

**Files to read**:
- ...

**Files to write/edit**:
- ...

**Build steps**:
1. ...

**Verify**:
- ...

**Output**:
- Commit message hint: `<imperative one-liner>`
- Update: this section file, `PROGRESS.md`.

---

## Session N — <ONE-LINE GOAL>

(same shape as above)
