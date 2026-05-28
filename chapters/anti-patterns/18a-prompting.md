# 18a — Prompting anti-patterns

A catalog of prompting patterns that fail in the contexts this spine targets. Each entry: the pattern, why it fails, what to do instead. These are strong defaults, not universal laws — most have an edge case where they're the right move (e.g., pasting a whole file when Claude needs to see a specific format choice that wouldn't survive a paths-only reference). When you knowingly hit one of those edges, ignore the rule.

## "Just figure it out"

**Fails because:** Claude picks a plausible default. You discover it's wrong after the code is written.
**Instead:** state the goal, the constraints, and what "done" looks like. Even one line each. See [09a-five-principles.md](../prompting/09a-five-principles.md).

## Bundling multiple unrelated asks in one prompt

**Fails because:** Claude prioritizes the first or last ask; the middle one gets neglected.
**Instead:** one ask per prompt. Multiple prompts in a session is fine; one prompt with three goals is not.

## "Make it better"

**Fails because:** "better" is undefined. You'll iterate 5 times.
**Instead:** specify what "better" means — tighter spacing, faster query, clearer name, etc.

## Pasting whole files when you could reference paths

**Fails because:** wastes tokens; Claude can `Read` precisely the lines it needs.
**Instead:** "look at `app/quotes/page.tsx`" — Claude reads on demand.

## Restating context Claude already has

**Fails because:** tokens spent rewriting `CLAUDE.md` content waste budget.
**Instead:** trust that CLAUDE.md + ARCHITECTURE.md is loaded. State only the *new* context for this turn.

## Apologizing for being unclear

**Fails because:** padding, not content.
**Instead:** just be clear. Skip the meta-commentary.

## Asking Claude to summarize what it just did

**Fails because:** the diff already shows it. Wastes tokens.
**Instead:** read the diff.

## Vague feedback ("this isn't right")

**Fails because:** Claude has to guess what you noticed. Often guesses wrong.
**Instead:** specific feedback. "The badge color logic doesn't handle the `archived` state."

## Correcting the same misunderstanding 3+ times

**Fails because:** if Claude keeps missing it, the framing is unclear or the session is drifting.
**Instead:** after 2 corrections, stop. Restart with the constraint stated explicitly upfront. See also [17b-recovery-moves.md](../recovery/17b-recovery-moves.md), Move A.

## Talking to Claude as if it remembers other sessions

**Fails because:** it doesn't. Each session starts fresh — state lives in files, not in conversation memory.
**Instead:** state needed context in this session, or load it from files (`CLAUDE.md`, `PROGRESS.md`, `DECISIONS.md`). See [12a-three-layers-overview.md](../persistence/12a-three-layers-overview.md).

## TL;DR

Vagueness, bundling, padding, and pretending Claude has memory it doesn't. The fix in every case: be more specific, smaller, and lean on files for state that should outlive the session.
