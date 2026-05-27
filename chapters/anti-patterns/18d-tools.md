# 18d — Tool selection anti-patterns

Using the wrong tool wastes tokens and produces worse output. Each entry: the anti-pattern, why it fails, what to do instead.

## Using subagents for trivial work

**Fails because:** overhead > benefit. Slower than just doing it, and you lose the reasoning trace.
**Instead:** subagents for parallel, broad-search, or audit work. See [16a-when-to-delegate.md](../subagents/16a-when-to-delegate.md).

## Using subagents when the *thinking* matters

**Fails because:** you get the conclusion but not the reasoning. Can't course-correct when the conclusion is wrong.
**Instead:** do it in the main thread when you'll iterate. Delegate the search; keep the synthesis.

## Using `Write` for small edits

**Fails because:** sends whole file content, harder to review the diff, more likely to drop unrelated lines.
**Instead:** `Edit` for targeted changes. See [15a-file-ops.md](../tools/15a-file-ops.md).

## Polling with `sleep` instead of `Monitor`

**Fails because:** wastes tokens on cycles, blocks the conversation.
**Instead:** `Monitor` for events, `run_in_background` for fire-and-forget. See [15c-execution.md](../tools/15c-execution.md).

## Asking Claude general knowledge questions in Claude Code

**Fails because:** wastes tokens on a session loaded with project context; Claude Code is for tasks with tools.
**Instead:** the web client for pure Q&A; Claude Code for code work.

## TL;DR

Tools have characteristic costs. `Write` is heavier than `Edit`. Subagents have overhead. `sleep` burns tokens. Pick the lightest tool that does the job, and don't use Claude Code when a non-tool answer is what you actually want.
