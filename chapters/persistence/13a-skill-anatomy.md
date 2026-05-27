# 13a — Skill anatomy

A skill is a markdown file with frontmatter, stored in:

- `~/.claude/skills/<skill-name>/SKILL.md` — global, available in every project.
- `<project>/.claude/skills/<skill-name>/SKILL.md` — project-only.

Claude Code scans skills at session start, reads the frontmatter (especially the `description`), and *lazily loads* the full body only when the description matches what the user is asking about.

## File shape

```markdown
---
name: client-site-deploy
description: Deploy a static client website to the production VPS. Use when deploying any project under the client-site stack, or when the user mentions VPS deployment or going live with a client site.
---

# Deploy to VPS

[multi-step procedure here]
```

That's the entire anatomy:

- **Frontmatter** — `name` (kebab-case identifier) and `description` (the trigger).
- **Body** — the instructions, loaded only when the skill fires.

## What goes in the body

Two principles:

1. **Be specific.** "Use Tailwind" is weak. "Use Tailwind utilities only; no @apply, no custom CSS classes" is strong.
2. **Order the steps.** If it's a workflow, number them. If it's a checklist, bullet them. If it's reference, group by topic.

The body is loaded when the skill fires, so it competes for context. Keep it tight — 50–200 lines is normal. >300 means it should probably be a project doc instead.

## Where to put skills

- `~/.claude/skills/` — global, available in every project. Cross-project workflows.
- `<project>/.claude/skills/` — project-specific. Ships with the repo.

For workflow that crosses projects → global. Project-specific procedures → project's `.claude/skills/`. Don't over-scope project skills — if a skill is project-specific *and* the procedure is small, it might just belong in the project's `CLAUDE.md`.

## Naming

Short, kebab-case, scoped if needed. `client-site-deploy` not `deploy`. `locale-rules-nl` not `locale`. Specific enough that you can spot it in a list.

## Use the skill-creator skill

Don't hand-write skills from memory. Frontmatter syntax has gotcha cases (multiline descriptions, allowed-tools format), and the `skill-creator` skill stays current with Claude Code's schema.

> "Create a skill called `pre-deploy-audit` that runs the checks in `docs/DEPLOY.md` and reports pass/fail. Trigger on 'deploy' / 'ship' / 'production' keywords."

The skill-creator picks the right file location, writes correctly-shaped frontmatter, and validates the description against common pitfalls.

## Cost and context

Skills are *lazy* — they don't burn context until loaded. So:

- Having 20 skills is fine.
- Having 5 skills that *all* match every prompt = expensive. They all load.

Test by checking: in a typical session, how many skills are firing? If "many," tighten descriptions — see [13b](13b-trigger-descriptions.md).

## TL;DR

- A skill = markdown file with `name` + `description` frontmatter + body.
- Description is the trigger; body loads only when description matches.
- Body 50–200 lines, specific, ordered.
- Global vs project: cross-project → global; project-specific → in the repo.
- Use the `skill-creator` skill — don't hand-write.
