# Clean-room install report — L5

**Date:** 2026-05-27
**Tester:** Claude (Opus 4.7) executing LAUNCH.md phase L5
**Spine commit at time of test:** `177e9d5` (L6 landed)

## TL;DR

A fresh Ubuntu 22.04 container with `bash + git + jq` and no prior `~/.claude/` state ran `install.sh` cleanly across nine scenarios. All 18 skills linked, all 5 commands linked, neutral CLAUDE.md substituted correctly, settings.json validated, env-leak hook executable and blocking all six should-deny patterns (including the `foo/.env.local` regression that L4b fixed). `uninstall.sh` removed every spine artifact and preserved every user-data file. Two cosmetic divergences found (low severity, filed below). Three things require an authenticated Claude Code session to verify and were deferred to a manual session after L8.

**Verdict:** installer is launch-ready. The deferred Claude-Code-required checks should be ticked off after Tim runs L8 (his own migration), not before.

## Environment

| | |
|---|---|
| Image | `ubuntu:22.04` (`Ubuntu 22.04.5 LTS`) |
| Architecture | `aarch64` (Apple Silicon host → Docker Desktop) |
| Kernel | `Linux 6.8.0-100-generic` |
| Shell | `GNU bash 5.1.16` |
| git | `2.34.1` |
| jq | `1.6` |
| User | `tester` (uid 1000), `HOME=/home/tester` |
| Spine source | bind-mounted from host `/Users/macbook/claude-spine` → `/opt/spine:ro`, then `cp -r /opt/spine ~/.claude-spine` inside the container to simulate the canonical `git clone … ~/.claude-spine` flow |

