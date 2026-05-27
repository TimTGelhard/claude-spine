# claude-spine

> The spine of every Claude Code project. Installable toolbox of skills, atomic operating-discipline chapters, project templates, and a profile-driven personalization layer that calibrates Claude to *you*.

For people already running real Claude Code sessions on real projects who want their workflow to stop leaking quality. Not a tutorial — a discipline manual + an installable harness that wires it into `~/.claude/`.

> **Status: v2 shipped; launch assets in flight.** All atomic chapters, the `op-*` skill set (now including the ambient `op-spine-active`), neutral + opinionated globals, `install.sh`, the `/onboard` personalization interview, the full capture/curate bucket loop, and the plan-driven workflow (`/prep` → ambient cold-start → `/done`) are shipped. See [`RECONSTRUCTION.md`](RECONSTRUCTION.md) for the build history and [`LAUNCH.md`](LAUNCH.md) for the launch gate tracker. The original 18 single-file chapters at the repo root are deprecated stubs pointing at their v2 atomic versions in `chapters/`.

---

## What you get

- **22 `op-*` skills** (19 task-routers + 3 ambient: cold-start, first-run welcome, curation nudge) that load only when relevant. Each one is a router that points Claude at the atomic chapter for the question — never the whole folder. See `skills/core/`.
- **~80 atomic chapters** (<150 lines each), one concept per file, organized by topic (foundations, workflow, prompting, signaling, persistence, tools, subagents, recovery, anti-patterns). Indexed by [`INDEX.md`](INDEX.md).
- **Personalization layer** — a profile (`/onboard`) that calibrates Claude to you, plus a capture/curate loop that grows your personal bucket as patterns emerge. See [Personalization](#personalization) below.
- **Empty personal bucket** (`bucket/`). Ships empty by design — your skill and chapter library grows one curated addition at a time. No pre-seeded "popular skills" trap.
- **Templates** (`templates/`) — `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, etc. Copy into each project's `docs/`; Claude maintains them across sessions.
- **Neutral + opinionated global** (`global/`) — pick the thin stub (default) or the heavy founder-flavored template.
- **One-shot installer** (`install.sh`) — symlinks everything into `~/.claude/`, idempotent, dry-runnable, backs up existing files.

---

## Quick start

Three commands. Two minutes. You're set up.

```bash
git clone https://github.com/TimTGelhard/claude-spine ~/.claude-spine
cd ~/.claude-spine
./install.sh
```

Then **restart Claude Code**, open any session, and type **`/onboard`** — a 7-question, ~2-minute interview that calibrates Claude to your subscription, your stack, and how you like to work. It writes `~/.claude/claude-spine-profile.md` and ends with a one-screen "here's what's available now" handoff.

After that you can:

- Type **`/spine`** to see everything that's loaded (22 skills, 9 slash commands, ~80 chapters).
- **`cd` into a project** and type **`/prep`** to plan a feature.
- **Just start chatting** — the right skill loads on demand.

That's the full first-run path. The rest of this section is optional.

### Install variants

- `./install.sh --opinionated` — heavy, kitchen-sink CLAUDE.md instead of the neutral stub
- `./install.sh --dry-run` — preview every action without writing anything
- `./install.sh --help` — every flag (`--skip-skills`, `--skip-hook`, `--keep-legacy`, etc.)
- `/onboard --deep` (after essentials) — full ~20-question pass for stack details, signal preferences, output format, risk tolerance

See [`global/INSTALL.md`](global/INSTALL.md) for partial-install flags, the full verification protocol, and uninstall.

### What gets installed and where

The installer symlinks the spine's skills, slash commands, global `CLAUDE.md`, `settings.json`, and safety hooks into `~/.claude/`. Existing files are backed up to `~/.claude-backup-<timestamp>/` before being overwritten — re-running is safe.

### Requirements

macOS or Linux (Windows works inside WSL). `bash`, `jq` (for the env-leak hook), `git`.

---

## Slash commands

Nine commands ship in `global/commands/`:

| Command | What it does |
|---|---|
| `/onboard` | Seven-question essentials interview (≈2 min). Writes `~/.claude/claude-spine-profile.md`. `--deep` for the full ~20-question pass. |
| `/prep` | Planning pass for a new project or major new section. Step 0 auto-runs `init.sh` if `docs/` doesn't exist; then brief → architecture → first section plan. No code this session. |
| `/done` | Close the active build session. Walks verify list, rolls up Stop-hook heartbeats, updates plan + `PROGRESS.md`, stages doc changes, suggests a commit message. The writeback command. |
| `/suggest` | Capture a high-signal moment to `bucket/SUGGESTIONS.md`. Locked four-condition trigger. |
| `/curate` | Review pending suggestions one-at-a-time; propose diff; apply on explicit approval. `--review-stale` walks old entries. |
| `/add-skill` | Gated skill-creation for the personal bucket (3+-paste-in rule). |
| `/refresh-bucket` | Rebuild `bucket/INDEX.md` from disk after manual file drops. |
| `/spine` | One-shot discovery — prints the active op-* skills, slash commands, profile path, and INDEX locations. Read-only. |
| `/hooks` | One-shot listing of every configured hook (event, matcher, script). Reads `~/.claude/settings.json` + any project-level `.claude/settings.json`. Read-only. |

The plan-driven flow is `/prep` → (open Claude; `op-spine-active` auto-loads scope) → build → `/done` ([chapters/workflow/05h–05j](chapters/workflow/05h-multi-session-planning.md)); a Stop hook (`spine-writeback.sh`) logs per-turn heartbeats in between. For safety-critical sessions wanting a code-gate, use Claude Code's built-in plan mode (Shift+Tab Tab). `/onboard`, `/suggest`, `/curate`, `/add-skill`, `/refresh-bucket` carry personalization ([chapters/personalization/19a–19e](chapters/personalization/19a-overview.md)).

---

## How it works

claude-spine uses a **stub + spine** architecture:

- `~/.claude/CLAUDE.md` is a thin stub (~25 lines) that points at the spine and the profile. Identity + pointers, nothing more.
- The spine (this repo) holds all the operating discipline as atomic markdown files.
- The 22 `op-*` skills route Claude to the right atomic file *only when needed* — descriptions are the trigger; bodies stay small (~40–60 lines). Skills with a longer procedure (e.g. `op-prepare`, `op-curate`) split into a router `SKILL.md` + adjacent procedure file.
- The profile file calibrates which defaults the spine's chapters should apply for *this user*.

Net effect: every session starts lean. Claude loads heavy content on-demand, filtered by your profile. The same machine can serve five projects without polluting any one session with the others' context.

---

## Personalization

Two layers sit on top of the static spine:

- **Profile** (`~/.claude/claude-spine-profile.md`) — written by `/onboard`. Captures who you are: subscription, experience level, primary stack, push-back intensity, answer length, reasoning depth, project type. Loaded every session via the global stub. Claude treats a senior backend engineer differently from a CS student.
- **Bucket loop** (`bucket/`) — your personal skill and chapter library. Three slash commands wire it:
  - During normal work, `op-suggest` captures high-signal moments (explicit user signal, 2+ same friction, end-of-session reflection, or `/suggest`) to `bucket/SUGGESTIONS.md`. One-line append, no task interruption.
  - `/curate` walks pending entries one at a time, reads existing bucket files to surface overlap, proposes a diff, applies on your explicit approval. Files land under `bucket/skills/` or `bucket/chapters/`; `bucket/INDEX.md` and `bucket/CHANGELOG.md` update mechanically. `/curate --review-stale` walks old entries for prune-or-keep.
  - Later sessions: when no core `op-*` skill matches, `op-bucket-router` reads `bucket/INDEX.md` and loads only the matching bucket file. The bucket helps the work without polluting unrelated sessions.

Hard rules: `op-curate` refuses to touch `chapters/` or `skills/core/` — the spine stays read-only per user. Profile updates flow through `/onboard` only; the suggestion loop never edits the profile. `git pull` never touches `bucket/` or your profile — spine upgrades are conflict-free.

Full mechanics: [`chapters/personalization/19a-overview.md`](chapters/personalization/19a-overview.md) → 19b–19e.

---

## Read order (humans)

If you want to read claude-spine, not just install it:

1. **Skim** [`INDEX.md`](INDEX.md) — the router map. See what topics exist.
2. **Read the foundations** — `chapters/foundations/01a-llm-loop.md` → `01b-three-levers.md` → `01c-failure-modes.md`. The mental model the rest builds on.
3. **Skim** `chapters/signaling/11-overview.md` — how Claude should behave as a senior dev who speaks up.
4. **Read** `chapters/workflow/05-overview.md` and `chapters/workflow/06-feature-sizing.md` — the project workflow + the one-feature-per-session rule.
5. **Skim** `chapters/anti-patterns/18-meta-patterns.md` — the cross-catalog list of failure modes.

Then jump to specific atomic files when stuck. INDEX.md tells you which.

---

## What ships in each folder

```
claude-spine/
├── README.md                    # this file
├── INDEX.md                     # router map for all atomic chapters
├── RECONSTRUCTION.md            # v2 reconstruction status (start here if you're a Claude session)
├── EXPLAINER.md                 # background reading on the v1 → v2 thinking
├── install.sh                   # one-shot installer
├── chapters/                    # atomic operating-discipline files
│   ├── foundations/             # how Claude Code actually works
│   ├── workflow/                # how to organize work
│   ├── prompting/               # how to interact
│   ├── signaling/               # proactive senior-dev behavior
│   ├── persistence/             # CLAUDE.md, skills, memory, hooks
│   ├── tools/                   # which Claude Code tool when
│   ├── subagents/               # when to delegate
│   ├── recovery/                # when quality drops mid-session
│   └── anti-patterns/           # explicit "never do this"
├── skills/
│   └── core/                    # the 22 op-* skills (shipped + maintained)
├── bucket/                      # YOUR personal library — ships empty by design
├── templates/                   # per-project docs you copy and adapt
└── global/
    ├── neutral/                 # default: thin stub
    ├── opinionated/             # opt-in: heavy founder-flavored template
    ├── commands/                # slash commands (e.g. /onboard)
    ├── hooks/                   # env-leak hook
    ├── settings.json            # Claude Code settings (allowlist, plugins, hooks)
    └── INSTALL.md               # detailed install + verify + uninstall guide
```

---

## What's NOT in this repo

- **Project-specific code or content** — that lives in your project's `.claude/CLAUDE.md` and `docs/`.
- **Stack-specific framework guidance** — use the relevant plugin skills (Vercel, Next.js, Supabase, Tailwind, shadcn, etc. via `/plugin install`).
- **A skill-sharing platform** — the bucket is *personal* and ships empty by design. There's no community marketplace and there won't be one: bucket entries reference your stack and project paths, sometimes your credential layout, and a public catalog invites the speculative-library trap ([chapter 13d](chapters/persistence/13d-skill-anti-patterns.md)) — collecting skills you'd never actually fire. This is your toolbox, not your subreddit. Fork the repo and shape your own; upstream PRs to `chapters/` or `skills/core/` are how patterns become universal.
- **A managed product** — claude-spine is a local install. No accounts, no telemetry, no auto-updates. `git pull` is the update mechanism.

---

## Running the tests

Two test suites live under `tests/`:

**Fast suite** (deterministic, offline, runs in CI on every push):

```bash
./tests/run.sh
```

Covers the env-leak hook (`global/hooks/block-env-staging.sh` — assert deny/allow on the Claude Code hook JSON protocol) and `install.sh --dry-run` (assert every documented section and flag combination fires correctly). Requires `bash` + `jq`. CI runs this on push to `main` and pull requests — see [`.github/workflows/test.yml`](.github/workflows/test.yml).

**Skill-trigger benchmarks** (paid, manual, run before editing any `op-*` frontmatter):

```bash
cd tests/skill-triggers
./run.sh                       # all 22 skills, ~5–10 min wall time, ~$5–10 (Sonnet)
./run.sh op-anti-patterns      # one skill
python3 aggregate.py           # writes results/REPORT.md and needs-tightening.md
```

Requires the `skill-creator` plugin and Python 3.10+ (falls back to `uv run --python 3.12` automatically). Not run in CI — costs real API spend, and has known structural bias for routing-style skills. See [`tests/skill-triggers/README.md`](tests/skill-triggers/README.md) for the full doc and caveats (the eval undercounts real-world triggering; the harness is most reliable for false-positive rates).

**Token-efficiency benchmark** (paid, manual, run before a release tag):

```bash
cd benchmarks/tokens
./run.sh                       # 19 prompts × 3 runs × 2 conditions = 114 calls, ~$9–$15 (Sonnet)
python3 aggregate.py           # writes REPORT.md
```

Measures the per-call input cost of having the spine installed vs not. For each prompt, runs `claude -p` once with the spine installed and once with `~/.claude/CLAUDE.md` stubbed + `~/.claude/skills/op-*` stashed, then compares `usage` tokens and `total_cost_usd`. Requires the `claude` CLI authenticated, `jq`, and Python 3.10+. Not run in CI — costs real API spend and runs in minutes, not seconds. See [`benchmarks/tokens/README.md`](benchmarks/tokens/README.md) for the eval-set, cost detail, and the "what this doesn't measure" caveats (single-shot undercount vs. multi-turn amortization; cache_creation vs cache_read interpretation).

---

## Contributing

Single-maintainer, opinionated repo. Issues and small PRs welcome for: factual errors, broken links, outdated Claude Code mechanics, install steps that don't work on a clean machine.

Larger reframes are unlikely to land — this reflects how *one operator* works. Fork freely and shape it to yours. Details in [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

## License

MIT — see [`LICENSE`](LICENSE).
