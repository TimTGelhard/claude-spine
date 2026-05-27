# 16b — Agent types

## Built-in types

| Type | What for |
|---|---|
| `general-purpose` | Default. Multi-step research and tasks. Has all tools. |
| `Explore` | Read-only search. Fast file-finding, grep, "where is X." |
| `Plan` | Architectural planning. Returns a step-by-step plan. |
| `code-reviewer` (if available) | Independent code review. |

For most work, `Explore` for "where is X" and `general-purpose` for "do this for me" cover 90%+.

## Custom subagents — when narrow and repeated

You can define custom subagents in `~/.claude/agents/<name>.md` with their own system prompt, allowed tools, and model. Treat them as a way to bake a *repeated narrow task* into a callable — not as a roster of always-on specialists.

### Write a custom subagent when

- You've manually written the same delegation prompt 3+ times.
- The task is bounded and well-defined ("fix the linter," "write the migration following our naming convention," "run the deploy checklist").
- It saves real context vs typing the prompt fresh each time.

Examples that earn their keep:

- A "lint-fixer" that runs `npm run lint --fix` and reports the diff.
- A "migration-writer" that knows your naming convention and RLS-in-same-file rule.
- A "client-site-deploy-checker" that runs Lighthouse + accessibility + JSON-LD validation.

### Don't write custom subagents for

- **"A specialist for each domain" (frontend-specialist, backend-engineer, etc.).** See the orchestrator trap below.
- **General-purpose tasks.** The built-in `general-purpose` and `Explore` already cover broad work.
- **Things that should be CLAUDE.md instructions.** "Always behave this way" = CLAUDE.md, not an agent.
- **Things that should be hooks.** "Always run X after Y" = hook ([14b](../persistence/14b-hook-recipes.md)).

## The orchestrator-with-specialists trap

You'll see screenshots online: `master-orchestrator → 7 specialists in parallel → final review`. Each specialist call: 80–200K tokens. Total per feature: ~900K tokens.

The pattern is real, but it's calibrated for: enterprise teams with no token budget concerns, demos that look impressive on social media, or genuinely massive multi-week projects.

For solo MVP / client-site work, lightweight wins on every dimension:

- **One focused subagent for one specific task** = ~50–100K tokens.
- **Same end result** for an MVP feature.
- **No coordination overhead** — you're the orchestrator.
- **Re-callable** — invoke when needed, don't pre-define the world.

Use the heavy pattern only if you can articulate why your specific feature genuinely needs it. Default to lightweight.

## Designing a narrow custom subagent

Frontmatter:

- `name` — kebab-case, used as `subagent_type`.
- `description` — when this should fire. Specific triggers, not "a helper for X."
- `model` — `sonnet` default. `opus` only if the task needs deeper reasoning.
- `tools` (optional) — restrict if it should be read-only or limited.

Body:

- One paragraph: what it does.
- Operating rules: what it always does (5–10 bullets).
- Output format: what it returns (so the main thread can use the result).
- When NOT to invoke: clarify scope.

Use the `skill-creator` skill to author these — it knows the current Claude Code schema.

## TL;DR

- Built-in: `Explore` (search), `general-purpose` (do), `Plan` (architect).
- Custom subagents for narrow, repeated, well-bounded tasks. Write after 3+ paste-ins.
- Don't build an orchestrator-with-specialists pyramid for solo work — wrong economics.
- Use `skill-creator` to author custom subagent files.