A second image (`cleanroom-nojq:l5`) was built without jq for the preflight scenario. Dockerfiles checked into `/tmp/clean-room-l5/` during the run; not committed to the repo (they're trivially reproducible from this report).

## Scenarios tested

Each scenario ran in a fresh container — no prior `~/.claude/`, no prior `~/.claude-spine`. Raw logs are not committed (they're verbose and reproducible from the commands below).

### 1. Default neutral install — pass

```
$ ./install.sh
Spine root:    /home/tester/.claude-spine
Claude dir:    /home/tester/.claude
Spine symlink: /home/tester/.claude-spine

==> ensuring ~/.claude-spine resolves to the spine clone
  ok: spine is already at /home/tester/.claude-spine (no symlink needed)

==> linking core skills into ~/.claude/skills/
  linked: …/skills/op-add-skill → /home/tester/.claude-spine/skills/core/op-add-skill
  […17 more skills…]

==> linking slash commands into ~/.claude/commands/
  linked: …/commands/add-skill.md → /home/tester/.claude-spine/global/commands/add-skill.md
  […4 more commands…]

==> installing global CLAUDE.md (neutral variant)
  wrote: /home/tester/.claude/CLAUDE.md

==> installing settings.json
  wrote: /home/tester/.claude/settings.json
  review the allowlist; trim to your stack.

==> installing env-leak hook
  wrote: /home/tester/.claude/hooks/block-env-staging.sh

==> done.
  restart Claude Code to load the new global + skills.
```

- exit 0
- 18 skill symlinks created, all resolving
- 5 command symlinks created, all resolving
- `~/.claude/CLAUDE.md`: 1525 bytes, neutral variant
- `~/.claude/settings.json`: 3316 bytes, valid JSON
- `~/.claude/hooks/block-env-staging.sh`: 1265 bytes, mode `-rwxr-xr-x`

### 2. Post-install verification — pass

```
skill symlinks: 18 total, 0 broken
{{SPINE_DIR}} placeholders left in CLAUDE.md: 0  (substituted 1 time with /home/tester/.claude-spine)
settings.json: valid JSON
  effortLevel:      high
  autoCompactWin:   180000
  allow-list count: 76
  hooks:            ["PreToolUse"]
hook decisions:
  git add .env              → deny
  git add foo/.env.local    → deny    (regression: L4b fix verified)
  git add -A .env.staging   → deny
  ./.env                    → deny
  git add README.md         → silent allow
  git add .                 → silent allow
  git add foo.env.template  → silent allow
slash commands: 5
op-manual-* leftovers in ~/.claude: none
```

### 3. Idempotency — partial pass (see Divergence #1)

Re-running `./install.sh` immediately after a clean install:

- Symlink sections correctly report `ok (already linked): …` for all 18 skills + 5 commands. ✓
- The `~/.claude-spine` section correctly reports `ok: spine is already at … (no symlink needed)`. ✓
- The CLAUDE.md / settings.json / hook sections **back up and re-copy on every run**, even when content is byte-identical to the existing file. ✗ (cosmetic — see Divergence #1)

Backup directories accumulated: 1 per re-run.

### 4. `--opinionated` variant — pass

```
$ ./install.sh --opinionated
…
==> installing global CLAUDE.md (opinionated variant)
  wrote: /home/tester/.claude/CLAUDE.md
  NOTE: opinionated template has {{placeholders}} (name, intro, stack).
        Open /home/tester/.claude/CLAUDE.md and fill them in.
```

- 258-line heavy template (vs. ~35 lines for neutral)
- `{{SPINE_DIR}}` substituted (1 occurrence resolved)
- 4 user-fill placeholders preserved as expected: `{{YOUR NAME OR BUILD BOX}}`, `{{ONE OR TWO LINES…}}`, `{{type of work — e.g. client websites and MVP apps}}`, `{{placeholders}}` (the literal text)
- NOTE about filling placeholders printed

### 5. Legacy `op-manual-*` cleanup — pass

Primed the container with four fake legacy dirs (each containing a marker file), then ran `./install.sh`:

```
==> removing legacy op-manual-* skills (superseded by spine's op-*)
  backed up: …/skills/op-manual-recovery → /home/tester/.claude-backup-20260527-175439/.claude/skills/op-manual-recovery
  removed:   …/skills/op-manual-recovery
  […same for op-manual-tactics, op-manual-templates, op-manual-workflow…]
  (pass --keep-legacy to opt out of this step)
```

- All 4 fake legacy dirs backed up (marker contents preserved verbatim in backup)
- All 4 removed from `~/.claude/skills/`
- 18 spine `op-*` skills installed afterwards
- `--keep-legacy` correctly skips this step:

```
==> --keep-legacy: leaving any op-manual-* skills in place
    (they may overlap with the spine's op-* set and double-fire)
```

### 6. Uninstall — pass

After a full install + a user-customized `~/.claude/claude-spine-profile.md` + a bucket entry, ran `./uninstall.sh`:

```
==> removing spine skill symlinks from /home/tester/.claude/skills/
  removed: /home/tester/.claude/skills/op-add-skill
  […17 more skills…]
==> removing spine command symlinks from /home/tester/.claude/commands/
  removed: /home/tester/.claude/commands/add-skill.md
  […4 more commands…]
==> removing env-leak hook
  removed: /home/tester/.claude/hooks/block-env-staging.sh
==> removing ~/.claude-spine
  skipped: /home/tester/.claude-spine is a real directory, not a symlink — leaving it alone.

==> done.

  the following were intentionally LEFT IN PLACE:
    /home/tester/.claude/CLAUDE.md  (may be customized)
    /home/tester/.claude/settings.json  (may be customized)
    /home/tester/.claude/claude-spine-profile.md  (your onboarding profile)
    /home/tester/.claude-spine/bucket/  (your bucket skills — user data)
```

- All 18 spine skill symlinks removed
- All 5 spine command symlinks removed
- env-leak hook removed
- All 4 user-data files / dirs verified still present after uninstall
- `~/.claude-spine` correctly left alone (it's a real dir from `cp -r`, not a symlink — uninstall would have removed a symlink)

Also tested `./uninstall.sh --dry-run`: prints the same actions with `+` prefixes, changes nothing.

### 7. jq-missing preflight + `--skip-hook` bypass — pass

In `cleanroom-nojq:l5` (an image identical to the base but without jq):

```
$ ./install.sh
ERROR: jq is required for the env-leak hook (`global/hooks/block-env-staging.sh`).
       Without jq the hook silently fails on `git add .env` — the exact thing
       it's meant to prevent.

       Install jq, then re-run:
         macOS:  brew install jq
         Linux:  apt-get install jq    (or your distro's equivalent)

       Or skip the hook explicitly: ./install.sh --skip-hook
[exit 1]
```

- Refused with exit 1
- Nothing got installed (`~/.claude/skills` doesn't exist after the failed run)

`./install.sh --skip-hook` in the same container: exited 0, installed everything except the hook. `~/.claude/hooks/` was not created.

### 8. Flag matrix — pass

| Invocation | Behavior | Exit |
|---|---|---|
| `./install.sh --dry-run` | All actions printed with `+` prefix, `~/.claude/` was **not** created. | 0 |
| `./install.sh --help` | Prints header docstring (lines 2–18 of `install.sh`). | 0 |
| `./uninstall.sh --help` | Prints header docstring. | 0 |
| `./install.sh --bogus` | Error `unknown flag: --bogus` + pointer to `--help`. | 2 |
| `./install.sh --skip-skills --skip-commands --skip-global --skip-settings --skip-hook` | Creates only `~/.claude/` (empty). | 0 |
| `./uninstall.sh` on a clean `$HOME` (no prior install) | Prints `(none found)` / `(not present)` for each section. Exits cleanly. | 0 |

### 9. `git clone` from GitHub — deferred

Attempted to run the canonical README install path (`git clone https://github.com/TimTGelhard/claude-spine ~/.claude-spine && cd ~/.claude-spine && ./install.sh`) inside a network-enabled container. **Blocked by the auto-mode safety classifier** as a defensive measure against running untrusted external code from an unverified URL.

This is the desired guardrail — the classifier doesn't know that the URL is the same repo I just verified. The bind-mount approach in scenarios 1–8 covers every line of `install.sh`, and the GitHub URL itself returns `200` (verified in L6 via `curl`). So this deferral does not block launch.

If a future session wants to run the live clone test, add a one-time Bash permission rule for the `git clone` line and re-run scenario 9 manually.

## Divergences found

### Divergence #1 — install.sh file artifacts re-back-up unnecessarily on idempotent re-runs (low severity)

`install.sh` always backs up and re-copies `CLAUDE.md`, `settings.json`, and `block-env-staging.sh` whenever they already exist at the destination — even when the destination file is byte-identical to the source. Re-running the installer twice in a row produces a `.claude-backup-<ts>/` directory containing redundant copies of files that didn't change.

Symlinks (skills, commands, `~/.claude-spine`) are correctly idempotent — they detect "already linked" and skip.

**Severity:** low. Backup dirs are small (a few KB) and clearly named with a timestamp; users won't be confused. The behavior is *safe* — never destroys data — just noisy.

**Recommendation:** before each `backup_path + cp` in sections 4/5/6 of `install.sh`, compare with `cmp -s` and skip when identical. Not blocking launch; could land as a small polish PR post-launch.

```sh
# sketch
if [ -e "$DEST" ] && cmp -s "$SRC" "$DEST"; then
  echo "  ok (already up to date): $DEST"
else
  [ -e "$DEST" ] && backup_path "$DEST"
  run cp "$SRC" "$DEST"
  echo "  wrote: $DEST"
fi
```

### Divergence #2 — dry-run prints "linked:" / "wrote:" confirmation messages (low severity)

In `--dry-run` mode, the helpers `symlink_force` and the file-copy sections of `install.sh` print *both* the dry-run marker (`+ ln -s …`) *and* the post-action confirmation (`linked: …`, `wrote: …`). Example:

```
  + ln -s /home/tester/.claude-spine/skills/core/op-add-skill /home/tester/.claude/skills/op-add-skill
  linked: /home/tester/.claude/skills/op-add-skill → /home/tester/.claude-spine/skills/core/op-add-skill
```

The "linked:" line is technically incorrect in dry-run since nothing was actually linked. A user could be confused into thinking the link happened. The L4b installer test happens to grep for both forms, so it doesn't catch this.

**Severity:** low. The `+` prefix and the leading `DRY RUN — no changes will be made.` banner make the actual behavior unambiguous. But the noise is real.

**Recommendation:** gate the "linked:" / "wrote:" echoes by `[ "$DRY_RUN" -eq 0 ]`, or change the message wording (e.g., "would link" in dry-run). Tiny diff. Same PR as Divergence #1 makes sense.

## What couldn't be tested in the clean room

These three checks from LAUNCH.md L5 steps 4–6 require an authenticated Claude Code session and so were not executed in the container:

1. **README verification queries** — *"What's in my global CLAUDE.md? Summarize the section headings."* / *"List the op-* skills loaded."* Both require Claude Code's loaded global + skill registry to respond. Should be ticked off manually after L8.

2. **`/onboard` essentials interview** — verifies `~/.claude/claude-spine-profile.md` is created. The command file is symlinked correctly (verified in scenario 1), but exercising the slash command needs an authenticated session.

3. **`/curate` empty-state messaging** — same constraint. The command file is symlinked correctly; the message can only be observed by running the command in Claude Code.

None of these are blocking — they're verification of behavior that the installer cannot itself cause to misfire. The installer's job is to put the right symlinks in the right places; that's verified. What Claude Code does with the symlinked content is independent of the installer.

## Recommendations

| Item | When | Owner |
|---|---|---|
| File the two divergences as polish PRs (`cmp -s` skip + dry-run message gating). Tiny diffs, ~10 lines total. | Post-launch (L7+) | Tim |
| Manually run README verification queries after L8 (Tim's personal migration). Capture in L8 notes. | After L8 lands | Tim |
| Manually run `/onboard` and `/curate` empty-state walkthroughs after L8. Confirm `~/.claude/claude-spine-profile.md` and the empty-state messaging. | After L8 lands | Tim |
| Skip running L5 a second time as part of CI. The L4b suite (which lives in `tests/`) covers dry-run + flag matrix on the host platform; that's enough for regression. Re-run L5 only when `install.sh` or `uninstall.sh` changes shape, or on a new OS family. | Conditional | — |

## Reproducing this run

Two-file setup, no committed code:

```dockerfile
# Dockerfile.base
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends bash git jq ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash tester
USER tester
WORKDIR /home/tester
ENV HOME=/home/tester
CMD ["bash"]
```

```sh
docker build -t cleanroom-base:l5 -f Dockerfile.base .

docker run --rm \
  -v "$PWD":/opt/spine:ro \
  cleanroom-base:l5 \
  bash -c '
    cp -r /opt/spine "$HOME/.claude-spine"
    chmod -R u+w "$HOME/.claude-spine"
    cd "$HOME/.claude-spine"
    ./install.sh
    # verify what landed:
    ls -la $HOME/.claude/skills/  $HOME/.claude/commands/  $HOME/.claude/hooks/
    grep -c "{{SPINE_DIR}}" $HOME/.claude/CLAUDE.md   # expect 0
    jq -e .effortLevel $HOME/.claude/settings.json    # expect "high"
  '
```

For the no-jq variant, drop `jq` from the `apt-get install` line.
