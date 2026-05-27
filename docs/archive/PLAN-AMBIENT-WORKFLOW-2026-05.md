# Ambient Workflow Refactor — Build Plan

> **Archived 2026-05-27.** This was the L10 planning document. The work has shipped — the live, as-built mechanic lives in [`skills/core/op-spine-active/SKILL.md`](../../skills/core/op-spine-active/SKILL.md), [`global/hooks/spine-writeback.sh`](../../global/hooks/spine-writeback.sh), [`global/commands/done.md`](../../global/commands/done.md), and [`chapters/workflow/05j-cold-start-protocol.md`](../../chapters/workflow/05j-cold-start-protocol.md). The release notes are in [`CHANGELOG.md`](../../CHANGELOG.md) under the `[Unreleased]` L10 / L10.1 entries. Kept here as the design audit trail for what was decided and why. **Do not rely on it as a current spec** — drift between the plan and ship is normal; the skill body and chapter 05j are authoritative.

**Created:** 2026-05-27
**Status:** Design agreed in conversation. Not yet built. Awaiting explicit "build it / go" from user before executor mode.
**Cold-start friendly:** read this file top-to-bottom and you have full context. No need to re-litigate the design.

---

## Why we're doing this

User feedback after the first `/prep` demo run:

1. **`/prep` requires a manual `cd` + `init.sh` step before opening Claude Code.** Friction for beginners. Should be one slash command, end-to-end.
2. **`/session-start` and `/session-end` feel ceremonial and slow.** User wants the workflow to be ambient — every turn already cold-start-resistant, no explicit boundary commands.
3. **"Vibecoders" don't want to keep clicking accept and running commands.** Default UX should be near-zero ceremony. Power-user escape hatches OK as opt-in.

Original goal of the workflow (cold-start resistance, scope discipline, multi-session continuity) is **still valid**. We're not abandoning it — we're moving it from explicit commands the user types to ambient mechanisms (auto-firing skills + Stop hooks) that run silently.

---

## Already shipped this session (UNCOMMITTED)

These changes are on disk but not committed. They're separate from this refactor — they fix a real `/prep` bug the demo surfaced.

- **`~/.claude-spine/skills/core/op-prepare/SKILL.md`** — added quality bar to Step 2 ("don't write the brief from a category-word"), inserted Step 2.5 (Product shape interview), added 2 anti-patterns.
- **`~/.claude-spine/global/commands/prep.md`** — mirrored the change, added "product shape before stack" hard rule, renumbered steps.

These should be committed independently before the ambient refactor starts (cleaner history), or as part of the refactor if user prefers one bundled commit.

---

## Open design question — resolve at start of next session

When the auto-firing skill announces "I'll build session N — adding the form," what happens next?

- **Option A: Auto-proceed silently.** Announcement is informational; Claude starts building immediately. Faster, slightly riskier — if Claude misread the plan, user has to interrupt.
- **Option B: Auto-proceed after a short pause.** Announcement, then ~2 seconds, then builds. Gives user a chance to stop without requiring them to type "go."
- **Option C: Pause until first edit-tool call.** Plan-text announcement only; Claude waits for user to say "go" or modify scope. Slowest, safest.

User leaned toward A/B-style ambient flow. **Default to A unless user picks otherwise.** Note: B is harder to implement (no built-in pause primitive); A is just "skill announces then continues into the work."

---

## The new shape

### 1. `/prep` becomes one-stop

Slash command runs `init.sh` in the cwd as step 0, then walks brief + product-shape + plan. From user's POV: open Claude in any directory, type `/prep`, get a project. No shell step.

**Open detail:** what if the user runs `/prep` in a non-empty dir that's NOT yet a spine project? Probably: `init.sh` is already idempotent and won't overwrite. Verify this still holds when invoked via slash command (Bash permission check etc).

### 2. Replace `/session-start` with auto-firing skill

New skill — working name `op-spine-active` (or merge into existing `op-workflow`). Fires when:
- Current cwd has `docs/plans/` with content
- AND we're on the first turn of a session (no prior assistant turns in this conversation)

