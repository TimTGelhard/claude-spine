# Claude Code — Advanced Operator's Manual

> **v2 reconstruction in progress.** This manual is being rebuilt into a public Claude Code toolbox — atomized chapters, skill-based routing, personalization, an empty user-contributed skill bucket. Current state: `RECONSTRUCTION.md`. Target architecture: `INDEX.md`. Everything below describes v1, still the authoritative source until each phase lands.

For solo founders, indie hackers, and vibecoders shipping MVPs and client work with Claude Code at high velocity. Not a tutorial — a discipline manual for people already running real sessions for real users, who want their workflow to stop leaking quality.

Read-only for you; loadable by Claude at session start.

The manual is platform reference (principles, mechanics, discipline). The `templates/` folder is the working layer (per-project files Claude fills in and updates). The `global/` folder is an opinionated `~/.claude/` setup you can install in one step.

**Calibrated for:** Opus 4.7 (1M context) + Claude Code with skills, memory, subagents, MCPs.
**Last reviewed:** 2026-05-26.

---

## What this repo is

Three layers, each independently useful:

1. **Manual** (the 18 numbered chapters at the repo root) — how to operate Claude Code well. Stack-agnostic principles, failure modes, and discipline. Read it; reference it.
2. **Templates** (`templates/`) — per-project docs (`CLAUDE.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, …). Copy into a new project's `docs/`; Claude maintains them across sessions.
3. **Global setup** (`global/`) — a curated `~/.claude/CLAUDE.md`, `settings.json`, and env-leak hook. Opinionated for solo-founder / MVP / agency work. Optional — install with `global/INSTALL.md`.

You can use any layer without the others. Most readers will start with the manual.

---

## Install (3 paths)

**Just the manual.** Clone, read, done.
```bash
git clone https://github.com/TimTGelhard/claude-code-operators-manual.git
```

**Manual + templates for a new project.** Clone, then copy templates into each project:
```bash
cp claude-code-operators-manual/templates/*.md path/to/your-project/docs/
```

**Manual + templates + global Claude Code upgrade.** Adds the curated `~/.claude/` config (instructions, permissions, env-leak hook). See [`global/INSTALL.md`](global/INSTALL.md) for the step-by-step.

---

## How to use the manual

### As the reader
- Read it once front-to-back to internalize the model.
- Re-read targeted chapters when stuck (see triage table below).
- Update it (or note "needs update") when Claude Code or Anthropic ship meaningful changes.

### With Claude
At the start of a serious project session, point Claude at it:

> Read `<path-to-this-repo>/01-first-principles.md` and `<path-to-this-repo>/05-workflow.md` for how I expect you to operate. Then orient on this project.

Or — for a more durable solution — reference it from your global or project `CLAUDE.md`:

```markdown
## Advanced workflow reference
For advanced Claude Code workflow, consult <path-to-this-repo>/.
Particularly 01-first-principles.md, 11-proactive-signaling.md, and 18-anti-patterns.md.
```

(The shipped `global/CLAUDE.md.template` already includes this reference — installing it via `global/INSTALL.md` wires it up automatically.)

That way every session starts with Claude aware of this discipline.

---

## The manual (read-only reference)

Organized in six parts. Each chapter applies the three levers (context, scope, verification) to a specific concern.

### Part I — Foundation (understand the medium)

| # | File | Purpose |
|---|------|---------|
| 01 | [first-principles.md](01-first-principles.md) | Mental model — three levers, three failure modes |
| 02 | [context-window-truth.md](02-context-window-truth.md) | What 1M actually buys; when to start fresh |
| 03 | [limits.md](03-limits.md) | What Claude can't do; warning signs |
| 04 | [models-and-economics.md](04-models-and-economics.md) | Opus vs Sonnet vs Haiku; plan mode; weekly limits |

### Part II — Process (how to organize work)

| # | File | Purpose |
|---|------|---------|
| 05 | [workflow.md](05-workflow.md) | The 7-stage project workflow |
| 06 | [feature-sizing.md](06-feature-sizing.md) | One session = one feature; concrete sizing rules |
| 07 | [collaboration-modes.md](07-collaboration-modes.md) | Executor / reviewer / explainer / planner — switching modes deliberately |
| 08 | [brownfield.md](08-brownfield.md) | Working with existing / old / inherited codebases |

### Part III — Communication (how to interact)

| # | File | Purpose |
|---|------|---------|
| 09 | [prompting.md](09-prompting.md) | Prompt structure, good vs bad examples, patterns |
| 10 | [visuals.md](10-visuals.md) | Screenshots, mockups, diagrams |
| 11 | [proactive-signaling.md](11-proactive-signaling.md) | Claude as senior dev — when to speak up unprompted |

### Part IV — Persistence (make Claude smarter over time)

| # | File | Purpose |
|---|------|---------|
| 12 | [skills-memory-claudemd.md](12-skills-memory-claudemd.md) | The three persistence layers compared |
| 13 | [custom-skills.md](13-custom-skills.md) | Writing your own skills — descriptions as triggers |
| 14 | [hooks-and-automation.md](14-hooks-and-automation.md) | settings.json hooks — system-level quality gates |

### Part V — Tactics (specific tools)

| # | File | Purpose |
|---|------|---------|
| 15 | [tool-palette.md](15-tool-palette.md) | Every tool, when to use it, common mistakes |
| 16 | [subagents.md](16-subagents.md) | When to delegate, when not to |

### Part VI — Failure (when things go wrong)

| # | File | Purpose |
|---|------|---------|
| 17 | [recovery-playbook.md](17-recovery-playbook.md) | Diagnosis and recovery moves |
| 18 | [anti-patterns.md](18-anti-patterns.md) | The explicit "never do this" reference |

Read order on first pass: **01 → 11 → 07 → 05 → 04 → 18**, then skim the rest. Re-read targeted chapters when needed.

---

## Templates (working layer)

In [`templates/`](templates/). Copy into each new project. Fill in and update as the project evolves.

Skills and custom subagents are intentionally NOT shipped as a library here. Both are best written per-project when an actual repeated pattern emerges — speculative libraries age fast and pollute context. Use the `skill-creator` plugin (globally available, invoke by asking or `/skill-creator`) to write skills and agents on demand.

| Template | Lives at (in target project) | Updated when |
|----------|------------------------------|--------------|
| `PROJECT_BRIEF.md` | `docs/PROJECT_BRIEF.md` | Stage 0 — once, before code |
| `CLAUDE.md` | project root | Stage 1, then rarely |
| `ARCHITECTURE.md` | `docs/ARCHITECTURE.md` | Stage 2; when topology changes |
| `FEATURES.md` | `docs/FEATURES.md` | End of every session |
| `PROGRESS.md` | `docs/PROGRESS.md` | End of every session |
| `DECISIONS.md` | `docs/DECISIONS.md` | When a non-obvious choice gets made |
| `SMOKE_TESTS.md` | `docs/SMOKE_TESTS.md` | When a critical flow ships or breaks |
| `DEPLOY.md` | `docs/DEPLOY.md` | When deploy process changes |
| `SESSION_STARTER.md` | `docs/SESSION_STARTER.md` | Rarely — when project doc structure changes |

**Manual vs templates — the split:**
- Manual = stack-agnostic principles. Doesn't change per project.
- Templates = stack-aware working files. Get filled in. Evolve with the project.
- Merging them would either pollute the manual with project state, or freeze the templates as documentation.

---

## Triage — find the right chapter when stuck

| Symptom | First chapter to consult |
|---------|--------------------------|
| New project, where do I start? | 05 (workflow) + templates |
| Resuming an old project | 08 (brownfield) + `templates/SESSION_STARTER.md` (Prompt E) |
| Quality dropping mid-session | 02 (context window) + 11 (Claude should have flagged this) |
| Claude contradicting itself | 06 (feature sizing) + 17 (recovery) + 11 (drift signal) |
| Feature won't converge | 06 + 17 |
| Claude hallucinating | 17 (recovery — verify, don't trust) + 11 (uncertainty signaling) |
| Claude is too passive — just executing, not pushing back | 11 (proactive signaling) |
| Stuck on a hard decision | 09 (prompting — challenge me preamble) + 07 (planner mode) |
| Don't understand my own code | 17 (move D — read the diff) |
| Bug shipped to production | 17 (move E — roll back first) |
| Considering a new dependency / pattern | 18 (anti-patterns) |
| Picking which model to use | 04 |
| Want to do something faster | 15 (tool palette) + 04 (fast mode) |
| Want to automate "always run X after editing Y" | 14 (hooks — not CLAUDE.md, not memory) |
| Stuck in executor mode, not getting the most out of Claude | 07 (collaboration modes — try reviewer/planner) |
| Repeatedly pasting the same instructions across sessions | 13 (write a skill) |

---

## Starting a new project (checklist)

1. **Stage 0 — Decide.** Fill in `PROJECT_BRIEF.md` *before* opening Claude Code. Reference 05 if unsure.
2. **Open Claude Code.** Copy the rest of the templates into the project's `docs/` (or root for `CLAUDE.md`).
3. **Stage 1 — Prep.** Use Prompt A from `SESSION_STARTER.md`. Set up stack, env vars, first deploy. No features yet.
4. **Stage 2 — Architect.** Fresh terminal. Use Prompt C. Fill in `ARCHITECTURE.md` thoroughly.
5. **Stage 3 — Build.** One session per feature. Prompt A to open, end-of-session prompt to close.
6. **Stages 4-6.** See 05 for integrate / harden / ship.

---

## Resuming an old project (checklist)

1. Read chapter 08 (brownfield) before doing anything.
2. Use **Prompt E** from `SESSION_STARTER.md` — explicit re-orientation.
3. Read `DECISIONS.md` end-to-end before acting.
4. `git log --oneline -20` for recent activity.
5. Walk smoke tests before changing anything — confirm baseline.
6. Then proceed as normal feature session.

This is the #1 most-likely-to-fail scenario in long-running projects. Don't skip the re-orientation.

---

## Maintaining this manual

Update when:
- A new Claude model ships with meaningfully different capabilities.
- Claude Code adds or changes a major feature (skills, MCP, plan mode behavior, etc.).
- You catch yourself disagreeing with the advice on a re-read (your taste has evolved).
- A real incident reveals a missing chapter.

Date every meaningful update. Old advice should be marked deprecated rather than silently overwritten, so you can see what changed.

The manual is a living document, but stable in the principles. Mechanics shift; the three levers (context, scope, verification) don't.

---

## What's NOT in this manual

- Project-specific stuff → that goes in your project's `CLAUDE.md` and `docs/`.
- Stack-specific deep guidance → see the relevant Vercel / Next.js / etc. skills.
- General programming knowledge → covered by Claude's training; ask in-session.
- Your personal preferences → `~/.claude/CLAUDE.md` (global) and memory system.

This manual stays in its lane: how to operate Claude Code well as an advanced user.

---

## Contributing

Single-maintainer, opinionated repo. Fork freely — adapt the manual, templates, and global setup to your own workflow without asking.

- **Issues** welcome for: factual errors, broken links, outdated Claude Code mechanics, install steps that don't work on a clean machine.
- **PRs** welcome for the same — clear fixes get merged.
- **Larger reframes / new chapters / opinion changes** are unlikely to land; this reflects how *I* work. Better to fork and shape it to yours.

---

## License

MIT — see [`LICENSE`](LICENSE).
