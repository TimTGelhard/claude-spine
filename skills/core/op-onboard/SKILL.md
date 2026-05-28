---
name: op-onboard
description: Use to create or refresh `~/.claude/claude-spine-profile.md` — the personal calibration file capturing the user's Claude subscription, experience level, stack preferences, environment (OS / VCS / plans-dir / currency), project context (typical work / artifact / team / users / org), working style, output format, and risk tolerance. Fires when the user invokes `/onboard` (essentials), `/onboard --deep` (full ~28-question interview), or says "re-onboard" / "update my profile" / "redo onboarding". For the first-run greeting that points the user at `/onboard`, see the sibling `op-welcome` skill — it owns the file-absence surface so this skill never auto-launches an interview unannounced.
---

# op-onboard — personal calibration

Captures and maintains `~/.claude/claude-spine-profile.md`. The profile shapes Claude's tone, defaults, and discipline for this user across all projects.

## Mode selection

1. **`/onboard` with no profile yet** → run **essentials** (10 questions), write the profile, then offer the deep path. (The first-run *greeting* is `op-welcome`'s job; this mode runs once the user actually invokes `/onboard`.)
2. **`/onboard`** with profile present → re-run essentials. Read the existing profile first; show current values; ask only the ones the user wants to change.
3. **`/onboard --deep`** → if profile is missing, run essentials first, then deep (18 more questions + 2 opt-in hook prompts). If profile exists, jump straight to deep.
4. **Ad-hoc edits** ("change my push-back to spar with me") → edit the matching profile section directly; don't restart the interview.

## Adjacent files (read on-demand)

| File | When |
|---|---|
| `~/.claude-spine/skills/core/op-onboard/questions-essential.md` | Always — the 10 essentials |
| `~/.claude-spine/skills/core/op-onboard/questions-deep.md` | Deep mode only — the 18 follow-ups |
| `~/.claude-spine/skills/core/op-onboard/profile-template.md` | Before writing the profile file |
| `~/.claude-spine/skills/core/op-onboard/subscription-tune.md` | Step 5 — propose autoCompactWindow + effortLevel tune based on Q1 |
| `~/.claude-spine/skills/core/op-onboard/hook-tune.md` | Step 7 (deep only) — opt-in PostToolUse hooks (auto-typecheck + auto-format) |
| `~/.claude-spine/skills/core/op-onboard/handoff.md` | Step 8 — emit the closing "you're all set" message |

## How to run the interview

1. **Print the preview block** (only on first-run, i.e. profile is missing). On re-runs (profile exists), skip — the user knows what they're getting into. Adapt the text to the mode:

   - `/onboard` essentials, first-run: *"I'll ask 10 quick questions across ~3 minutes. After saving the essentials, I'll offer the deep pass (18 more, ~5 more minutes). You can stop after the essentials and run `/onboard --deep` later — nothing about this is locked in."*
   - `/onboard --deep`, first-run: *"This is the full pass — 10 essentials (~3 min) + 18 deep (~5 min) + 2 opt-in hook prompts at the end. ~8 minutes total. Profile is plain markdown — hand-edit anything later."*

   Emit as a normal text message, not inside `AskUserQuestion`. No "press enter" gate — the next AskUserQuestion is itself the continue affordance.

2. Read the relevant question file.
3. Ask **one question at a time** via `AskUserQuestion` — each question's options are pre-defined in the file. Use `multiSelect: true` where the question file says so.
4. **After all 10 essentials are captured (last one is Q9):** save the profile. Read `profile-template.md` and write `~/.claude/claude-spine-profile.md` with the essentials. Stamp `Captured: <today>` on first write, `Last updated: <today>` on every run. This guarantees the essentials are persisted even if the user aborts during the next steps.
5. Run the **subscription-based settings tune** — load `subscription-tune.md` and follow its flow. Proposes adjusting `autoCompactWindow` and `effortLevel` to match the user's plan.
6. Ask: "Want to continue into the deep interview, or save now and run `/onboard --deep` later?" If yes → load `questions-deep.md` and continue; update the profile file with deep values when done. If no → leave deep sections marked `(unfilled — run /onboard --deep to capture)`.
7. **If deep ran:** run the **Hook tuning** pass — load `hook-tune.md` and follow its flow. Proposes wiring two opt-in PostToolUse hooks (auto-typecheck, auto-format) into `~/.claude/settings.json`. Skipped on essentials-only runs.
8. **Emit the handoff message** — load `handoff.md` and emit the closing block. This is the only place the user gets a complete picture of what was captured and what's now possible — don't skip it, even on re-runs.

## Rules

- **One question at a time.** No walls. Deep mode is opt-in, never default.
- **Don't infer.** Skipped or "Other" answers stay as the user wrote them; don't guess.
- **Don't capture sensitive data.** No client names, addresses, API keys. Working-style only.
- **Write surface is allow-listed.** This skill writes to exactly two files: `~/.claude/claude-spine-profile.md` (always) and `~/.claude/settings.json`. In `settings.json`, only two write surfaces are permitted, both with explicit per-run approval:
  1. The top-level keys `autoCompactWindow` and `effortLevel` — see `subscription-tune.md`.
  2. A `hooks.PostToolUse` block with matcher `Edit|Write|MultiEdit`, containing only the named entries `typecheck-after-edit.sh` and/or `format-on-save.sh` — see `hook-tune.md`.

  No other files. No other keys. No other hooks. No edits to existing hook entries.
