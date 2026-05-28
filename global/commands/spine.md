---
description: One-shot discovery surface — list the active op-* skills, slash commands, profile path, and INDEX locations for this install of claude-spine.
---

# /spine — show what's loaded

Single-shot discovery. The user has typed `/` and seen the slash-command menu but no surface for the op-* skills or the chapter library. This command prints the full map so they know what's available without grepping the repo.

## What to do

Print one cohesive block in this order. Read from disk every time — never hard-code counts or names, since the user may have added bucket skills or the spine may have grown.

### 1. Profile

Print:

```
Profile: ~/.claude/claude-spine-profile.md
```

Append `✓ exists` or `✗ missing — run /onboard` based on a file check. If missing, that single hint is enough; do not lecture.

### 2. Spine root

Print:

```
Spine:   ~/.claude-spine/   (symlink to the cloned repo)
```

### 3. Slash commands

List every file under `~/.claude-spine/global/commands/*.md`. For each, print `/<name> — <one-line summary>` where the summary is the `description:` frontmatter field. Sort alphabetically.

### 4. op-* skills

List every directory under `~/.claude-spine/skills/core/op-*/`. For each, print `op-<name> — <trigger>` where the trigger is the first sentence (up to the first period) of the skill's `description:` frontmatter field. Sort alphabetically. Count them at the end: *"N op-* skills loaded."*

### 5. Chapters

Print:

```
Chapters: ~/.claude-spine/INDEX.md   (≈N atomic files across foundations / workflow / prompting / signaling / persistence / tools / subagents / recovery / anti-patterns)
```

Substitute `N` by counting `.md` files under `~/.claude-spine/chapters/` (excluding any README or INDEX files).

### 6. Bucket

Print:

```
Bucket:   ~/.claude-spine/bucket/INDEX.md
```

Then on the next line, look at `bucket/INDEX.md` for table rows. If there are entries, print `N bucket skills, M bucket chapters.` If both tables are empty, print `(empty — grows as `op-suggest` captures and `/curate` applies)`.

### 7. Suggestion queue

If `~/.claude-spine/bucket/SUGGESTIONS.md` has pending entries (non-empty "Pending" section), print:

```
Pending suggestions: K (run /curate to review)
```

Otherwise omit this line.

### 8. Parse-error surface

If `docs/.spine-parse-error` exists in the current working directory, print a one-line warning followed by the marker contents indented two spaces:

```
⚠ spine-writeback parse-error in this project — heartbeats are silently no-opping.
  <contents of docs/.spine-parse-error, indented>
```

This is the only line `/spine` is allowed to print that isn't pure inventory — it surfaces a silent failure mode the user otherwise has no way to notice. If the marker file doesn't exist, omit the section entirely.

## Hard rules

1. **Read-only.** This command never writes anything to disk.
2. **No interpretation.** List what's on disk; do not recommend which skill the user should run.
3. **Truncate gracefully.** If a skill description is long, print only the first sentence (stop at the first period or 120 chars).
4. **No noise on top.** No "Here is your spine overview:" preamble. Print the block, stop.
