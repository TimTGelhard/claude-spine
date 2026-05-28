# 18c — Context management anti-patterns

The context window is a budget, not bandwidth. Each entry: the anti-pattern, why it fails, what to do instead.

## Dumping the whole codebase to "give Claude full context"

**Fails because:** attention dilution. Claude focuses worse on the relevant 5%.
**Instead:** load the slice for the current task. Trust Claude to read more on demand. See [02-context-budget.md](../foundations/02-context-budget.md).

## `cat` via Bash to read files

**Fails because:** plain text dump, no syntax handling, no IDE integration, bypasses the file-state tracking the Read tool maintains.
**Instead:** the `Read` tool. See [15a-file-ops.md](../tools/15a-file-ops.md).

(Edge: when a shell pipeline genuinely needs the file body in a heredoc or as input to another command, `cat` is fine — the anti-pattern is using `cat` to *look at* a file, not the unix idiom.)

## Running verbose commands without filtering

**Fails because:** install output (1000+ lines) lands in context for the session.
**Instead:** pipe to `tail -50`, or filter to errors only. For long-running processes, use background execution and only pull the relevant slice.

## Ignoring auto-compaction

**Fails because:** post-compaction, Claude "remembers" decisions imprecisely. Subtle bugs.
**Instead:** treat compaction as a soft restart. Re-state critical constraints right after it happens.

## Storing project state in conversation

**Fails because:** dies at session end. Next session starts blind.
**Instead:** files (`PROGRESS.md`, `DECISIONS.md`, `FEATURES.md`). Update at session end. See [12a-three-layers-overview.md](../persistence/12a-three-layers-overview.md).

## TL;DR

Context-management failures all share the same root: treating the window as infinite when it's a budget you can blow in a few sloppy reads. Load on demand, filter verbose output, persist state to files between sessions.
