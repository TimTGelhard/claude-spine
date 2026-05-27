---
name: op-onboard
description: Use to create or refresh `~/.claude/claude-spine-profile.md` — the personal calibration file capturing the user's Claude subscription, experience level, stack preferences, project context, working style, output format, and risk tolerance. Fires when the user invokes `/onboard` (essentials), `/onboard --deep` (full ~20-question interview), or says "re-onboard" / "update my profile" / "redo onboarding". For the first-run greeting that points the user at `/onboard`, see the sibling `op-welcome` skill — it owns the file-absence surface so this skill never auto-launches an interview unannounced.
---

# op-onboard — personal calibration

Captures and maintains `~/.claude/claude-spine-profile.md`. The profile shapes Claude's tone, defaults, and discipline for this user across all projects.

> Paths below are written as `~/.claude-spine/...`. Expand `~` to `$HOME` before reading.

## Mode selection

1. **`/onboard` with no profile yet** → run **essentials** (7 questions), write the profile, then offer the deep path. (The first-run *greeting* is `op-welcome`'s job; this mode runs once the user actually invokes `/onboard`.)
2. **`/onboard`** with profile present → re-run essentials. Read the existing profile first; show current values; ask only the ones the user wants to change.
3. **`/onboard --deep`** → if profile is missing, run essentials first, then deep (13 more questions). If profile exists, jump straight to deep.
4. **Ad-hoc edits** ("change my push-back to spar with me") → edit the matching profile section directly; don't restart the interview.

## Adjacent files (read on-demand)

| File | When |
|---|---|
| `~/.claude-spine/skills/core/op-onboard/questions-essential.md` | Always — the 7 essentials |
| `~/.claude-spine/skills/core/op-onboard/questions-deep.md` | Deep mode only — the 13 follow-ups |
| `~/.claude-spine/skills/core/op-onboard/profile-template.md` | Before writing the profile file |

## How to run the interview

1. Read the relevant question file.
2. Ask **one question at a time** via `AskUserQuestion` — each question's options are pre-defined in the file. Use `multiSelect: true` where the question file says so.
3. **Right after Q6: save the profile.** Read `profile-template.md` and write `~/.claude/claude-spine-profile.md` with the essentials. Stamp `Captured: <today>` on first write, `Last updated: <today>` on every run. This guarantees the essentials are persisted even if the user aborts during the next steps.
4. Run the **subscription-based settings tune** (see section below) — proposes adjusting `autoCompactWindow` and `effortLevel` to match the user's plan.
5. Ask: "Want to continue into the deep interview, or save now and run `/onboard --deep` later?" If yes → load `questions-deep.md` and continue; update the profile file with deep values when done. If no → leave deep sections marked `(unfilled — run /onboard --deep to capture)`.
6. **Emit the handoff message** (see "After writing the profile" below). This is the only place the user gets a complete picture of what was captured and what's now possible — don't skip it, even on re-runs.

## Rules

- **One question at a time.** No walls. Deep mode is opt-in, never default.
- **Don't infer.** Skipped or "Other" answers stay as the user wrote them; don't guess.
- **Don't capture sensitive data.** No client names, addresses, API keys. Working-style only.
- **Write surface is allow-listed.** This skill writes to exactly two files: `~/.claude/claude-spine-profile.md` (always) and `~/.claude/settings.json` (only the keys `autoCompactWindow` and `effortLevel`, only with explicit per-run approval — see "Subscription-based settings tuning" below). No other files. No other keys.

## Subscription-based settings tuning

After essentials are saved and before offering the deep interview, propose a settings.json tune based on Q1 (subscription). The spine ships Pro-safe defaults; Max 20× users with 1M-context models leave performance on the table unless these get raised.

### Mapping table (Q1 answer → target settings)

| Q1 answer | `autoCompactWindow` | `effortLevel` |
|---|---|---|
| Free | 180000 | high |
| Pro | 180000 | high |
| Max (5×) | 180000 | high |
| Max (20×) | **800000** | **xhigh** |
| Other (free-text) | leave alone | leave alone |

### Flow

1. Read `~/.claude/settings.json`. If it doesn't exist, skip the tune entirely (no install, no settings to touch).
2. Compute target values from the mapping table using Q1's answer.
3. If target matches current for both keys → no diff, skip silently.
4. If Q1 was "Other" → skip silently. Mention in the post-write summary that settings.json was left alone and point at `global/INSTALL.md`'s "Tuning for Max 20×" section.
5. Otherwise → first print a short **plain-English explanation block** as a normal text message (not inside `AskUserQuestion`), then ask the Apply/Skip question. Template the block like this (substitute the user's subscription name and the current/target numbers):

   ```
   You're on {{plan}}. The defaults ship Pro-safe — let me propose two tweaks
   so you get the most out of your plan:

     • autoCompactWindow:  {{current}} → {{target}} tokens
       (how full the conversation gets before Claude auto-compresses earlier
       messages — raising this lets you stay in one session longer without
       losing context. Safe on plans with bigger context windows.)

     • effortLevel:  {{current}} → {{target}}
       (how much reasoning Claude does per response. "xhigh" is the deepest
       setting and is only worth it when your plan covers the extra cost.)

   Both write to ~/.claude/settings.json. You can hand-edit either value later.
   ```

   Then call `AskUserQuestion` with a tight question:
   - **Question:** "Apply these two settings tweaks?"
   - **Header:** `Settings`
   - **Option A:** **Apply** — "Write both values to settings.json"
   - **Option B:** **Skip** — "Leave settings.json alone (recommended if you've hand-tuned)"

6. On Apply: use `Edit` to replace the two key lines in-place. Do NOT rewrite the whole file — preserve the rest exactly. If the format doesn't match (e.g., user reformatted settings.json), abort the write and tell the user to hand-edit; do not retry with broader matching.
7. On Skip: note it and continue. The profile still reflects the subscription answer — just settings.json is untouched.

The explanation block is always shown, regardless of whether current values match ship defaults. A user who hand-tuned to `400000` and re-runs `/onboard` will see "400000 → 800000" and decline; that's the correct outcome — explicit approval, not silent inference.

## After writing the profile — the handoff

This is the **only place** the user gets a complete picture of what just happened and what's now possible. Don't be terse here. Don't lecture either — this is one focused, well-structured message that lands the experience. Treat it like the "you're all set" screen of a polished app.

Emit a single message in this shape. Substitute the bracketed values from what the user actually picked. Drop any section that doesn't apply (e.g., the deep-mode line if they completed deep).

```
You're set up. Profile saved to ~/.claude/claude-spine-profile.md.

Here's what just happened:
  • I know you're a [Plan] user with [Experience] experience, working mostly
    on [Stack] for [Project context].
  • Across every Claude Code session on this machine, I'll match your
    push-back intensity ([Push-back]), answer length ([Answer length]),
    and reasoning depth ([Reasoning depth]).
  • settings.json: [tuned to {{plan}} defaults | left alone | not present].
  • Deep profile: [completed | skipped — run `/onboard --deep` when you want
    to capture stack details, signal preferences, output format, and risk
    tolerance (13 more questions, ~5 min)].

What you have available now:
  /spine            see everything that's loaded (skills, commands, chapters)
  /hooks            list every hook configured for this session (event + script)
  /prep             plan a new project or a major feature  (run in a project dir)
  /onboard          re-run essentials  (`--deep` for the full 20-question pass)
  /suggest          capture a high-signal moment to your personal bucket
  /curate           review captured moments and apply approved ones
  /add-skill        add a new skill to your personal bucket
  /done             close the current build session cleanly
  /refresh-bucket   rebuild the bucket index after manual file drops

What to do next:
  • Starting a new project?  cd into the directory and run /prep.
  • In an existing codebase?  Just ask me something — I'll route based on
    what you need. Type /spine if you want to see the full surface.
  • Just exploring?  Ask "what is claude-spine" or open ~/.claude-spine/README.md.

Both your profile (~/.claude/claude-spine-profile.md) and settings
(~/.claude/settings.json) are plain files — open and hand-edit anytime.
Re-run /onboard to walk through the essentials again.
```

### Hard rules for the handoff

1. **Always emit this block** on first-run completion and on every re-run, even if the user only re-answered one essential. Re-runs are how the user double-checks their setup landed correctly.
2. **Substitute real values** — do not leave bracketed placeholders. If the user picked "Other" for any field, use their free-text answer verbatim.
3. **Only list commands that exist** — count `~/.claude-spine/global/commands/*.md` if uncertain. Don't invent commands that aren't installed.
4. **No follow-up questions in this block.** It's the closing message. The user knows where to go.
5. **No marketing.** Don't tell the user the spine is "powerful" or "production-grade." State what was captured and what's available.
