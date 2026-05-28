# Hook tuning (deep mode only)

Loaded on-demand from `op-onboard/SKILL.md`'s step 7 (only when the deep interview just completed). Skipped on essentials-only runs.

After the deep interview is saved (and the optional `## Notes` follow-up captured), propose two opt-in PostToolUse hooks that the spine ships but defaults off: **`typecheck-after-edit`** and **`format-on-save`**. Both scripts live at `~/.claude/hooks/<name>.sh` after `install.sh` runs; the gate is whether `settings.json` references them.

This pass mirrors the subscription tune: read `settings.json` → per-hook explanation block → `AskUserQuestion` → `Edit`-insert on Apply, with a fail-fast hand-edit fallback when the existing block doesn't match the canonical shape.

## When this runs

Only when the deep interview completed in this run. Essentials-only runs skip this section entirely — hooks are a deep-tier opt-in on purpose (the user should understand what a hook is before accepting one). On a re-run that revisits only deep, this still runs.

## Per-hook pre-flight

For each of the two hooks, before asking:

1. **Read `~/.claude/settings.json`.** If the file is missing → skip the entire Hook tuning section silently (no install, nothing to write into).
2. **Check whether the hook is already wired.** Grep the file for the literal command path (`${HOME}/.claude/hooks/typecheck-after-edit.sh` or `${HOME}/.claude/hooks/format-on-save.sh`). If present → skip *this* hook silently (no question, no diff — already opted in).
3. **Check whether `PostToolUse` exists with a shape we don't own.** If `PostToolUse` is present and its matcher is anything other than `Edit|Write|MultiEdit`, or it contains hooks beyond the two spine-named scripts → emit the **Hand-edit fallback** (below) for any not-yet-installed hook the user wants, and skip Edit. Do not surgically mutate someone else's PostToolUse block.

Only proceed to the question + Edit path when the hook is absent AND the surrounding settings.json is in a shape this skill owns (no `PostToolUse` block at all, OR `PostToolUse` containing only the spine-named scripts).

## Question G1 — Auto-typecheck after edits

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

## Question G2 — Auto-format after edits

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

## Writing the hook(s)

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

## Hand-edit fallback

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
