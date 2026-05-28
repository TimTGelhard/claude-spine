# Settings-extras merge (deep mode only)

Loaded on-demand from `op-onboard/SKILL.md`'s step 8 (after the Hook tuning pass, before the handoff). Skipped on essentials-only runs.

This pass proposes opt-in merges of `~/.claude-spine/global/settings-extras/+*.json` fragments into the user's `~/.claude/settings.json` based on Q3 / B1 / Q8 / Q9 answers. The merge uses `jq` — both because it's the robust mutation tool for JSON, and because the fragments append to arrays (`permissions.allow`, `permissions.WebFetch`), not replace scalars. Same Apply/Skip discipline as the subscription and hook tunes — never silent, always explicit.

## When this runs

Only when the deep interview just completed. Essentials-only runs skip silently — extras are a deep-tier opt-in by design. On a re-run that revisits only deep, this still runs and re-checks; fragments already fully merged into `settings.json` are silently skipped (the "already merged" check below).

## Detection — which fragments to suggest

Scan the captured answers in order:

1. **Q8 (VCS host) → at most one VCS fragment.**
   - `GitLab` → `+vcs-gitlab.json`
   - `Bitbucket` → `+vcs-bitbucket.json`
   - `GitHub` / `None — local-only` / `Other (free-text)` → no VCS fragment

2. **Q3 free-text + B1 free-text + B2 free-text → zero or more stack fragments.** Case-insensitive substring match on the free-text the user typed. Be conservative — only the unambiguous keywords below trip a suggestion; do not infer from bucket alone:

   | Keyword (case-insensitive, substring) | Fragment |
   |---|---|
   | `vercel` | `+vercel-stack.json` |
   | `supabase` | `+supabase-stack.json` |
   | `aws`, `amazon web services`, ` ec2`, ` lambda`, ` dynamodb`, ` rds`, ` s3 ` | `+aws-stack.json` |
   | `gcp`, `google cloud`, `firebase`, `cloud run`, `cloud functions` | `+gcp-stack.json` |
   | `azure` | `+azure-stack.json` |
   | `docker`, `kubernetes`, ` k8s`, ` helm`, `containerd`, `docker-compose` | `+docker-k8s-stack.json` |

   The narrow word-boundary fragments (` ec2`, ` lambda`, ` k8s`) avoid false positives on `ec2instanceconnect`, `λambda` jokes, common substrings, etc. Keep the list conservative — a missed suggestion is fine; a wrong one trains distrust.

3. **Deduplicate.** Each fragment is suggested at most once even if multiple keywords match.

4. **Already-merged check.** For each candidate fragment, read `~/.claude/settings.json` and the fragment. Compute the *new entries* the merge would add (set difference: `fragment.permissions.allow \ settings.permissions.allow`, same for `WebFetch`). If both diff sets are empty → drop this candidate silently (already fully merged).

If no fragments remain after detection + dedup + already-merged → emit a single one-line note: `No settings-extras suggested — your live settings.json already covers your stack.` Skip the rest of this section.

## Per-fragment flow

Process the remaining candidates one at a time. For each:

1. **Pre-flight read.** Read `~/.claude/settings.json` and the fragment. If `~/.claude/settings.json` is missing → skip the entire Settings-extras merge section silently (no install, nothing to write into — same fail-safe as the other tunes).

2. **Print a plain-English explanation block** as a normal text message (NOT inside `AskUserQuestion`). Substitute the fragment name + the new-entry counts + a one-line reason for the user's stack:

   ```
   I noticed you mentioned {{matched-keyword}} — there's a drop-in fragment
   at ~/.claude-spine/global/settings-extras/+{{fragment-name}}.json that adds:

     • {{N}} new permissions.allow entries (so I can run {{example-cmd}}
       without re-prompting)
     • {{M}} new permissions.WebFetch entries (so I can fetch
       {{example-domain}} docs)

   Append-only — your existing entries stay as-is. Hand-edit ~/.claude/settings.json
   later to remove anything. Skipping is fine; the fragment will still be there
   if you want to merge it by hand later.
   ```

   Pick a representative `{{example-cmd}}` and `{{example-domain}}` from the fragment so the user sees what's actually being added (e.g. for `+vcs-gitlab.json`: `glab mr view` and `gitlab.com`).

