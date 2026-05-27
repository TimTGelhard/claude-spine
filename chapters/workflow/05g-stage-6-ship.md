# 05g — Stage 6: Ship

The final session. Everything is built, hardened, verified locally. Now it goes live.

## The ship sequence

- Smoke list passes locally.
- **Run `/security-review` on the full diff against `main`.** This is the dedicated audit, not a search by hand.
- **Optionally run `/ultrareview`** if the changes are significant. Cost is non-trivial but cheaper than shipping a regression.
- `npm audit` clean (or your language's equivalent).
- Migrations applied to production.
- Deploy.
- **After deploy: walk the smoke list *against production*** with real credentials.
- Consider `/verify` against the production URL to confirm the deploy is healthy end-to-end.
- For client work: write a short handover (login info, deploy process, contact, where the docs live).

## Why post-deploy smoke matters

A staging-only smoke pass doesn't prove production works. Real env vars, real DNS, real cache behavior, real third-party integrations only exist in production. The 10-minute post-deploy walk is the cheapest insurance you'll buy.

## What goes in the handover (client work)

- URL(s) — live, staging, admin if any.
- Login(s) — your account, the client's account if they have one.
- Deploy process — "merging to `main` deploys to production" or the equivalent.
- Where docs live — link to `ARCHITECTURE.md`, `DEPLOY.md`, `PROGRESS.md`.
- Who to contact for what — you for code, the client's domain registrar for DNS, etc.
- Known issues — anything you punted on with a note about when to revisit.

This file lives in `docs/HANDOVER.md` or similar. Without it, every "small change" three months later is a brownfield session — see [08a-discovery-sequence.md](08a-discovery-sequence.md).

## Anti-patterns

- **No production smoke.** "It worked on staging" is not the same as "it works in production."
- **Skipping `/security-review` at the final step.** It's the cheapest insurance for the highest-stakes moment.
- **No handover for client work.** Every future maintenance touch starts cold.

## TL;DR

- Smoke locally → security review → audit deps → deploy → smoke production → handover.
- The post-deploy smoke is the one that actually proves it works.
- For client work, the handover file is non-negotiable.
