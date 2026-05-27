> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/tools/`](chapters/tools/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 15 — Tool palette: which tool when

Claude Code has many tools. Picking the right one isn't optional — it's how you control context cost, latency, and correctness.

## File operations

### `Read`
**Use for:** any file Claude needs to see. Always preferred over `cat` via Bash.

**Use with care:**
- Big files: pass `offset` and `limit` to read only the relevant range.
- Logs > 1000 lines: don't load whole — `grep` first, then `Read` the relevant section.
- Generated/lockfiles (`package-lock.json`): almost never. Read `package.json` instead.

**Anti-pattern:** "Let me read the file to understand the project" — for one file, fine. For ten files at the start of a session, you've burned a third of your context before doing any work.

### `Edit`
**Use for:** modifying existing files. The default for code changes.

**Rules:**
- Always `Read` the file first (the tool enforces this).
- Match exact strings including indentation. Failed `Edit`s mean the string isn't unique or doesn't match.
- For multiple changes to the same file, prefer multiple `Edit` calls over one giant rewrite.
- For renaming a symbol everywhere in a file: `replace_all: true`.

**Anti-pattern:** using `Write` to "rewrite the whole file" when only a few lines change. Wastes tokens, harder to review.

### `Write`
**Use for:** creating new files, or genuine full rewrites (>50% changed).

**Anti-pattern:** writing a "fresh" version of a file you could have edited. Loses git blame, harder to review.

### `NotebookEdit`
**Use for:** Jupyter notebooks (`.ipynb`). Don't `Edit` notebooks — the JSON structure breaks.

## Search

### `Bash` with `grep` / `rg` / `find`
**Use for:** quick lookups when you know roughly what you're searching for.

**Patterns:**
```bash
# Find every place that imports from a module
grep -r "from '@/lib/db'" --include="*.ts" --include="*.tsx" app/

# Find files matching a pattern
find . -name "*.test.ts" -not -path "*/node_modules/*"

