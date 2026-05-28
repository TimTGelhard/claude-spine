# Progress — <PROJECT NAME>

> Live pointer to where work resumes. Updated at every `/done`.
> Claude reads this first at the start of every session (via the `op-spine-active` skill).
>
> This file does NOT inventory features (use `FEATURES.md`) or list every bug (use issues / `FEATURES.md`).
> Its job is to answer: *what's the next session, what does it need, what's blocking it?*

<!-- ⚠️ DO NOT REFORMAT THE NEXT 6 LINES (or the **Session** bullet below). They are parsed by `spine-writeback.sh` via a regex that expects the literal `- **Section**:` / `- **Session**:` shape with backticks around the name. If you swap the bold for italics, drop the backticks, change the bullet style, or move these bullets to a different sub-heading, the Stop-hook heartbeat will silently no-op — your session activity won't be logged. -->

## Active section

- **Section**: `<section-name>` (from `docs/PROJECT_PLAN.md`)
- **Plan file**: `docs/plans/<section-name>.md`
- **Section status**: `in-progress | blocked | done`

## Active session

- **Session**: `<N>` — `<one-line goal>`
- **Status**: `pending | in-progress | blocked`

## Last session outcome

(Filled by `/done`. One paragraph. What shipped, what carried over, what's notable.)

_(no sessions run yet)_

## Blockers

Things that stop the next session from starting. Empty = ready to go.

- _(none)_

## Next session reading list

Copy of the next session entry's "Files to read" block. So a fresh Claude can orient in 30 seconds.

- `docs/ARCHITECTURE.md`
- `docs/plans/<section-name>.md`
- `<file-1>`
- `<file-2>`

---

## Session log

Append-only. One line per session. Prune when it exceeds ~30 entries — move old entries to `docs/sessions-archive.md` if you want history.

### YYYY-MM-DD
- _(no sessions yet)_

---

## Notes

- For the project plan (sections + dependencies), see `docs/PROJECT_PLAN.md`.
- For per-section detail (session entries with build steps + verify checks), see `docs/plans/<section-name>.md`.
- For long-lived feature inventory, see `docs/FEATURES.md`.
- For non-obvious decisions, see `docs/DECISIONS.md`.
