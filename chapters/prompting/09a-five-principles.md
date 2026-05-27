# 09a — Five prompting principles

The lever with the highest ROI for output quality. A 2-minute investment in a better prompt regularly saves 30 minutes of rework.

## The five

1. **State the goal, not the steps.** Claude is smart enough to pick steps. It is not psychic about goals.
2. **Show, don't describe.** Example > paragraph every time.
3. **Give the constraints up front.** Not at the end as "oh by the way."
4. **Match prompt to scope.** Tiny tasks get tiny prompts. Complex tasks get structured prompts.
5. **One ask per prompt.** Bundling two unrelated asks halves the quality of both.

## The inverse — things that waste tokens

Stop doing these:

- **"Please"** and **"thank you"** — fine for tone, but unnecessary. Claude isn't offended by direct requests.
- **Restating the obvious.** "As you know, this is a Next.js project..." — yes, Claude saw `package.json`.
- **Apologizing for being unclear** — just be clear. Skip the meta-commentary.
- **Pasting whole files** when you could say `read app/quotes/page.tsx`. Same effect, less context burned.
- **Asking Claude to summarize what it just did.** You can see the diff.

## Why these five

They map directly to the three failure modes ([01c-failure-modes.md](../foundations/01c-failure-modes.md)):

- **Drift** comes from goal ambiguity (principle 1) and bundled asks (principle 5).
- **Dilution** comes from over-stuffed context, often from violating principles 4 and 5.
- **Hallucination** comes from missing constraints (principle 3) — Claude fills the gap with a guess.

A prompt that respects all five is hard to write a confidently-wrong answer to.

## TL;DR

- Goal not steps. Show don't describe. Constraints up front. Scope-match. One ask.
- The inverse is what wastes tokens — politeness, context restating, file pasting, post-hoc summaries.
- Each principle blocks one failure mode.
