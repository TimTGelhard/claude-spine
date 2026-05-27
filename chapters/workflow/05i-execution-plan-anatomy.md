# 05i — Execution plan anatomy: what's in each file

The planning hierarchy ([05h](05h-multi-session-planning.md)) produces three plan artifacts. Each has a defined shape so cold sessions know exactly where to find what they need.

## `docs/PROJECT_PLAN.md` — the master plan

One per project. Updated rarely (major scope changes only).

Contains:

- **Project goal** — one paragraph. The brief's executive summary, condensed.
- **Constraints** — stack, timeline, team, non-negotiables (security boundaries, compliance).
- **Section list** — ordered, with: name, one-line goal, dependencies, status (`planned` / `in-progress` / `done`).
- **Order rationale** — 1-2 sentences on why this ordering (especially dependencies).
- **Open questions** — things that need a decision before specific sections.
- **Risks** — known unknowns that could change the plan.
- **Status log** — append-only timeline of plan-level changes.

Optimal length: 30-80 lines. If it's longer, you're putting section-detail in the master plan — move it to the section file.

Template: `~/.claude-spine/templates/PROJECT_PLAN.md`.

## `docs/plans/<section>.md` — section plan

One file per section. Each section contains N session-plans inside (typically 2-5).

Contains:

- **Section name + goal** — one paragraph.
- **Done criteria** — concrete bullets defining "section complete". 3-5 items.
- **Cross-session notes** — discoveries from earlier sessions in this section that affect later ones. Updated at session-end.
- **Section-level open questions** — things to decide before specific sessions.
- **Sessions (1..N)** — each session entry has the structure below.

Optimal length: 100-300 lines depending on session count. Past 300, the section is probably two sections.

Template: `~/.claude-spine/templates/SECTION_PLAN.md`.

## Session entry — the cold-start bridge

The single most important artifact. Each entry is the input contract for one fresh terminal. A well-written entry means a cold session can execute without re-deriving anything.

Each session entry contains:

- **Status** — `pending` / `in-progress` / `done` / `blocked`.
- **Session goal** — one line, the user-visible or technical outcome.
- **Files to read** (orient list) — what to load before coding. Cold-start reads exactly this list, nothing more.
- **Files to write/edit** (scope list) — what's in bounds. Anything else is out of scope and requires explicit pause to add.
- **Build steps** — high-level, not line-by-line. 3-7 steps usually.
- **Verify** — the smoke check for this session. Specific (e.g., "Sign-up form submits → row appears in `auth.users`"), not generic ("test it works").
- **Output** — what gets committed (a one-line message hint) and what gets updated in plan files.

A good session entry answers, in <100 lines:

1. What am I building this session?
2. What do I read first to orient?
3. What files are in/out of scope?
4. What steps do I take, at a high level?
5. How do I verify it works?
6. What do I commit + update at the end?

If you can't answer all six from the entry alone, the entry needs more detail before that session starts.

## `docs/PROGRESS.md` — the live pointer (revised role)

Replaces the old "summary of all features" template. Now thin:

- **Active section + active session** — pointer into the section plan.
- **Last session outcome** — one paragraph: what shipped, what carried over.
- **Blockers** — anything stopping the next session.
- **Next session reading list** — derived from the next session entry's "Files to read".
- **Session log** — append-only timeline of completed sessions.

Optimal length: 30-60 lines. The plan files hold the blueprint; `PROGRESS.md` says where you are in it.

Template: `~/.claude-spine/templates/PROGRESS.md` (revised in this update).

## What does NOT go in plan files

- **Code.** That's in the repo.
- **Architecture rationale.** That's in `ARCHITECTURE.md`.
- **Decisions with cross-cutting implications.** Those move to `DECISIONS.md`.
- **Anything derivable from `git log` or `package.json`.** Don't duplicate.
- **Live feature lists.** Use `FEATURES.md` for that.

## Maintaining plans over time

- **End-of-session.** `/done` (legacy alias: `/session-end`; or manual writeback per [05j](05j-cold-start-protocol.md)) updates the session status, adds cross-session notes if anything was discovered, updates `PROGRESS.md`. The Stop hook `spine-writeback.sh` traces per-turn heartbeats during the session but never closes it.
- **End-of-section.** Mark section `done` in `PROJECT_PLAN.md`, draft the next section's plan if it hasn't been drafted yet.
- **Scope discovery.** When work emerges that wasn't planned: pause, propose a new section or new session, get approval, update the plan. Never bundle silently.
- **Plans are not contracts.** When reality diverges, update the plan first, then continue. Never let plan and code drift apart silently — see [05j](05j-cold-start-protocol.md) "Hard rules".

## Why this shape

- **Two-tier indirection** (project → section → session) means cold sessions read 1-2K tokens, not 10-15K.
- **Status flows upward** — session done → section status → project status — without re-deriving from git history or commit messages.
- **Cross-session notes prevent re-discovery** — what session 1 learned about the auth schema is captured for session 2, not re-derived.
- **Templates keep entries uniform** — the `op-spine-active` skill (and the legacy `/session-start`) knows exactly where to look in any session entry, regardless of which section.

## TL;DR

- `PROJECT_PLAN.md` = section list + dependencies + status. 30-80 lines.
- `docs/plans/<section>.md` = N session entries with scope, verify, output. 100-300 lines.
- `PROGRESS.md` = pointer to the active session entry, not project state. 30-60 lines.
- Session entries are the cold-start bridge — write them so a fresh terminal can execute without re-derivation.
