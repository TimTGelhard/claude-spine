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
3. **`/onboard --deep`** → if profile is missing, run essentials first, then deep (13 more questions + 2 opt-in hook prompts). If profile exists, jump straight to deep.
4. **Ad-hoc edits** ("change my push-back to spar with me") → edit the matching profile section directly; don't restart the interview.

## Adjacent files (read on-demand)

| File | When |
|---|---|
| `~/.claude-spine/skills/core/op-onboard/questions-essential.md` | Always — the 7 essentials |
| `~/.claude-spine/skills/core/op-onboard/questions-deep.md` | Deep mode only — the 13 follow-ups (the 2 hook-tuning prompts live in this file's `## Hook tuning` section) |
| `~/.claude-spine/skills/core/op-onboard/profile-template.md` | Before writing the profile file |

## How to run the interview

1. Read the relevant question file.
2. Ask **one question at a time** via `AskUserQuestion` — each question's options are pre-defined in the file. Use `multiSelect: true` where the question file says so.
3. **Right after Q6: save the profile.** Read `profile-template.md` and write `~/.claude/claude-spine-profile.md` with the essentials. Stamp `Captured: <today>` on first write, `Last updated: <today>` on every run. This guarantees the essentials are persisted even if the user aborts during the next steps.
4. Run the **subscription-based settings tune** (see section below) — proposes adjusting `autoCompactWindow` and `effortLevel` to match the user's plan.
5. Ask: "Want to continue into the deep interview, or save now and run `/onboard --deep` later?" If yes → load `questions-deep.md` and continue; update the profile file with deep values when done. If no → leave deep sections marked `(unfilled — run /onboard --deep to capture)`.
6. **If deep ran:** run the **Hook tuning** pass (see "Hook tuning (deep mode only)" below) — proposes wiring two opt-in PostToolUse hooks (auto-typecheck, auto-format) into `~/.claude/settings.json`. Skipped on essentials-only runs.
7. **Emit the handoff message** (see "After writing the profile" below). This is the only place the user gets a complete picture of what was captured and what's now possible — don't skip it, even on re-runs.

## Rules

- **One question at a time.** No walls. Deep mode is opt-in, never default.
- **Don't infer.** Skipped or "Other" answers stay as the user wrote them; don't guess.
- **Don't capture sensitive data.** No client names, addresses, API keys. Working-style only.
- **Write surface is allow-listed.** This skill writes to exactly two files: `~/.claude/claude-spine-profile.md` (always) and `~/.claude/settings.json`. In `settings.json`, only two write surfaces are permitted, both with explicit per-run approval:
  1. The top-level keys `autoCompactWindow` and `effortLevel` — see "Subscription-based settings tuning" below.
  2. A `hooks.PostToolUse` block with matcher `Edit|Write|MultiEdit`, containing only the named entries `typecheck-after-edit.sh` and/or `format-on-save.sh` — see "Hook tuning (deep mode only)" below.

  No other files. No other keys. No other hooks. No edits to existing hook entries.

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

## Hook tuning (deep mode only)

After the deep interview is saved (and the optional `## Notes` follow-up captured), propose two opt-in PostToolUse hooks that the spine ships but defaults off: **`typecheck-after-edit`** and **`format-on-save`**. Both scripts live at `~/.claude/hooks/<name>.sh` after `install.sh` runs; the gate is whether `settings.json` references them.

This pass mirrors the subscription tune: read `settings.json` → per-hook explanation block → `AskUserQuestion` → `Edit`-insert on Apply, with a fail-fast hand-edit fallback when the existing block doesn't match the canonical shape.

### When this runs

Only when the deep interview completed in this run. Essentials-only runs skip this section entirely — hooks are a deep-tier opt-in on purpose (the user should understand what a hook is before accepting one). On a re-run that revisits only deep, this still runs.

### Per-hook pre-flight

For each of the two hooks, before asking:

1. **Read `~/.claude/settings.json`.** If the file is missing → skip the entire Hook tuning section silently (no install, nothing to write into).
2. **Check whether the hook is already wired.** Grep the file for the literal command path (`${HOME}/.claude/hooks/typecheck-after-edit.sh` or `${HOME}/.claude/hooks/format-on-save.sh`). If present → skip *this* hook silently (no question, no diff — already opted in).
3. **Check whether `PostToolUse` exists with a shape we don't own.** If `PostToolUse` is present and its matcher is anything other than `Edit|Write|MultiEdit`, or it contains hooks beyond the two spine-named scripts → emit the **Hand-edit fallback** (below) for any not-yet-installed hook the user wants, and skip Edit. Do not surgically mutate someone else's PostToolUse block.

Only proceed to the question + Edit path when the hook is absent AND the surrounding settings.json is in a shape this skill owns (no `PostToolUse` block at all, OR `PostToolUse` containing only the spine-named scripts).

### Question G1 — Auto-typecheck after edits

Print this plain-English block first (as a normal text message, not inside `AskUserQuestion`):

```
Optional: auto-typecheck after each edit. After I edit a .ts or .tsx file,
this runs your project's TypeScript compiler (or a global tsc) against the
nearest tsconfig.json and surfaces any errors mentioning the edited file.
For .py files it runs `python -m py_compile` (just verifies the file parses
— no type checking).

Failures print to my terminal so I see them in the next turn. The hook
NEVER blocks the edit. Default-off; this prompt opts you in. Hand-edit
~/.claude/settings.json later to remove.
```

Then call `AskUserQuestion`:
- **Question:** "Turn on auto-typecheck after edits?"
- **Header:** `Typecheck`
- **Option A:** **Yes — turn it on** — wires the PostToolUse hook in settings.json
- **Option B:** **Not now** — re-run `/onboard --deep` later to add

### Question G2 — Auto-format after edits

Same shape — explanation block first:

```
Optional: auto-format after each edit. After I edit a recognized file, this
runs your project's formatter:

  .ts .tsx .js .jsx .json .md .css .html .yaml  →  Prettier  (if nearest
                                                              package.json
                                                              has a prettier
                                                              binary)
  .py                                            →  Black     (if nearest
                                                              pyproject.toml
                                                              declares
                                                              [tool.black])
  .go                                            →  gofmt    (if nearest
                                                              go.mod)
  .rs                                            →  rustfmt  (if nearest
                                                              Cargo.toml)

Silent skip when a project doesn't have a formatter configured — the hook
doesn't impose a style on projects that haven't asked for one. Hand-edit
~/.claude/settings.json later to remove.
```

Then `AskUserQuestion`:
- **Question:** "Turn on auto-format after edits?"
- **Header:** `Format`
- **Option A:** **Yes — turn it on**
- **Option B:** **Not now**

### Writing the hook(s)

Collect both answers, then write once. If both are "Not now" → skip silently, no settings.json touch.

**Case A — no `PostToolUse` block exists in settings.json** (the default state shipped by the spine). Use `Edit` to insert the new block. Match this exact slice of the current file:

````
  "hooks": {
    "PreToolUse":
````

Replace with the slice below, **dropping the typecheck object if G1 = Not now, and dropping the format object if G2 = Not now** (preserve trailing commas correctly — the array contents adjust):

````
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "${HOME}/.claude/hooks/typecheck-after-edit.sh",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "${HOME}/.claude/hooks/format-on-save.sh",
            "timeout": 15
          }
        ]
      }
    ],
    "PreToolUse":
