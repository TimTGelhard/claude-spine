# 18h — Long-term project anti-patterns

What ages well vs what compounds badly over months. Each entry: the anti-pattern, why it fails, what to do instead.

## Shipping code you don't understand

**Fails because:** can't maintain, can't fix bugs in it, can't extend it. Every future change has to re-learn what should already be in your head.
**Instead:** if you don't understand a Claude-produced block, ask for an explanation (not modification), then refactor for clarity. See [17c-high-stakes-cases.md](../recovery/17c-high-stakes-cases.md), "I'm scared to touch the codebase."
*(Edge: third-party library internals, well-audited OSS dependencies, and battle-tested framework code earn a different treatment — you don't need a line-by-line mental model of how React's reconciler works to ship a React app. The anti-pattern is shipping your own application code you can't read, not depending on libraries you trust.)*

## Letting CLAUDE.md drift

**Fails because:** every session starts with stale instructions. Claude makes wrong assumptions, you spend tokens correcting, and the corrections don't persist.
**Instead:** update `CLAUDE.md` when conventions change. Make it part of "the convention changed" workflow, not a separate chore. See [12b-claudemd.md](../persistence/12b-claudemd.md).

## Treating memory as a kitchen sink

**Fails because:** stale memories pollute future sessions. Claude recalls them with the same confidence as fresh ones, and acts on facts that aren't true anymore.
**Instead:** prune the auto-memory index periodically. Delete what's no longer true. Memory is for facts that earn their keep — not a journal. See [12c-memory.md](../persistence/12c-memory.md).

## Adding dependencies casually

**Fails because:** each dep is a supply chain risk, a maintenance cost, and bundle bloat. The cost shows up six months later when you can't upgrade or one of them publishes a malicious version.
**Instead:** justify each new dep in one line. Reject if you can do it in stdlib + 20 lines. Audit before any production push.

## "Claude built it, so it's tested"

**Fails because:** Claude tests against its own assumptions of how the feature should behave, not against your users' reality. The tests pass because they validate what Claude wrote, not whether it's correct.
**Instead:** manual smoke tests against real flows. Real browser. Real devices. See [18e-verification.md](18e-verification.md).

## TL;DR

Long-term failures are mostly *drift* — code, docs, memory, and dependencies all rot if you don't actively maintain them. The fix is small ongoing maintenance (prune memory, update CLAUDE.md, justify deps) rather than a big cleanup later. Big cleanups don't happen.
