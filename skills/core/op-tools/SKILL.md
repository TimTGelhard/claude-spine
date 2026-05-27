---
name: op-tools
description: Use when choosing which Claude Code tool fits a task (Read/Edit/Write, Bash, grep, Agent, plan mode, TaskCreate, WebFetch, MCP, slash commands), debugging "should this be Bash or a dedicated tool", deciding when to background a long-running command, picking between grep and Agent(Explore) for a search, or auditing loaded MCPs for cost. Routes to chapter 15 of the Claude Code Operator's Manual.
---

# op-tools — which tool when

Picking the right tool isn't optional — it's how Claude controls context cost, latency, and correctness. Read ONE category file per task.

## Index

| Question / situation | Atomic file |
|---|---|
| General principles, "choose between similar tools" table | `/Users/macbook/claude-op-manual/chapters/tools/15-selection-principles.md` |
| Reading / editing / writing files (Read / Edit / Write / NotebookEdit) | `/Users/macbook/claude-op-manual/chapters/tools/15a-file-ops.md` |
| Searching code (grep, find, Agent Explore) | `/Users/macbook/claude-op-manual/chapters/tools/15b-search.md` |
| Running shell commands (Bash, Monitor, backgrounding) | `/Users/macbook/claude-op-manual/chapters/tools/15c-execution.md` |
| Planning (plan mode) and in-session tracking (TaskCreate) | `/Users/macbook/claude-op-manual/chapters/tools/15d-planning.md` |
| Delegating to a subagent (Agent tool mechanics) | `/Users/macbook/claude-op-manual/chapters/tools/15e-delegation.md` |
| Scheduling work (ScheduleWakeup, /loop, /schedule, Cron) | `/Users/macbook/claude-op-manual/chapters/tools/15f-scheduling.md` |
| Web access (WebFetch, WebSearch) | `/Users/macbook/claude-op-manual/chapters/tools/15g-web.md` |
| MCP integrations (Chrome DevTools, Context7, Playwright, audit) | `/Users/macbook/claude-op-manual/chapters/tools/15h-mcp.md` |
| Slash commands tier list and when to reach for them first | `/Users/macbook/claude-op-manual/chapters/tools/15i-slash-commands.md` |

## How to use

1. Pick exactly ONE category file. The user's task maps to one. Don't load all.
2. If the user is asking about *delegation depth* (when to subagent vs do it yourself), use `op-subagents` instead.
3. For "review this" / "verify this" / "is this safe to ship" → 15i (slash commands fire first).

## Common triggers

- "Should I use grep or Explore for this?" → 15b.
- "Why is `cat file.ts` wrong?" → 15a.
- "How do I run the dev server without blocking?" → 15c (backgrounding).
- "Plan mode for this?" → 15d.
- "Which MCPs should I have?" → 15h.
- "What does `/verify` do exactly?" → 15i.

## Sibling skills

- Deeper "when to delegate" guidance → `op-subagents`.
- Settings.json edits via tools → `update-config` skill.
- Reducing permission prompts → `fewer-permission-prompts` skill.
