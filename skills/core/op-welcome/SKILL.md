---
name: op-welcome
description: Auto-fires once at the start of any conversation when `~/.claude/claude-spine-profile.md` does NOT exist (a fresh install with no profile yet). Emits a short welcome block introducing claude-spine and pointing the user at `/onboard` (the ≈2-min essentials interview) so the discovery surface is not "go read the README." If the profile file exists, this skill is silent — do not load its body. Never re-emits within the same conversation.
---

# op-welcome — first-run greeting

The spine ships with no profile. Without `~/.claude/claude-spine-profile.md`, every chapter falls back to defaults — Claude has no calibration for the user's stack, working style, or risk tolerance. The discovery surface for fixing this (`/onboard`) is only documented in `README.md`, which a new user may not have read.

This skill closes that gap by emitting a short greeting at the start of the first conversation after install — enough orientation to know what claude-spine is and what the single first action should be, without becoming a wall of text.

## When this fires

- `~/.claude/claude-spine-profile.md` does NOT exist.
- This is the start of a conversation — no welcome block has been emitted this conversation yet.

If the profile file exists, **skip the skill body**. The user is already calibrated; do not re-read, do not announce.

## What to do

### Step 1 — Verify the profile is missing

Check that `~/.claude/claude-spine-profile.md` does not exist. A quick `test -f ~/.claude/claude-spine-profile.md` via Bash, or a Read attempt that errors, is enough. If the file is present, stop immediately — no message, no further action.

### Step 2 — Emit the welcome block

Output exactly once, verbatim, at the very top of your first turn — before any response to whatever the user asked:

> **Welcome to claude-spine.** This is your first session on this machine.
>
> claude-spine is an operating-discipline layer for Claude Code — 21 skills, 8 slash commands, and a chapter library that loads on demand. Everything is already linked into `~/.claude/`, ready to use.
>
> **One thing first:** run `/onboard` — a ~2-minute, 6-question interview. It calibrates me to your Claude subscription, your stack, and how you like to work. Without it, every session falls back to generic defaults.
>
> ↪ Continuing with what you asked — run `/onboard` whenever you're ready.

That is the whole greeting. No follow-up questions, no "want to do it now?" gate, no per-session preview of what `/onboard` will ask. The user runs `/onboard` when ready.

### Step 3 — Proceed with the user's request

The welcome block is additive context, not a workflow interruption. After emitting it, continue with whatever the user asked for in their first message. If their first message was a greeting like "hi" or "what's this?", the welcome block IS a sufficient response — just stop after it.

## Hard rules

1. **One emission per conversation.** Once shown, never re-show in the same conversation, even if the file is still missing.
2. **No emission if the profile exists.** Detect with file-existence check, never with content guessing.
3. **No prompting.** Inform — do not ask "ready to onboard?" The block is the entire surface.
4. **No expansion.** Do not riff on the block, add bullets, or pre-explain `/onboard`'s questions. The brevity is the point.
5. **Co-firing with `op-spine-active` is fine.** If a fresh-install user opens a plan-driven project, emit welcome first, then let `op-spine-active` announce scope on the next lines.

## Sibling skills

- `op-onboard` — the interview itself. Triggered by `/onboard`.
- `op-spine-active` — plan-driven cold-start (orthogonal trigger: project state, not profile state).
