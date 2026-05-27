# 15c — Execution: Bash and Monitor

## Bash

**Use for:** anything that needs the shell. Building, testing, git, package management.

**Discipline:**

- **Use `run_in_background: true` for long-running commands** (dev server, watch tests). Don't sit blocking the conversation.
- **Pipe to `head -N` or `tail -N` for verbose commands** — don't pull 5000 lines of `npm install` output into context.
- **Chain related commands with `&&`** (sequential) — fewer tool calls = less overhead.
- **Parallel commands → multiple `Bash` calls in one message.** They run concurrently.

**Anti-patterns:**

- `cat file.ts` to read a file → use `Read`.
- `sed -i ...` to modify a file → use `Edit`.
- `echo "..." > file.ts` to create a file → use `Write`.
- Running the dev server foreground → always `run_in_background: true`.
- `find /` instead of `find .` → scans the whole filesystem.

## Monitor

**Use for:** watching a background process for events. Better than polling with `sleep`.

When you start a long-running task with `run_in_background`, `Monitor` streams stdout lines as notifications. Use it when you need to react to a specific log line; don't use it as a wait loop where Bash with a one-shot wait would do.

## When to background

| Task | Foreground or background? |
|---|---|
| Dev server | Background |
| Watch tests | Background |
| Full test suite (one-shot) | Background if it'll take more than a few seconds |
| Build that takes ~30s | Foreground OK |
| `npm install` | Background — you don't need the output streaming |
| Quick `git status` | Foreground |

The rule: if blocking on it costs more wall-clock than the next thing you could be doing, background it.

## TL;DR

- Bash for shell. Background long-runners. Filter verbose output.
- Chain sequential with `&&`; parallel = multiple Bash calls in one message.
- `Read`/`Edit`/`Write` beat `cat`/`sed`/`echo` every time.
- `Monitor` for event-driven background-watching.
