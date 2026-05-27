# 12a — Three persistence layers, compared

Claude Code has three mechanisms for "remembering things between sessions." They look similar but behave very differently. Using the wrong one is a common mistake.

## At a glance

| Layer | Lives in | Loaded | Best for |
|---|---|---|---|
| **CLAUDE.md** | Project root + global `~/.claude/CLAUDE.md` | Every session, automatically, into context | Stable instructions: stack, conventions, rules |
| **Skills** | `~/.claude/skills/` or `.claude/skills/` | Lazily, when description matches the task | Specialized capabilities ("review code", "deploy to Vercel") |
| **Memory** | `~/.claude/projects/<dir>/memory/` + `MEMORY.md` | Lazily, when relevant | Things learned about *you* and *the project state* across sessions |

## How they compose in a real session

1. Session starts. Claude reads global + project `CLAUDE.md`. ~5–10K tokens used.
2. `MEMORY.md` index loaded. ~1–2K tokens.
3. You ask for something. Claude maybe loads a skill if it matches. ~3–5K tokens.
4. Claude maybe loads a specific memory if relevant. ~500 tokens.
5. Conversation proceeds with all of the above active.

Total before any real work: ~15–20K tokens of "remembered context." Fine — that's why we use them. But if your CLAUDE.md is 800 lines and 20 skills always trigger, you start sessions in yellow zone. Trim.

## Decision tree: where does this thing go?

> I want Claude to know X.

- Is X stable across all projects? → Global `CLAUDE.md` ([12b](12b-claudemd.md)).
- Is X stable for this project only? → Project `CLAUDE.md`.
- Is X a multi-step procedure I do repeatedly? → Skill ([13a](13a-skill-anatomy.md)).
- Is X about me as a person / my preferences? → Memory (user / feedback — see [12c](12c-memory.md)).
- Is X about current project state, deadlines, decisions? → `PROGRESS.md` / `DECISIONS.md` in the project (NOT memory — files in the project are more durable and reviewable).
- Is X about an external system? → Memory (reference) — but only if you'll actually use it.

## Hooks are different

If you want X to happen *automatically* in response to an event — running typecheck after every TS edit, blocking commits without smoke tests — that's a hook, not a persistence layer. The harness runs hooks; they're deterministic. See [14a](14a-settings-cascade.md) and [14b](14b-hook-recipes.md).

## TL;DR

- `CLAUDE.md` = always loaded, stable rules. Cheap until it's bloated.
- Skills = lazy, specialized. Have many; they don't cost you until used.
- Memory = automatic and lazy. Review occasionally; prune stale.
- Project state (progress, decisions) goes in markdown files in the project, not memory.
- Automatic deterministic behavior = hook.
