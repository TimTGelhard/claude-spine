# 15 — Tool selection principles

Claude Code has many tools. Picking the right one isn't optional — it's how you control context cost, latency, and correctness.

Read this first; jump to the category file for the specific tool.

## Categories

| Category | File |
|---|---|
| File ops (Read, Edit, Write, NotebookEdit) | [15a-file-ops.md](15a-file-ops.md) |
| Search (grep, find, Explore) | [15b-search.md](15b-search.md) |
| Execution (Bash, Monitor) | [15c-execution.md](15c-execution.md) |
| Planning (plan mode, TaskCreate) | [15d-planning.md](15d-planning.md) |
| Delegation (Agent) | [15e-delegation.md](15e-delegation.md) |
| Scheduling (ScheduleWakeup, /loop, /schedule, Cron) | [15f-scheduling.md](15f-scheduling.md) |
| Web (WebFetch, WebSearch) | [15g-web.md](15g-web.md) |
| MCP | [15h-mcp.md](15h-mcp.md) |
| Slash commands | [15i-slash-commands.md](15i-slash-commands.md) |

## The general principles

1. **Use dedicated tools, not Bash.** `Read` not `cat`. `Edit` not `sed`. `Write` not `echo >`. The dedicated tools are syntax-aware, faster, and produce reviewable tool calls.
2. **Filter verbose output.** Pipe `npm install` to `tail -20`. Don't pull 5000 lines into context.
3. **Background long-runners.** Dev servers, watch tests, full test suites — always `run_in_background: true`. Foreground blocks the conversation.
4. **Parallelize independent work.** Multiple tool calls in one message run in parallel. Two unrelated greps → two `Bash` calls in one turn.
5. **Delegate broad search and audits.** Open-ended "where is X" with many lookups → `Agent (Explore)`. Independent perspective for review → `Agent (general-purpose)`.
6. **Reach for slash commands first** when the task is review / verify / security audit / config edit. They're maintained and Anthropic-tested.

## Choosing between similar tools

| Goal | Use | Don't use |
|------|-----|-----------|
| Read a file | `Read` | `cat` via Bash |
| Modify a file | `Edit` | `sed` via Bash, `Write` (unless full rewrite) |
| Search code (one shot) | `grep`/`rg` via Bash | `Read` then visually scan |
| Open-ended search (many lookups) | `Agent (Explore)` | Many sequential greps |
| Find a function definition | `grep` | `Agent (Explore)` (overkill) |
| Run a test | `Bash` | Asking Claude what would happen |
| Long-running process | `Bash run_in_background` | Foreground (blocks conversation) |
| Multi-step research | `Agent (general-purpose)` | Doing it yourself in main thread |
| Audit / review | `Agent` (independent) | Asking Claude in same thread (contaminated) |
| Review a diff | `/code-review` | Manual "let me look at the diff" |
| Verify a feature | `/verify` | Asking Claude "did it work?" |

## TL;DR

- `Read`/`Edit`/`Write` for files, in that order of preference.
- `Bash` for execution. Background long-runners. Filter verbose output.
- `Agent (Explore)` for many-lookup searches; `grep` for one-shots.
- `Agent (general-purpose)` for parallel, audit, or expensive-to-load research.
- Plan mode for non-trivial work; skip for trivial.
- Slash commands first for review / verify / security / config.
