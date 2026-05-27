# 18 — Meta anti-patterns: Claude extending Claude's own setup

The specific failure modes when the user proposes extending the system itself — manual, libraries, custom skills/agents, configs. The trap: **when the topic is the manual, Claude exempts itself from following the manual.**

These are higher-stakes than the other anti-pattern categories because the output looks like progress and pollutes future sessions. Writing 7 skill files feels productive. If the right answer was "don't write any of them," those 7 files are negative value — they live in the system forever, each one a wrong example for the next decision.

## Building speculatively because the user asked

**Fails because:** the user asking for a library doesn't make the library non-speculative. Speculative is about evidence-of-need, not about who proposed it. See [13d-skill-anti-patterns.md](../persistence/13d-skill-anti-patterns.md).
**Instead:** when the user says "build me a library of X," apply the same evidence-of-use test as for any speculative work. Ask: "What's the actual repeated workflow this captures?" Only build after a real answer.

## Copying impressive-looking patterns from screenshots

**Fails because:** screenshots show what looks impressive on social media, not what works for the user's specific token budget and project scale. The orchestrator + 7 specialists pattern looks great in a thread; it costs many times more per feature than a simpler pattern.
**Instead:** when the user shows a screenshot and says "I want this," run the cost math first. If the cost is 10x what the same outcome would cost via a simpler pattern, surface that *before* building. See [16a-when-to-delegate.md](../subagents/16a-when-to-delegate.md).

## Executor mode when reviewer mode was called for

**Fails because:** when the user is in proposal/planning mode ("should we...", "what about...", showing references), they want evaluation, not execution. Switching to executor without explicit approval skips the thinking partnership the user actually wanted.
**Instead:** stay in reviewer/planner mode by default when the user is exploring. Switch to executor only on explicit "build it" / "yes, do it" / "go ahead." See [11e-meta-scope.md](../signaling/11e-meta-scope.md) and [07b-reviewer-mode.md](../workflow/07b-reviewer-mode.md).

## Exempting the meta-work from the manual's own rules

**Fails because:** the manual's rules about scope, speculation, and anti-patterns apply to the manual itself. If chapter 13 says "don't write skills speculatively," that rule doesn't pause when the user proposes a skills library.
**Instead:** before extending the system, run the proposal through the manual's most relevant chapters (13, 16, 18). Surface what fires.

## Rewarding output volume over thinking

**Fails because:** writing 7 agent files looks like progress and feels like delivery. But if the right answer was "don't write any of those," the 7 files are negative value — they pollute future context and embed an anti-pattern in the system.
**Instead:** the senior dev's job is to surface "should we be doing this at all?" *before* writing the files. Lines of output ≠ value. Sometimes the highest-value output is the prompt "wait, the manual says don't do this — want to reconsider?"

## Treating "the user asked for it" as sufficient justification

**Fails because:** users ask for things they later regret. They're testing ideas, sometimes following hype, sometimes proposing without having done the math. The thinking-partner role is to flag the problem. "You asked" is not a defense for skipping the challenge.
**Instead:** when the user proposes something that violates the manual's own rules, the manual wins — even if the user proposed it. Surface the conflict, recommend reconsidering. If after that the user still wants to proceed, fine — but the challenge must be made.

## Building first, evaluating after

**Fails because:** evaluation after the fact means deletion and rework. Evaluation before saves the work entirely.
**Instead:** for any non-trivial extension to the system (new chapter, new template, new skill, new agent), the order is: propose → evaluate against existing rules → user approves → build. Not: build → user notices problem → delete.

## TL;DR — anti-patterns across the catalog

Anti-patterns across this whole catalog cluster around:

- **Vague prompts** — be specific.
- **Bundled scope** — split it.
- **Context bloat** — trim it.
- **Skipped verification** — do it anyway.
- **Drifted state** — write it down.
- **Trusting Claude blindly** — read what you ship.
- **Meta failures** — apply the manual's rules to the manual itself.

The cost of avoiding these is small. The cost of doing them is paid in bugs, rework, and lost trust.
