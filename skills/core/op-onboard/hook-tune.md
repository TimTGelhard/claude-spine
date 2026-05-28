# Hook tuning (deep mode only)

Loaded on-demand from `op-onboard/SKILL.md`'s step 7 (only when the deep interview just completed). Skipped on essentials-only runs.

After the deep interview is saved (and the optional `## Notes` follow-up captured), propose two opt-in PostToolUse hooks that the spine ships but defaults off: **`typecheck-after-edit`** and **`format-on-save`**. Both scripts live at `~/.claude/hooks/<name>.sh` after `install.sh` runs; the gate is whether `settings.json` references them.

This pass mirrors the subscription tune: read `settings.json` → per-hook explanation block → `AskUserQuestion` → `jq`-based mutation on Apply, with a fail-fast hand-edit fallback when the existing `PostToolUse` block contains foreign entries the skill doesn't own.

## When this runs

Only when the deep interview completed in this run. Essentials-only runs skip this section entirely — hooks are a deep-tier opt-in on purpose (the user should understand what a hook is before accepting one). On a re-run that revisits only deep, this still runs.

## Per-hook pre-flight

For each of the two hooks, before asking:

1. **Read `~/.claude/settings.json`.** If the file is missing → skip the entire Hook tuning section silently (no install, nothing to write into).
2. **Check whether the hook is already wired.** Grep the file for the literal command path (`${HOME}/.claude/hooks/typecheck-after-edit.sh` or `${HOME}/.claude/hooks/format-on-save.sh`). If present → skip *this* hook silently (no question, no diff — already opted in).
3. **Check the surrounding `PostToolUse` shape.** If `PostToolUse` is present and the only matcher uses `Edit|Write|MultiEdit` with hooks limited to the two spine-named scripts → the shape is *owned* by this skill and a jq merge is safe. If `PostToolUse` is absent → also safe. Any other shape (foreign matcher, foreign hook entries, multiple matchers, hand-tuned timeouts) → emit the **Hand-edit fallback** for any not-yet-installed hook the user wants, and do NOT run the jq merge.

Only proceed to the question + merge path when the hook is absent AND the surrounding `PostToolUse` block is in a shape this skill owns (no `PostToolUse` block at all, OR `PostToolUse` containing only the spine-named scripts).

## Question G1 — Auto-typecheck after edits

Print this plain-English block first (as a normal text message, not inside `AskUserQuestion`):

```
Optional: auto-typecheck after each edit. After I edit a recognized source
file, this runs your project's type-checker against the nearest config and
surfaces any errors mentioning the edited file.

Languages covered: TypeScript (tsc), Python (mypy → pyright → ruff → py_compile),
Go (`go vet`), Rust (`cargo check`), Ruby (`ruby -wc`), PHP (`php -l`), C#
(`dotnet build`). Silent skip on languages with no checker available.

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

  .ts .tsx .js .jsx .json .md .css .html .yaml  →  Prettier
  .py                                            →  Black (if [tool.black] in
                                                            pyproject.toml)
  .go                                            →  gofmt
  .rs                                            →  rustfmt
  .rb / .php / .java / .kt / .swift / .cs       →  language-native formatter
  .sh / .lua / .ex .exs / .c .cpp .h            →  shfmt / stylua / mix format
                                                    / clang-format

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

Collect both answers, then write once. If both are "Not now" → skip silently, no settings.json touch. Otherwise build the desired PostToolUse block from the accepted hooks and let `jq` set the key.

**Step 1 — sanity check.** If the pre-flight in the previous section already flagged the PostToolUse shape as not-owned, jump straight to **Hand-edit fallback** for the hook(s) the user accepted. Do not run the merge.

**Step 2 — build the desired hooks array.** Two possible objects, both with the canonical timeout values; include only the ones the user accepted (and any spine-named hook *already wired*, so an existing Apply doesn't get clobbered):

```jsonc
// typecheck (G1=Yes OR already wired)
{
  "type": "command",
  "command": "${HOME}/.claude/hooks/typecheck-after-edit.sh",
  "timeout": 30
}

// format (G2=Yes OR already wired)
{
  "type": "command",
  "command": "${HOME}/.claude/hooks/format-on-save.sh",
  "timeout": 15
}
```

**Step 3 — run the merge.** Via the `Bash` tool. The hooks-array JSON is composed in the shell from the two accepted entries; the `jq` call sets `.hooks.PostToolUse` to the canonical wrapper around it.

```bash
set -euo pipefail
SETTINGS="$HOME/.claude/settings.json"
TMP="$SETTINGS.spine-hooks.tmp"

# $HOOKS_JSON is a JSON array literal built from the accepted hooks, e.g.:
#   '[{"type":"command","command":"${HOME}/.claude/hooks/typecheck-after-edit.sh","timeout":30}]'
# Use a single-quoted heredoc / variable so ${HOME} stays literal in the JSON
# (Claude Code expands ${HOME} at hook-run time; settings.json stores the literal).

jq empty "$SETTINGS" >/dev/null

jq --argjson hooks "$HOOKS_JSON" '
  .hooks.PostToolUse = [
    {
      "matcher": "Edit|Write|MultiEdit",
      "hooks": $hooks
    }
  ]
' "$SETTINGS" > "$TMP"

jq empty "$TMP" >/dev/null
mv "$TMP" "$SETTINGS"
```

If the Bash invocation exits non-zero at any point → emit the **Hand-edit fallback** below for the accepted hooks. Do not partial-apply.

## Hand-edit fallback

Print this exact block (substituting the hook script name and timeout the user opted into):

```
Your ~/.claude/settings.json already has a PostToolUse hooks block I can't
safely modify in-place (foreign hooks I don't own, or jq returned non-zero).
To add the hook you accepted, append the following entry to the existing
matcher's `hooks` array, then restart Claude Code:

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
