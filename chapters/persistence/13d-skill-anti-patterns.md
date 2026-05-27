# 13d — Skill anti-patterns and the library thesis

Skills are easy to write and hard to write *well*. The failure modes below are the ones that wreck personal skill libraries — and the principles for avoiding them are what make a *shippable* library possible.

## The "speculative library" trap — revised

The classic anti-pattern: write skills you might need someday, end up with a graveyard of unused files that all fire (badly) and bloat context.

**The old framing:** "Don't ship libraries. Write skills only after you've copy-pasted the same prompt 3+ times."

**The revision:** the problem isn't shipping a library. The problem is shipping a library of skills with *poorly-designed triggers* or *fast-aging content*. A library can ship at scale if:

1. **Triggers fire narrowly.** Each skill activates only for its specific situation. Trigger overlap is what causes bloat — five skills firing on every prompt costs more than fifty firing on the right one.
2. **Content sits on a slow-aging axis.** Workflow, discipline, and review patterns age in years. Framework-specific syntax ages in months. A shipped library should sit on the slow axis.
3. **Fast-aging stuff lives separately.** Stack-specific helpers go in a personal bucket the user grows themselves, not in the shipped core.

The manual you're reading is itself a library. It works because each skill's trigger is sharp, the content is workflow/discipline (slow-aging), and the personal `skills/bucket/` exists separately for the fast-aging stuff.

**The personal-collection rule still stands:** for your own machine, write skills only after the procedure has earned itself — usually 3+ paste-ins. The "speculative" warning applies to *personal* libraries, where there's no curation discipline to keep stale skills out.

## Other anti-patterns

### Vague descriptions

Skills don't fire when needed or fire when they shouldn't. See [13b](13b-trigger-descriptions.md). The most common form: "this is a helper for X" — describes the artifact, not the trigger.

### Long unfocused skills

A skill that does five things probably should be three skills. Body should answer one question; pick the pattern (workflow / reference / persona — see [13c](13c-skill-design-patterns.md)) that fits.

### Skills that compete with CLAUDE.md

If it should apply *every* session, it's CLAUDE.md ([12b](12b-claudemd.md)), not a skill. Skills are for things you want loaded *sometimes*.

### Skills that compete with hooks

If it's "always run this command after X," it's a hook ([14b](14b-hook-recipes.md)), not a skill. Hooks are deterministic; skills are reasoning.

### A graveyard of unused skills

Skills you wrote and never use cost session-start scan time and clutter the trigger surface. Audit periodically:

- **Does this still fire when expected?** If not, fix the description.
- **Is the content still accurate?** Library APIs change.
- **Am I using it?** If a skill hasn't fired in 6 months, delete it.

### Re-suggesting the same skill after dismissal

If the user dismissed a skill's output last session, don't fire it the next session for the same situation. That's noise.

## Maintaining skills

Audit two axes:

- **Trigger health** — fires when expected, stays silent otherwise. Tighten if not.
- **Content health** — still accurate as the underlying tools / APIs / discipline evolve. Refresh or delete.

A skill that fires reliably but on stale content is worse than no skill. So is a skill with fresh content that never fires.

## The bucket pattern (preview)

The manual's `skills/bucket/` is the user's personal library — they fill it themselves with stack-specific or project-specific skills. The core ships empty. This separates fast-aging (user's stack) from slow-aging (workflow/discipline) so the core can stay shippable without rotting.

The lesson: when you build a library — for yourself or to ship — match the axis of decay to the layer.

## TL;DR

- The "don't ship libraries" rule is wrong as stated; the right rule is "ship libraries with narrow triggers and slow-aging content."
- Personal collections: write skills only after 3+ paste-ins — speculation kills your library.
- Long unfocused skills → split. Skill vs CLAUDE.md vs hook: match the mechanism to the need.
- Audit periodically on both trigger health and content health.
- Fast-aging stuff goes in your personal bucket, not in the shipped spine.