````

If the `Edit` doesn't match (user reformatted settings.json, removed PreToolUse, etc.) → abort the write and fall to **Hand-edit fallback**. Do not retry with broader matching.

**Case B — `PostToolUse` already exists with matcher `Edit|Write|MultiEdit` containing exactly one of the two spine-named scripts** (e.g., format was opted in last run; typecheck is being added now). Don't try to surgically insert mid-array — emit the **Hand-edit fallback** for the missing hook.

**Case C — any other shape.** Hand-edit fallback.

### Hand-edit fallback

Print this exact block (substituting the hook script name and timeout the user opted into):

```
Your ~/.claude/settings.json already has a PostToolUse hooks block I can't
safely modify in-place. To add the hook you accepted, append the following
entry to the existing matcher's `hooks` array, then restart Claude Code:

  {
    "type": "command",
    "command": "${HOME}/.claude/hooks/<script>",
    "timeout": <timeout>
  }

Scripts + timeouts:
  typecheck-after-edit.sh   timeout 30
  format-on-save.sh         timeout 15
```

The skill does not attempt any further write after printing this — the user is now in the loop.

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
  • Opt-in hooks: [auto-typecheck + auto-format on | auto-typecheck on |
    auto-format on | declined both | already configured — left alone |
    not offered (essentials-only)].  `/hooks` lists what fires this session.
  • Deep profile: [completed | skipped — run `/onboard --deep` when you want
    to capture stack details, signal preferences, output format, risk
    tolerance, plus two opt-in hooks (auto-typecheck, auto-format) — 13
    personal questions + 2 hook prompts, ~5 min].

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