3. **Call `AskUserQuestion`:**
   - **Question:** `Merge +{{fragment-name}}.json into ~/.claude/settings.json?`
   - **Header:** `Extras`
   - **Option A:** **Apply** — runs the `jq` merge below
   - **Option B:** **Skip** — leaves settings.json untouched

4. **On Apply:** run the merge via the `Bash` tool. Substitute `{{fragment-name}}` literally; do not template the whole command from an unverified source:

   ```bash
   set -euo pipefail
   FRAGMENT="$HOME/.claude-spine/global/settings-extras/+{{fragment-name}}.json"
   SETTINGS="$HOME/.claude/settings.json"
   TMP="$SETTINGS.spine-extras.tmp"

   # Sanity-check both files parse as JSON before merging.
   jq empty "$SETTINGS" >/dev/null
   jq empty "$FRAGMENT" >/dev/null

   jq -s '
     .[0] as $base
     | .[1] as $extra
     | $base
     | .permissions.allow    = ((.permissions.allow    // []) + ($extra.permissions.allow    // []) | unique)
     | .permissions.WebFetch = ((.permissions.WebFetch // []) + ($extra.permissions.WebFetch // []) | unique)
   ' "$SETTINGS" "$FRAGMENT" > "$TMP"

   # Verify the output is still valid JSON before moving into place.
   jq empty "$TMP" >/dev/null

   mv "$TMP" "$SETTINGS"
   ```

   If the Bash invocation exits non-zero at any point → emit the **Hand-edit fallback** below for this fragment. Do not retry, do not partial-apply.

5. **On Skip:** note it. Move to the next fragment. The user can always merge by hand later via the command in `settings-extras/README.md`.

## Hand-edit fallback

Print this block (substituting the fragment file path) when the auto-merge fails for any reason (`jq` not on PATH, settings.json malformed, fragment file missing, write blocked):

```
Couldn't auto-merge `+{{fragment-name}}.json` into ~/.claude/settings.json
(jq returned non-zero or the file format wasn't shapeable). To add these
entries by hand:

  1. Open ~/.claude/settings.json in your editor.
  2. Open ~/.claude-spine/global/settings-extras/+{{fragment-name}}.json.
  3. For each entry in the fragment's `permissions.allow` array, append it
     to the same array in your settings file (don't overwrite — extend).
  4. Same for `permissions.WebFetch`.
  5. Save. Restart Claude Code so the harness reloads.

The fragment stays on disk regardless — you can merge it any time. See
~/.claude-spine/global/settings-extras/README.md for a one-shot `jq` command.
```

The skill does not attempt any further write after printing this — the user is now in the loop.

## Rules

- **Never modify entries.** Append-only. Never replace, never reorder, never remove.
- **Only the named fragments.** Only the eight files under `global/settings-extras/`. Never invent or import new ones. Never resolve a user-typed `Other` answer into a fragment path.
- **Only `permissions.allow` and `permissions.WebFetch`.** Never touch any other keys (`hooks`, `model`, `theme`, `enabledPlugins`, env, etc.) — those keys belong to other passes or to the user.
- **Atomic writes.** Always write to `.tmp` first, then `mv`. Never edit settings.json in-place — a failed `jq` invocation otherwise corrupts the live file.
- **One question per fragment.** Don't batch multiple Apply/Skip into one prompt — a user should be able to opt into `+vcs-gitlab.json` and decline `+docker-k8s-stack.json` independently.
- **Fail-fast.** If anything in the merge command exits non-zero → Hand-edit fallback for that fragment only. Never broaden the regex, never retry with a different strategy.
- **Idempotent.** The `unique` step in the `jq` filter dedupes — a user who re-runs `/onboard --deep` after a merge sees the fragment as "already merged" and gets no prompt.
