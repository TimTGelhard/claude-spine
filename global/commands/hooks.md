---
description: One-shot listing of every hook configured in this session — event, matcher, and script path. Read-only.
---

# /hooks — show configured hooks

Single-shot discovery. Lists every hook configured at the user level (`~/.claude/settings.json`) and any project-level (`./.claude/settings.json`). For each hook, prints the event name, the `if` / matcher filter when present, and the script that fires.

## What to do

Read the `hooks` block from each settings file and print one row per hook. Read directly with the Read tool; parse the JSON inline. Do not invent or recommend — list what's on disk.

### 1. User-level hooks

Read `~/.claude/settings.json`.

- If the file is missing, print `~/.claude/settings.json — not found`.
- If it has no `hooks` block (or the block is empty), print `~/.claude/settings.json — no hooks configured`.
- Otherwise, iterate every event → every matcher group → every hook entry, and print one line per hook:

```
<Event>   [matcher / if: <filter>]   →   <command>
```

Examples:

```
PreToolUse   [Bash · if Bash(git add*)]      →   ~/.claude/hooks/block-env-staging.sh
PreToolUse   [Bash · if Bash(git commit*)]   →   ~/.claude/hooks/block-env-commit.sh
Notification                                  →   ~/.claude/hooks/notify-long-task.sh
Stop                                          →   ~/.claude/hooks/spine-writeback.sh
```

If a hook has no `matcher` and no `if`, leave the bracket empty (omit the brackets entirely for cleanliness). Expand `${HOME}` and `~` to the real path so the user sees what actually runs.

Print a heading before the listing:

```
User hooks (~/.claude/settings.json):
```

### 2. Project-level hooks

Look for `./.claude/settings.json` in the current working directory.

- If present and has a `hooks` block, print under heading `Project hooks (./.claude/settings.json):` and repeat the same per-hook format.
- If absent or empty, omit this section entirely.

### 3. Summary count

After both sections, print one line:

```
Total: <N> hook(s) across <E> event(s).
```

(Counts the user level and project level combined.)

## Hard rules

1. **Read-only.** Never write to settings.json. Never propose adding or removing hooks.
2. **No interpretation.** List what's configured; do not explain what each hook does unless the user follows up with a question.
3. **No preamble.** Print the table block, stop. No "Here are your hooks:" header.
4. **Resolve paths.** Replace `${HOME}` and `~` with the actual expanded path so each row points at a real file.
5. **Graceful on missing files.** A missing `~/.claude/settings.json` is a state to report, not an error to raise.

## Sibling commands

- `/spine` — full discovery surface (skills, commands, profile, chapters, bucket). `/hooks` is the narrower view focused on event automation.
