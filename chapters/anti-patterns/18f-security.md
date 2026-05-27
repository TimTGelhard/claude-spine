# 18f — Security anti-patterns

Security failures are the ones you can't undo. Each entry: the anti-pattern, why it fails, what to do instead. Many of these are also in the global `CLAUDE.md` security block — listed here for cross-reference and so the anti-pattern catalog is complete.

## Public env-var prefix on sensitive values

**Fails because:** anything prefixed with the framework's "public" marker ships to the browser bundle. Anyone with devtools can read it.
**Instead:** server-only env vars (no public prefix), accessed in route handlers / server actions / explicitly server-side modules.

## Privileged DB keys in shared `/lib/` files

**Fails because:** a shared lib file can be imported by a client component, which pulls the privileged key into the browser bundle.
**Instead:** put server-only code in clearly-marked server modules (e.g., `lib/server/db-admin.ts`). Make the boundary visible in the path.

## `catch (e) {}` — swallowed exceptions

**Fails because:** hides failures, makes debugging hell, masks security issues silently.
**Instead:** handle meaningfully, OR rethrow with context, OR don't catch.

## `throw new Error('failed')` with no detail

**Fails because:** unactionable for debugging. You get a stack trace pointing at "failed" and no idea why.
**Instead:** include the operation, relevant IDs, and what failed: `throw new Error(\`failed to create quote for profile ${profileId}: ${cause.message}\`)`.

## Logging PII or secrets to error trackers

**Fails because:** Sentry, PostHog, and similar tools persist payloads. GDPR exposure. A logged token is a leaked token.
**Instead:** log structured events without PII; redact secrets at the logger boundary.

## Editing an applied migration

**Fails because:** other environments will have the old version applied. Inconsistent state across dev / staging / prod.
**Instead:** write a new migration that supersedes. Migrations are forward-only.

## TL;DR

The pattern: anything that crosses a trust boundary (client/server, your-app/third-party, log/storage) needs a deliberate choice, not a default. The default is almost always insecure. The forbidden list in your global `CLAUDE.md` is the authoritative checklist — re-read it when in doubt.