# Search for a function definition
grep -rn "export function actionCreateQuote" .
```

**Faster than `Explore`** for one-shot lookups. **Slower than `Explore`** when you don't know what to search for or need multiple lookups.

### `Agent` with `subagent_type: Explore`
**Use for:** open-ended "where is X" / "what files reference Y" when you'd need multiple greps.

**Cost trade:** ~10-30 seconds of latency, but returns a 1-2K summary instead of dumping all matches into your context. Worth it when the search would produce a lot of noise.

**Anti-pattern:** spawning Explore for a single file lookup. Just `find`.

## Execution

### `Bash`
**Use for:** anything that needs the shell. Building, testing, git, package management.

**Discipline:**
- Use `run_in_background: true` for long-running commands (dev server, watch tests). Don't sit blocking the conversation.
- Pipe to `head -N` or `tail -N` for verbose commands — don't pull 5000 lines of `npm install` output into context.
- Chain related commands with `&&` (sequential) — fewer tool calls = less overhead.
- Parallel commands → multiple `Bash` calls in one message.

**Anti-pattern:** `cat file.ts` to read a file. Use `Read`. The IDE will show the file inline; `cat` dumps it as plain text and provides no syntax-awareness.

**Anti-pattern:** running the dev server foreground. Always `run_in_background: true`.

### `Monitor`
**Use for:** watching a background process for events. Better than polling with `sleep`.

## Planning

### `EnterPlanMode` / `ExitPlanMode`
**Use when:**
- Task touches >3 files OR >2 layers.
- Architectural decision involved.
- Security boundary changing.
- You're unsure of the right approach.

**Skip when:**
- One-file bug fix with obvious cause.
- Mechanical edit (rename, copy change).

**How it works:** Claude proposes a plan, you approve or push back, then Claude executes. Catches "Claude is about to do something wrong" before it's done.

**Anti-pattern:** planning everything. For simple tasks it's friction. For complex ones it's gold.

## Delegation

### `Agent` (general-purpose)
**Use for:**
- Multi-step research you can't easily script.
- Audits and code reviews (independent perspective).
- Parallel independent tasks (multiple `Agent` calls in one message).

**Don't use for:**
- Tasks where the *thinking* matters — you only get the conclusion.
- Tasks you'll iterate on — subagent vanishes.
- Trivial work — overhead isn't worth it.

See [16-subagents.md](16-subagents.md) for the full pattern.

### `Agent` (Explore) — already covered above.

### `Agent` (Plan)
**Use for:** architectural planning when you want a structured proposal back. Outputs a step-by-step plan.

## Scheduling and persistence

### `TaskCreate` / `TaskUpdate` / `TaskList`
**Use for:** tracking progress on multi-step work within the current session.

**Anti-pattern:** using tasks for what should be in `PROGRESS.md`. Tasks die at session end. PROGRESS.md persists.

**Anti-pattern:** creating one task per tiny action. Tasks are for *meaningful units of work*, not every keystroke.

### `CronCreate` / `CronList` / `CronDelete`
**Use for:** scheduled remote agents (running periodically without you). Rare for solo MVP work. Useful for ongoing maintenance ("check the deploy status every morning").

### `ScheduleWakeup`
**Use for:** within an autonomous loop, deciding when to next check on a long-running task. Niche.

## Web

### `WebFetch`
**Use for:** fetching a specific URL you know.

**Discipline:** the page content goes into context. Don't fetch huge pages without a reason. If you're scraping multiple, use a subagent.

### `WebSearch`
**Use for:** open-ended "find me current info on X."

**Caveat:** Claude's training has a cutoff. For library docs, breaking changes, or recent platform shifts, `WebSearch` beats trusting Claude's memory.

## MCP integrations

MCP (Model Context Protocol) servers extend Claude with external capabilities. Some you have loaded; others are worth adding for any serious build setup.

### Must-have MCPs (install on every machine)

These give Claude capabilities it doesn't have natively. Install once globally, benefit on every project.

#### Chrome DevTools MCP
**Use for:** Claude driving a real Chrome browser, accessing devtools — clicking, typing, taking screenshots, reading console messages, inspecting network requests, capturing performance traces, running JavaScript in page context.

**Killer use case:** Claude testing the frontend himself before declaring done. Walk a flow in a real browser, screenshot the result, read the console for errors — all from inside the conversation, no manual hand-off.

**Versus Playwright MCP:** overlapping but different emphasis. Chrome DevTools MCP is debugging-first (performance traces, devtools panels). Playwright is test-automation-first (assertion-friendly, headless-friendly). Having both is fine; if you can only pick one for frontend verification, Chrome DevTools wins for solo MVP work.

**Install:** check the Chrome DevTools MCP repo (search `chrome-devtools-mcp` on GitHub) for the current install command. Typically `claude mcp add` with the package name.

#### Context7
**Use for:** up-to-date library documentation injected into Claude's context on demand. Solves the "framework moves faster than Claude's training" problem.

**Killer use case:** before writing Next.js 16 / Supabase / Stripe / any modern-library code, Claude can query Context7 for the *current* API rather than guessing from training data. Eliminates a class of hallucinations.

**How it fits with your existing rules:** your global CLAUDE.md says "don't invent — file paths, API names, config keys, library features, version-specific syntax." Context7 is the verification mechanism. When Claude is uncertain, query Context7 instead of guessing.

**Install:** see `context7.com` for the current install steps. Hosted MCP — no local server to run.

#### Playwright MCP (you have this)
**Use for:** programmatic browser automation, especially for repeated test flows. Complements Chrome DevTools MCP — use Playwright for "verify this works end-to-end on every deploy," Chrome DevTools for "debug why this specific page is slow."

### Project-specific MCPs you have loaded

#### `mcp__ide__getDiagnostics`
**Use for:** pulling TypeScript / lint errors from the IDE without running a full `tsc`.

#### `mcp__claude_ai_Gmail__*` / `mcp__claude_ai_Google_*`
**Use for:** real workflow tasks (drafting emails, scheduling). Outside of building, mostly.

#### `mcp__plugin_vercel_*`
**Use for:** Vercel auth / deployment flows. The Vercel skills (`vercel:deploy`, `vercel:env`, etc.) wrap most useful patterns.

### Finding and installing MCPs

- **Official registry:** `github.com/modelcontextprotocol` — anchor for stable servers.
- **Community registries:** `mcp.so` aggregates third-party MCPs.
- **Verify before installing:** check that the repo is actively maintained, last commit recent, weekly downloads non-trivial. The MCP ecosystem has churn.
- **Install via `claude mcp add`** for most servers, or edit your MCP config directly.

### Cost of leaving MCPs running

Every loaded MCP contributes to session-start tokens. Tool catalogs, descriptions, and frontmatter all land in context before you type a prompt. Five MCPs you never use this session still cost tokens this session.

Audit periodically (`claude mcp list` or your client's equivalent). If an MCP hasn't fired in weeks, uninstall — reinstalling takes under a minute when you actually need it.

Heavy MCPs (browser automation with many tools, broad API wrappers) cost more at idle than narrow ones. Stack them only when the unique capability earns the running cost. Use deliberately — they're power tools, not always-on assistants.

### When NOT to install an MCP

- It overlaps with an MCP you already have (don't run three browser-automation MCPs).
- It's a wrapper around a single API call you could `fetch` instead.
- It hasn't been updated in 6+ months.
- You can't articulate the specific use case it unlocks.
- You wouldn't use it weekly. Idle MCPs still cost context.

## Slash commands

Anthropic ships first-party commands invoked with `/<name>`. They're maintained, tested, and kept current — for the things they cover, they beat both custom skills and ad-hoc manual approaches. Reach for these *first* before doing the same work by hand.

### Tier 1 — High-value, use often

| Command | When | Why it beats manual |
|---------|------|---------------------|
| `/ultrareview` | Before merging significant PRs or branches | Multi-agent cloud review. Heavyweight, billed separately, but catches what single-pass review misses. **User-triggered only — Claude cannot launch it.** Pass `<PR#>` for a GitHub PR, or no arg to review the local branch. |
| `/security-review` | Before any deploy touching auth, payments, PII; after dependency changes | Independent security audit of pending diff. Replaces ad-hoc grep + manual checks. |
| `/code-review` | After any non-trivial change | Diff correctness review. Pass `--comment` to post findings as PR comments. Multiple effort levels (low/medium/high/max). |
| `/verify` | "Does this actually work end-to-end?" | Full-stack verification: runs the app, walks the flow, checks browser → API → data → response. Replaces manual smoke walks when the feature is verifiable. |

