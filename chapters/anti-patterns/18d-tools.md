# 18d — Tool selection anti-patterns

Using the wrong tool wastes tokens and produces worse output. Each entry: the anti-pattern, why it fails, what to do instead. These are strong defaults, not universal laws — most have a context where the "wrong" tool is genuinely the right one (e.g., `Write` is fine for whole-file rewrites; `cat` is fine in shell pipelines; `sleep` is fine when you're polling external state the harness can't notify you about). When you knowingly hit one of those edges, ignore the rule.

## Using subagents for trivial work

**Fails because:** overhead > benefit. Slower than just doing it, and you lose the reasoning trace.
**Instead:** subagents for parallel, broad-search, or audit work. See [16a-when-to-delegate.md](../subagents/16a-when-to-delegate.md).
*(Edge: when you specifically want a clean context window for a small task — e.g., reading a giant log without polluting the main thread — delegating is fine even though the unit of work is small. The "trivial" anti-pattern is when the agent itself adds no isolation value.)*

## Using subagents when the *thinking* matters

**Fails because:** you get the conclusion but not the reasoning. Can't course-correct when the conclusion is wrong.
**Instead:** do it in the main thread when you'll iterate. Delegate the search; keep the synthesis.

## Using `Write` for small edits

**Fails because:** sends whole file content, harder to review the diff, more likely to drop unrelated lines.
**Instead:** `Edit` for targeted changes. See [15a-file-ops.md](../tools/15a-file-ops.md).
*(Edge: creating a new file or doing a complete rewrite — `Write` is the right tool. The anti-pattern is reaching for it on a 3-line change in a 500-line file.)*

## Polling with `sleep` instead of `Monitor`

**Fails because:** wastes tokens on cycles, blocks the conversation.
**Instead:** `Monitor` for events, `run_in_background` for fire-and-forget. See [15c-execution.md](../tools/15c-execution.md).
*(Edge: waiting on external state the harness can't notify you about — a CI run, a deploy, a remote queue — there `sleep` (or `ScheduleWakeup` at a longer interval) is appropriate. The anti-pattern is using `sleep` to poll local processes that already emit completion signals.)*

## Asking Claude general knowledge questions in Claude Code

**Fails because:** wastes tokens on a session loaded with project context; Claude Code is for tasks with tools.
**Instead:** the web client for pure Q&A; Claude Code for code work.
*(Edge: a quick fact-check that's directly relevant to the code in front of you — e.g., "what's the default timeout on `fetch` in Node?" — is fine in-session; the question gets answered against your project's context. The anti-pattern is asking encyclopedia-shaped questions ("explain how OAuth works") with a full project tree loaded.)*

## TL;DR

Tools have characteristic costs. `Write` is heavier than `Edit`. Subagents have overhead. `sleep` burns tokens. Pick the lightest tool that does the job, and don't use Claude Code when a non-tool answer is what you actually want.