What it does:
- Silently reads `docs/PROGRESS.md` + the active session entry
- Announces scope in 3-4 lines ("Section N, session M — building X. Files I'll touch: A, B, C.")
- Proceeds to build (per Option A above) unless user says otherwise

What it does NOT do:
- Pull in the whole repo
- Read ARCHITECTURE.md or PROJECT_PLAN.md (the session entry already has what's needed)
- Wait for "go" / "yes" / "confirmed" before starting

### 3. Replace `/session-end` with Stop hook

New shell hook script: `~/.claude-spine/global/hooks/spine-writeback.sh`. Wired via `~/.claude/settings.json` Stop event.

After every turn in a plan-driven project, the hook:
- Detects what files changed since last hook run (`git diff --name-only HEAD`)
- Appends one line to the session log in the active section plan
- If the session's "verify" checklist all passed (heuristic: any of the verify-related files changed) → updates `PROGRESS.md` pointer to next session
- Stages the doc updates (`git add docs/plans/*.md docs/PROGRESS.md`) but does NOT commit
- Outputs a one-line note to the user: "Spine: logged session entry to plans/section-2.md. PROGRESS now points at session 3."

**Tricky bit:** Stop hooks run on every turn, not just "session boundaries." How does the hook know if THIS turn finished a session vs is mid-session? Probably needs to compare files-touched-this-turn against session entry's "Files to write" list — if all are touched and verify passes, session done. Otherwise just append to log.

### 4. Keep slash commands as escape hatches

Don't delete `/session-start` and `/session-end`. Mark them in INSTALL.md as "legacy / power-user." They still work for:
- Explicitly resetting context mid-conversation
- Forcing a writeback without waiting for hook
- Projects where the auto-firing skill is disabled

Add `/done` as a new explicit "this session is complete, move PROGRESS pointer to next" command for when the heuristic in step 3 is wrong.

---

## What we lose (honest tradeoffs)

| Lost | Mitigation |
|------|------------|
| Explicit "confirm scope" gate before code | Announcement is the scope statement; user stops Claude if wrong. Same protection, no extra turn. |
| Forced verify-walk before commit | End-of-turn message includes verify checklist as advisory text. User decides whether to verify before commit. |
| Hard-stop "no code until you say go" rule | If user says nothing, Claude proceeds. If they want the gate, they type `/session-start` (escape hatch still works). |
| Clean session boundaries in commit history | Stop hook stages but doesn't commit — user still controls commit cadence. |

**Net:** for solo founder / MVP work, the tradeoff is worth it. For regulated / team work, keep the explicit commands.

---

## Build order

Each step is small and verifiable. Test after each before moving on.

### Step 1 — Commit the `/prep` Step 2.5 fix first
Independent of this refactor; ships the demo-surfaced bug fix cleanly.
```bash
cd ~/.claude-spine
git add skills/core/op-prepare/SKILL.md global/commands/prep.md
git commit -m "fix(prep): add product-shape interview before stack questions"
```

### Step 2 — `/prep` auto-runs `init.sh`
Edit `~/.claude-spine/global/commands/prep.md`:
- Add new "Step 0" instruction: "If `docs/` doesn't exist in the cwd, run `~/.claude-spine/init.sh .` first. If it exists, skip."
- Verify Bash permission for `init.sh` is allowed by default `~/.claude/settings.json` (it's not in the allowlist currently — may need to add or accept the prompt).

Test: in fresh `~/spine-demo-2`, run `git init` only, then `/prep`. Should scaffold and continue.

### Step 3 — Build the `op-spine-active` skill
New file: `~/.claude-spine/skills/core/op-spine-active/SKILL.md`.

Trigger description (frontmatter):
> "Auto-fires on the first turn of any Claude Code session in a directory that contains docs/plans/ with at least one section file. Loads docs/PROGRESS.md and the active session entry, announces scope in 3-4 lines, then proceeds to build per the entry."

Body covers: how to read PROGRESS, how to identify active session, what to announce, how to handle "no plan yet" gracefully (suggest `/prep`).

Add symlink target in `install.sh` so it gets installed automatically (existing skill-loop should catch it via glob).

### Step 4 — Build the Stop hook
New file: `~/.claude-spine/global/hooks/spine-writeback.sh`. Bash script. Outputs JSON per Claude Code hook protocol.

Logic:
- Check if cwd has `docs/plans/` — if not, exit silently (no-op).
- Read `docs/PROGRESS.md` → find active section + session.
- Compute diff: `git diff --name-only HEAD` for files-changed-this-turn (or track via temp marker between hook runs).
- Append session-log entry to active section plan.
- If session looks done (heuristic) → bump PROGRESS pointer.
- `git add docs/plans/*.md docs/PROGRESS.md`.
- Print one-line status to stdout.

Wire it in `~/.claude-spine/global/settings.json` as a Stop event. Update install.sh to verify the hook is wired after install.

### Step 5 — Add `/done` command
New file: `~/.claude-spine/global/commands/done.md`. Simple: marks current session done explicitly, regardless of heuristic. Calls the same hook logic but forces session-bump.

### Step 6 — Mark `/session-start` and `/session-end` as legacy
Update their slash-command files with a top note: "Legacy / power-user. Default flow is ambient — see INSTALL.md."

Update `INSTALL.md` "Plan-driven workflow" section: rewrite the flow diagram to show the ambient default. Move the explicit-command flow to a "Power user / explicit mode" subsection.

### Step 7 — Update README + CHANGELOG
- `README.md`: update the workflow overview if it mentions `/session-start`/`/session-end` as primary.
- `CHANGELOG.md`: new entry "L10 — ambient workflow refactor."

### Step 8 — Re-test the full demo
```bash
rm -rf ~/spine-demo
mkdir ~/spine-demo
cd ~/spine-demo
git init
# Open Claude Code → /prep → calorie tracker brief → answer Step 2.5 questions → plan files exist
# Close terminal, open fresh terminal in same dir
# Just say "let's go" or "continue" — skill should auto-load PROGRESS and start building
# After turn ends, check docs/plans/section-1.md and PROGRESS.md were auto-updated
```

If all green: commit and push.

---

## Files affected

**New:**
- `~/.claude-spine/skills/core/op-spine-active/SKILL.md`
- `~/.claude-spine/global/hooks/spine-writeback.sh`
- `~/.claude-spine/global/commands/done.md`

**Edited:**
- `~/.claude-spine/global/commands/prep.md` (add Step 0: auto-run init.sh)
- `~/.claude-spine/global/commands/session-start.md` (add legacy note)
- `~/.claude-spine/global/commands/session-end.md` (add legacy note)
- `~/.claude-spine/global/settings.json` (wire Stop hook)
- `~/.claude-spine/global/INSTALL.md` (ambient default, explicit as power-user)
- `~/.claude-spine/README.md` (workflow overview)
- `~/.claude-spine/CHANGELOG.md` (new L10 entry)
- `~/.claude-spine/install.sh` (verify new skill + hook get installed)

---

## Testing checklist

- [ ] `/prep` in an empty dir scaffolds without manual `init.sh`
- [ ] Brief is real (no one-liner passes through) — Step 2.5 interview fires
- [ ] After `/prep`, closing terminal and opening fresh — Claude auto-loads PROGRESS without `/session-start`
- [ ] Auto-announce of scope is 3-4 lines, not a wall of text
- [ ] Hook runs after every turn — log entry appended
- [ ] PROGRESS pointer advances when session is heuristically done
- [ ] `/done` forces an advance when the heuristic missed it
- [ ] Legacy `/session-start` and `/session-end` still work for users who want them
- [ ] Demo (calorie tracker) runs end-to-end with zero shell commands beyond `git init` and opening Claude

---

## Pointer back to context

- **Conversation transcript so far:** look in `~/.claude/projects/-Users-macbook-claude-spine/` — most recent JSONL file is this session. Previous session's transcript referenced: `/Users/macbook/.claude/projects/-Users-macbook-claude-spine/6de69220-60df-48a0-9dfd-37544a1c8500.jsonl`
- **Spine repo:** `/Users/macbook/claude-spine` (working dir), `~/.claude-spine` (symlink)
- **Last commit:** `5b62022` — cleanup, drop stale landing screenshots
- **Branch:** `main`, synced with origin

When next session opens, read this file first, then optionally check `git status` for the uncommitted `/prep` fix.