**The behavioral rule:** when the user says "review this," "audit this," "check that it works," "is this safe to ship," reach for the appropriate slash command *first*. Do the work manually only when no slash command fits.

### Tier 2 — Useful operational

| Command | When |
|---------|------|
| `/init` | Starting in a codebase without `CLAUDE.md` — generates one from existing code |
| `/run` | Need to drive the actual app to see a change working (CLI, server, TUI, browser) |
| `/skill-creator` | Authoring a new skill — knows current schema, avoids hand-edit gotchas |
| `/update-config` | Settings.json edits (hooks, permissions, env vars) |
| `/fewer-permission-prompts` | After a session of approving the same commands — auto-generates allowlist |
| `/keybindings-help` | Custom keybindings |

### Tier 3 — Specialized

- `/loop <interval> <prompt>` — Run a prompt on a recurring interval ("check the deploy every 5 min")
- `/schedule` — Cron-style scheduled remote agents for ongoing maintenance
- Vercel suite: `/vercel:deploy`, `/vercel:env`, `/vercel:status`, etc. — wrap common Vercel flows

### Built-in (always available)

- `/help` — Help
- `/clear` — Clear conversation
- `/config` — Settings
- `/fast` — Toggle Opus speed mode (Opus 4.6 and 4.7)

### When to use slash commands vs alternatives

| Need | Use | Don't use |
|------|-----|-----------|
| Review a diff | `/code-review` | Manual "let me look at the diff" |
| Security audit | `/security-review` | Ad-hoc grep + checklist by hand |
| Verify a feature works | `/verify` | Asking Claude "did it work?" |
| Heavy PR review | `/ultrareview` | Multiple manual passes |
| Generate CLAUDE.md | `/init` | Writing from scratch |
| Settings.json edit | `/update-config` | Hand-editing the JSON |
| Skill authoring | `/skill-creator` | Hand-writing frontmatter |

The pattern: slash commands are the Anthropic-tested version of work you'd otherwise do manually. Defaulting to them saves time, catches more, and stays current as Claude Code evolves.

## Skills

Already covered in [12-skills-memory-claudemd.md](12-skills-memory-claudemd.md). The short version:

- **Built-in skills** (vercel:*, frontend-design, code-review, verify, etc.) — lazily loaded when relevant. Worth knowing what's available.
- **Custom skills** — write for repeated multi-step workflows. Don't write for one-offs.

Browse `~/.claude/skills/` and `~/.claude/plugins/` occasionally to see what's available. You probably have powerful tools you've never used.

## Choosing between similar tools

| Goal | Use | Don't use |
|------|-----|-----------|
| Read a file | `Read` | `cat` via Bash |
| Modify a file | `Edit` | `sed` via Bash, `Write` (unless full rewrite) |
| Search code | `grep`/`rg` via Bash | `Read` then visually scan |
| Open-ended search | `Agent (Explore)` | Many sequential greps |
| Find function definition | `grep` | `Agent (Explore)` (overkill) |
| Run a test | `Bash` | Asking Claude what would happen |
| Long-running process | `Bash run_in_background` | Foreground (blocks conversation) |
| Multi-step research | `Agent (general-purpose)` | Doing it yourself in main thread |
| Audit/review | `Agent` (independent) | Asking Claude in same thread (contaminated) |

## TL;DR

- `Read`/`Edit`/`Write` for files, in that order of preference.
- `Bash` for execution. Background long-runners. Filter verbose output.
- `Agent (Explore)` when a search needs many lookups; `grep` for one-shots.
- `Agent (general-purpose)` for parallel, audit, or expensive-to-load research.
- `EnterPlanMode` for non-trivial work; skip for trivial.
- MCPs and skills extend what Claude can do — know what's loaded.
