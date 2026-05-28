# settings-extras — drop-in fragments for `~/.claude/settings.json`

Optional JSON fragments that add stack-specific or platform-specific allowlist entries to `~/.claude/settings.json`. The neutral default ships with broad coverage already (Bash + WebFetch were broadened in the 2026-05 bias-audit round to cover ~10 ecosystems). These fragments add the **next layer** — third-party CLIs, provider-specific subcommands, and docs domains that don't ship in the default.

You only need one of these if you're hitting permission prompts for a tool you use routinely.

## How to merge a fragment

Each `+<name>.json` file in this directory is a partial settings.json — the keys it contains should be merged into your live `~/.claude/settings.json` under the matching key path.

**By hand (the safest path):**

1. Open the fragment in this directory (e.g. `+vcs-gitlab.json`).
2. Open `~/.claude/settings.json` in your editor.
3. For each top-level key in the fragment (usually `permissions.allow` and / or `permissions.WebFetch`), append the array entries to the same array in your settings file. Don't overwrite — extend.
4. Save. Restart Claude Code so the harness reloads.

**With `jq` (faster, error-prone if you have hand-edits):**

```bash
# Merge +vcs-gitlab.json into ~/.claude/settings.json — appends allow + WebFetch entries.
jq -s '
  .[0] as $base
  | .[1] as $extra
  | $base
  | .permissions.allow = ((.permissions.allow // []) + ($extra.permissions.allow // []) | unique)
  | .permissions.WebFetch = ((.permissions.WebFetch // []) + ($extra.permissions.WebFetch // []) | unique)
' ~/.claude/settings.json ~/.claude-spine/global/settings-extras/+vcs-gitlab.json \
  > ~/.claude/settings.json.tmp \
  && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

Back up `~/.claude/settings.json` first; the `jq` path overwrites in place.

## Fragments shipped

| File | When to merge |
|---|---|
| `+vcs-gitlab.json` | You push to GitLab. Adds `Bash(glab:*)` patterns + GitLab docs WebFetch. |
| `+vcs-bitbucket.json` | You push to Bitbucket. Adds `Bash(bb:*)` (Atlassian CLI) + Bitbucket docs WebFetch. |
| `+vercel-stack.json` | You deploy to Vercel. Adds broader `vercel` subcommand patterns + Vercel-platform docs not in defaults. |
| `+supabase-stack.json` | You use Supabase as your backend. Adds broader `supabase` CLI patterns + Supabase-platform docs not in defaults. |
| `+aws-stack.json` | You deploy to AWS. Adds `Bash(aws:*)`, `Bash(eb:*)`, AWS docs + console WebFetch. |
| `+gcp-stack.json` | You deploy to GCP / Firebase. Adds `Bash(gcloud:*)`, `Bash(firebase:*)`, GCP docs WebFetch. |
| `+azure-stack.json` | You deploy to Azure. Adds `Bash(az:*)` patterns + Azure docs WebFetch. |
| `+docker-k8s-stack.json` | You containerize. Adds `docker`, `docker-compose`, `kubectl`, `helm`, `minikube` patterns + Docker Hub / k8s docs. |

The neutral default in `global/settings.json` already covers:

- All major language toolchains (`node`, `npm`, `pnpm`, `python`, `pip`, `pytest`, `cargo`, `go`, `mvn`, `gradle`, `bundle`, `gem`, `composer`, `php`, `dotnet`, `mix`, `swift`, `deno`, `bun`, `make`)
- GitHub CLI (`gh pr view`, `gh issue view`, `gh repo view`, `gh run view`, etc.)
- Documentation domains for the top 10 ecosystems (MDN, docs.python.org, pkg.go.dev, doc.rust-lang.org, rubyonrails.org, laravel.com, learn.microsoft.com, kotlinlang.org, swift.org, etc.)

So you should rarely need more than 1–2 fragments. If you find yourself wanting to grant broad `Bash(*)` patterns for a CLI not listed above, file an issue — that's a candidate for the default allowlist.

## How fragments relate to `op-onboard`

`/onboard --deep` includes a **Settings-extras merge pass** (added 2026-05-28) that detects which fragments match your captured answers and offers to merge them per-fragment with explicit Apply/Skip confirmation:

- **Q8 (VCS host) = GitLab** → proposes `+vcs-gitlab.json`
- **Q8 (VCS host) = Bitbucket** → proposes `+vcs-bitbucket.json`
- **Q3 / B1 / Q9 free-text mentions a known platform** (`vercel`, `supabase`, `aws`, `gcp`/`firebase`/`google cloud`, `azure`, `docker`/`kubernetes`/`k8s`) → proposes the matching `+<platform>-stack.json`

The merge runs the `jq` command shown above against each fragment the user accepts; nothing is touched on Skip. Already-merged fragments are silently dropped from the candidate list, so a re-run of `/onboard --deep` is idempotent.

You can also merge any fragment by hand at any time — the fragments live on disk regardless of whether `op-onboard` ever proposed them. See `~/.claude-spine/skills/core/op-onboard/extras-merge.md` for the full detection + merge flow.

## Rules

- **Never silent-merge.** Explicit user action required — either an Apply prompt inside `/onboard --deep`'s extras-merge pass, or a hand-run `jq` command outside it. Never write to `settings.json` without the user having seen a diff and approved.
- **Never overwrite — extend.** Treat `allow` and `WebFetch` as append-only. Deduplicate via `jq` `unique`.
- **One fragment per layer.** A fragment that needs to add Bash + WebFetch entries should keep them in one file, not split across two.
- **No new top-level keys.** Fragments only add to existing key paths (`permissions.allow`, `permissions.WebFetch`). They never introduce `hooks`, `model`, `theme`, `enabledPlugins`, etc. — those are user-territory and belong to other passes (or stay user-only).
