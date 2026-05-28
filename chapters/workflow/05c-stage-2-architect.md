# 05c — Stage 2: Architect

Fresh terminal. The deliverable is `ARCHITECTURE.md` — the full system view that every future session reads first.

Time: 30–90 minutes with Claude.

## What goes in ARCHITECTURE.md

- **Stack** (versions pinned)
- **Data model** — tables / collections / entities + relationships, ASCII or Mermaid diagram
- **Routes / surfaces** — URL → page mapping for web; subcommand → handler for CLI; public API surface for libraries; topics + handlers for queue-driven services
- **Server / process boundaries** — what's a server action vs an API route vs an edge function vs a background worker vs a client call
- **Auth model** — who can do what, per-row / per-resource authorization strategy (Postgres RLS / Firestore rules / IAM / decorator-based / none-because-single-tenant)
- **External services** — payment provider, email, storage, an LLM provider, anything you call — what touches what
- **Cache + invalidation** (if relevant)
- **Deployment topology** — hosting / runtime + database + edge / CDN / queue / etc.

This is the source of truth for every future session. When you open a feature session, Claude reads this first.

## Push back here

This is the most important session to engage Claude as a thinking partner. Bad architecture decisions cost 10x later. Use **planner mode** (see [07d-planner-mode.md](07d-planner-mode.md)) heavily.

Good prompts for this stage:

- "Walk me through the auth flow. Where does the session live? What happens on token refresh?"
- "Show me the worst case: 1000 concurrent users on the dashboard. What breaks first?"
- "Where's the abstraction that would hurt us most if we picked wrong?"

Don't accept the first proposal. Get 2–3 options with tradeoffs. The friction up front saves rework after.

## Decisions go into DECISIONS.md

Every non-obvious architectural decision: write down what you chose, what you considered, and *why*. Future-you and future-Claude both need this — without the "why," the next session will re-litigate decisions that were already settled.

## Exit condition

`ARCHITECTURE.md` covers all the headings above with enough detail that a fresh Claude session could load it and propose a correct first feature without asking architectural questions.

## Common failure modes

- **Skipping straight to Stage 3** because "I'll figure out the architecture as I go." You'll discover the wrong-shape schema after building three features on it.
- **Accepting Claude's first proposal.** Defeats the point of planner mode.
- **Writing `ARCHITECTURE.md` after the first feature.** It's now post-hoc justification, not design.
- **No DECISIONS.md.** Architectural choices get re-derived (or contradicted) every session.

## TL;DR

- 30–90 minutes, fresh terminal.
- Output: `ARCHITECTURE.md` + initial `DECISIONS.md` entries.
- Planner mode, with explicit pushback. Don't take the first answer.
