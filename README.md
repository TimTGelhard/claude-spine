# claude-spine

> The spine of every Claude Code project. Installable toolbox of skills, atomic operating-discipline chapters, project templates, and a profile-driven personalization layer that calibrates Claude to *you*.

For people already running real Claude Code sessions on real projects who want their workflow to stop leaking quality. Not a tutorial — a discipline manual + an installable harness that wires it into `~/.claude/`.

> **Status: v2 reconstruction in progress.** Phases 0 through 6c are done — atomized chapters, 14 `op-*` skills, neutral + opinionated globals, `install.sh`, and the `op-onboard` personalization interview all ship. Phase 6.5 (the personal skill-bucket router) is next. See [`RECONSTRUCTION.md`](RECONSTRUCTION.md) for the live phase tracker. The pre-v2 manual (single-file chapters `01-…` through `18-…` at the repo root) is still the authoritative source until every phase atomizes it.

---

## What you get

- **14 `op-*` skills** that load only when relevant. Each one is a router that points Claude at the atomic chapter for the question — never the whole folder. See `skills/core/`.
- **~70 atomic chapters** (<150 lines each), one concept per file, organized by topic (foundations, workflow, prompting, signaling, persistence, tools, subagents, recovery, anti-patterns). Indexed by [`INDEX.md`](INDEX.md).
- **Personalization** — first-run interview captures your experience, stack, working style, push-back intensity, verbosity, and risk tolerance into `~/.claude/claude-spine-profile.md`. Claude reads it every session.
- **Empty personal-skill bucket** (`skills/bucket/`). Ships empty by design — each user grows their own library over time. No pre-seeded "popular skills" trap.
- **Templates** (`templates/`) — `PROJECT_BRIEF.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, etc. Copy into each project's `docs/`; Claude maintains them across sessions.
- **Neutral + opinionated global** (`global/`) — pick the thin stub (default) or the heavy founder-flavored template.
- **One-shot installer** (`install.sh`) — symlinks everything into `~/.claude/`, idempotent, dry-runnable, backs up existing files.

---

## Install

```bash
git clone https://github.com/TimTGelhard/claude-spine ~/.claude-spine
cd ~/.claude-spine
./install.sh                  # neutral global stub (recommended default)
./install.sh --opinionated    # heavy, kitchen-sink CLAUDE.md
./install.sh --dry-run        # preview without changing anything
```

Existing `~/.claude/` files are backed up to `~/.claude-backup-<timestamp>/` before being overwritten. Re-running is safe. See [`global/INSTALL.md`](global/INSTALL.md) for all flags, verification queries, and uninstall.

**Requirements:** macOS or Linux (Windows works inside WSL). `bash`, `jq` (for the env-leak hook), `git`.

---

## First session after install

1. **Restart Claude Code** so it picks up the new global, skills, and slash commands.
2. **Run `/onboard`** — the 5-question essentials interview. Takes ~2 minutes. Profile is written to `~/.claude/claude-spine-profile.md`.
3. **Optional:** `/onboard --deep` for the full ~15-question interview (stack details, signal preferences, output format, risk tolerance). Run now or later — Claude offers it at the end of essentials.
4. **Verify:** start a session and ask *"List the op-* skills loaded"* — you should see all 14. Ask *"What's in my global CLAUDE.md?"* — should match the variant you installed.

---

## How it works

claude-spine uses a **stub + spine** architecture:

- `~/.claude/CLAUDE.md` is a thin stub (~25 lines) that points at the spine and the profile. Identity + pointers, nothing more.
- The spine (this repo) holds all the operating discipline as atomic markdown files.
- The 14 `op-*` skills route Claude to the right atomic file *only when needed* — descriptions are the trigger; bodies stay small (~40–50 lines).
- The profile file calibrates which defaults the spine's chapters should apply for *this user*.

Net effect: every session starts lean. Claude loads heavy content on-demand, filtered by your profile. The same machine can serve five projects without polluting any one session with the others' context.

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
├── PERSONALIZATION.md           # Phase 8 plan — self-evolution loop on top of v2
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
│   ├── core/                    # the 14 op-* skills (shipped + maintained)
│   └── bucket/                  # YOUR personal library — ships empty by design
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
- **A skill-sharing platform** — the bucket is *personal*. No fork-and-share community story baked in; if you want to share your skills, that's your problem to solve.
- **A managed product** — claude-spine is a local install. No accounts, no telemetry, no auto-updates. `git pull` is the update mechanism.

---

## Contributing

Single-maintainer, opinionated repo. Issues and small PRs welcome for: factual errors, broken links, outdated Claude Code mechanics, install steps that don't work on a clean machine.

Larger reframes are unlikely to land — this reflects how *one operator* works. Fork freely and shape it to yours.

---

## License

MIT — see [`LICENSE`](LICENSE).
