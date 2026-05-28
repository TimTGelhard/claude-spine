---
name: op-brownfield
description: Use when entering a codebase you didn't build, returning to your own project after months away, inheriting client code, extending a site months after launch, or about to modify code where you couldn't answer "what does this file do" in one sentence. Covers the discovery sequence, safe first changes, teaching Claude an unfamiliar codebase, and when a rewrite is the right answer. Routes to chapter 08 (brownfield) of claude-spine.
---

# op-brownfield — inherited code and returning to old projects

Greenfield's risk is over-engineering. Brownfield's risk is **breaking working code through ignorant changes.** Different discipline.

## Index

| Question / situation | Atomic file |
|---|---|
| Where do I start in an unfamiliar codebase? Discovery sequence? | `~/.claude-spine/chapters/workflow/08a-discovery-sequence.md` |
| First-change patterns — how do I ease in safely? | `~/.claude-spine/chapters/workflow/08b-safety-patterns.md` |
| How do I orient Claude to a codebase it's never seen? | `~/.claude-spine/chapters/workflow/08c-teaching-unfamiliar.md` |
| Should I rewrite this or extend it? Brownfield anti-patterns? | `~/.claude-spine/chapters/workflow/08d-rewrites.md` |

## How to use

1. If the user is returning to old code or entering an inherited codebase: start with `08a` — discovery sequence.
2. If they're about to change something they don't yet understand: `08b` — safety patterns.
3. If they're prompting Claude to "just look at this codebase and tell me what to do": `08c` — teaching unfamiliar.
4. If they're saying "this should be rewritten": `08d` — the rewrite urge is usually premature.

## Common triggers

- "Coming back to this project after months." → 08a
- "Inheriting a client's code." → 08a + 08c (security checks)
- "I want to clean up this weird code I just found." → 08b (Pattern C — comment, don't rewrite)
- "Claude doesn't know this codebase." → 08c (orientation prompt)
- "Should I just rewrite this?" → 08d (run discovery first)

## Sibling skills

- The 7-stage greenfield workflow → `op-workflow`.
- Picking the right collaboration mode for the brownfield session → `op-collaboration-modes` (explainer mode is usually right for first contact).
