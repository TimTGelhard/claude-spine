---
name: op-onboard
description: Use to create or refresh `~/.claude/claude-spine-profile.md` — the personal calibration file capturing the user's experience level, stack preferences, project context, working style, output format, and risk tolerance. Fires when the profile file does not exist (first-run calibration), or when the user invokes `/onboard` (re-run essentials), `/onboard --deep` (full ~15-question interview), or says "re-onboard" / "update my profile" / "redo onboarding". The profile persists across all projects and is read by Claude at the start of every session.
---

# op-onboard — personal calibration

Captures and maintains `~/.claude/claude-spine-profile.md`. The profile shapes Claude's tone, defaults, and discipline for this user across all projects.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to `$HOME` before reading.

## Mode selection

1. **First-run** (profile missing) → run **essentials** (5 questions), write the profile, then offer the deep path.
2. **`/onboard`** (no flag) → re-run essentials. Read the existing profile first; show current values; ask only the ones the user wants to change.
3. **`/onboard --deep`** → if profile is missing, run essentials first, then deep (~10 more questions). If profile exists, jump straight to deep.
4. **Ad-hoc edits** ("change my push-back to spar with me") → edit the matching profile section directly; don't restart the interview.

## Adjacent files (read on-demand)

| File | When |
|---|---|
| `~/.claude-spine/skills/core/op-onboard/questions-essential.md` | Always — the 5 essentials |
| `~/.claude-spine/skills/core/op-onboard/questions-deep.md` | Deep mode only — the ~10 follow-ups |
| `~/.claude-spine/skills/core/op-onboard/profile-template.md` | Before writing the profile file |

## How to run the interview

1. Read the relevant question file.
2. Ask **one question at a time** via `AskUserQuestion` — each question's options are pre-defined in the file. Use `multiSelect: true` where the question file says so.
3. After essentials, ask: "Want to continue into the deep interview, or save now and run `/onboard --deep` later?"
4. Read `profile-template.md` and write `~/.claude/claude-spine-profile.md` using the exact section structure. Stamp `Captured: <today>` on first write, `Last updated: <today>` on every run.

## Rules

- **One question at a time.** No walls. Deep mode is opt-in, never default.
- **Don't infer.** Skipped or "Other" answers stay as the user wrote them; don't guess.
- **Don't capture sensitive data.** No client names, addresses, API keys. Working-style only.
- **Never write outside `~/.claude/claude-spine-profile.md`.** This skill has one output file.

## After writing the profile

Tell the user: (a) the file path, (b) Claude reads it every session, (c) re-run with `/onboard` or `/onboard --deep`, (d) hand-editing is fine — it's plain markdown.
