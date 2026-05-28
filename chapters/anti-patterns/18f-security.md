# 18f — Security anti-patterns

Security failures are the ones you can't undo. Each entry: the anti-pattern, why it fails, what to do instead. This catalog is the authoritative checklist — your global `CLAUDE.md` may carry a short version for quick reference, but the long form lives here.

Unlike the other 18x files (where most rules are strong defaults with edge cases), most entries below are **intentionally absolute** — the cost of getting them wrong (secret exfiltration, SQL injection, auth bypass) is too high to leave to judgment. The few entries with legitimate variation (CORS `*` on public endpoints, when `catch (e)` makes sense, when `throw new Error('failed')` is acceptable as an intermediate-wrap) name the variation inline. If you find yourself wanting to relax a rule that has no inline edge case, double-check whether you're actually in one of the rare exceptions — most attempts at "this case is different" turn out to be the exact pattern this file warns against.

## Hardcoded secrets in source

**Fails because:** secrets in source survive deletion (git history), spread on every clone, and leak the moment a repo flips public. Rotating them is painful.
**Instead:** `.env*` files only, gitignored. Commit a `.env.example` with placeholder values. Fail loud at startup if a required key is missing.

## Public env-var prefix on sensitive values

**Fails because:** anything prefixed with the framework's "public" marker (`NEXT_PUBLIC_`, `EXPO_PUBLIC_`, `VITE_`) ships to the browser bundle. Anyone with devtools can read it.
**Instead:** server-only env vars (no public prefix), accessed in route handlers / server actions / explicitly server-side modules. Public prefixes are for browser-safe values only (site URL, anon keys, public analytics IDs).

## Privileged DB keys in shared `/lib/` files

**Fails because:** a shared lib file can be imported by a client component, which pulls the privileged key into the browser bundle.
**Instead:** put server-only code in clearly-marked server modules (e.g., `lib/server/db-admin.ts`). Make the boundary visible in the path.

## Direct frontend → privileged API

**Fails because:** any API key shipped to the client is a leaked key. Stripe secret, Anthropic / OpenAI keys, SMTP creds — once they hit the browser, treat them as compromised.
**Instead:** route every call to a paid or privileged API through a server action, API route, or edge function. Frontend only ever talks to your own server.

## SQL with string-interpolated user input

**Fails because:** SQL injection. One quote in the wrong place exfiltrates the table.
**Instead:** parameterized queries always (`$1`, `?`, the ORM's binding syntax). Treat *every* user-shaped value as hostile.

## `eval()` / `new Function()` on user-derived input

**Fails because:** arbitrary code execution. There is no safe way to do this.
**Instead:** don't. Use a parser, a sandbox, or refuse the use case. If you genuinely need dynamic evaluation, route through a dedicated sandbox runtime — never the host process.

## JWTs / session tokens in localStorage or sessionStorage

**Fails because:** any XSS on the page can read the entire storage object and exfiltrate the token. There is no browser-side mitigation.
**Instead:** httpOnly + secure + sameSite=lax cookies. Server reads them; JS can't.

## RLS disabled on tables with user data

**Fails because:** without row-level security, the anon key reads every row. "We'll add it later" usually means "we shipped without it."
**Instead:** RLS on every user-data table from day 1. Policies written in the same migration as the table. Test from two sessions — owner and non-owner. "It compiled" is not "it's secure."

## `Access-Control-Allow-Origin: *` on routes returning user data

**Fails because:** any origin (including malicious sites the user happens to be logged into) can read responses. Cookies still get sent if `credentials: 'include'`.
**Instead:** explicit allow-list of trusted origins. For unauthenticated public endpoints `*` is fine; for anything touching user data, never.

## `catch (e) {}` — swallowed exceptions

**Fails because:** hides failures, makes debugging hell, masks security issues silently. A swallowed auth-check exception is an auth bypass.
**Instead:** handle meaningfully, OR rethrow with context, OR don't catch.

## `throw new Error('failed')` with no detail

**Fails because:** unactionable for debugging. You get a stack trace pointing at "failed" and no idea why.
**Instead:** include the operation, relevant IDs, and what failed: `throw new Error(\`failed to create quote for profile ${profileId}: ${cause.message}\`)`.

## Logging PII or secrets to error trackers

**Fails because:** Sentry, PostHog, and similar tools persist payloads. GDPR exposure. A logged token is a leaked token.
**Instead:** log structured events without PII; redact secrets at the logger boundary. Never log full request bodies or raw LLM prompts/responses.

## Editing an applied migration

**Fails because:** other environments will have the old version applied. Inconsistent state across dev / staging / prod.
**Instead:** write a new migration that supersedes. Migrations are forward-only.

## TL;DR

The pattern: anything that crosses a trust boundary (client/server, your-app/third-party, log/storage) needs a deliberate choice, not a default. The default is almost always insecure. Re-read this catalog when in doubt — and when adding a project- or stack-specific item, add it to *this* file (the spine), not just your project's CLAUDE.md.
