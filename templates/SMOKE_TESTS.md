# Smoke Tests — <PROJECT NAME>

> The 3-5 critical flows that MUST work before any deploy.
> Walk these manually (or run a green check on an automated proxy) before declaring anything done.
>
> _Stack-agnostic shape. For a fully-filled auth-app example (Next.js + Supabase: signup, login, CRUD, RLS isolation, signout), see `templates/examples/web-saas-next-supabase/SMOKE_TESTS.md`. Other shapes you might fill this in for: CLI command exit codes + stdout snapshots; library contract tests + example-snippet compile; service health endpoint + load profile + per-domain contract; ML model evaluation set + regression-vs-baseline + drift signal._

## How to use

- Before merging to the deploy branch: walk every flow in this file (locally or against a preview environment).
- After deploying: walk every flow on the deployed environment with real credentials / real data.
- If any flow breaks, the deploy is broken — fix or roll back.

Add a new flow when a new critical capability ships. Remove a flow only if the feature is removed.

## Status legend

- ✅ Last verified <date>
- ❌ Last verified <date> — broken: <one-line reason>
- ⚠️ Not verified since major change

---

## Flow 1: `<name of the most important flow>`

**Status**: ⚠️

**Steps**:
1. `<step 1>`
2. `<step 2>`
3. `<step N>`

**Expected**: `<what success looks like — observable, not "it works">`

**Edge cases to also try**:
- `<edge case 1 + expected behavior>`
- `<edge case 2 + expected behavior>`

---

## Flow 2: `<next critical flow>`

**Status**: ⚠️

**Steps**:
1. …

**Expected**: …

---

## Flow 3, 4, 5: …

(Aim for 3-5 flows total. More than 5 and they probably aren't all critical — promote the most important ones, drop the rest into per-feature tests.)

---

## Cross-cutting checks (on the deployed environment)

Pick the ones that apply to your surface:

- [ ] **All projects**: no leaked secrets in artifacts you ship (binaries, JS bundles, container layers, package archives) — grep for the secret prefixes used by your providers.
- [ ] **All projects**: dependency audit clean for direct deps + transitive.
- [ ] **Browser-driven (web apps, marketing sites, dashboards)**: no console errors on any page load; no 404s on assets; Lighthouse mobile ≥ 90 for marketing sites / ≥ 70 for auth apps; works in real mobile browser (not just devtools mobile view); slow-network behavior (Slow 3G) reasonable.
- [ ] **APIs / services**: health endpoint returns 200 under nominal + degraded conditions; contract test against the consumers green; rate-limit + auth headers behave as specified.
- [ ] **CLIs**: `<bin> --help` exits 0; `<bin> --version` matches the release tag; the documented happy path on README runs against `testdata/` and matches golden output.
- [ ] **Libraries**: the example in the README compiles + runs; published artifact has the expected files (no test fixtures, no `.env`, no secrets); CHANGELOG entry exists for this version.
- [ ] **ML / data**: model evaluation on the held-out set matches or beats the previous version's score; drift signal on production data is within threshold; canary inference passes.

### Per-stack concrete commands

(Drop the ones that don't apply; add yours.)

```bash
# JS / TS bundles: check no server-side secret leaked to client
grep -rE "(service_role|sk_(live|test)_|sk-ant-)" .next/static dist build 2>/dev/null \
  && echo "❌ LEAKED" || echo "✅ clean"

# Python: dependency audit
pip-audit  # or: safety check

# Go: module-level audit
go list -m -u all ; govulncheck ./...

# Rust: audit advisory DB
cargo audit

# Ruby: bundler audit
bundle audit --update

# JS / TS: dependency audit
npm audit --omit=dev  # or: pnpm audit, yarn audit

# Typecheck / build (must be green for your stack)
<typecheck command> && <lint command>
```

### Per-user / per-tenant authorization verification (for any multi-user app)

For auth-touching changes, this is the most-important security check. The pattern is the same regardless of stack:

1. Authenticate as User A; note an ID of a resource owned by A.
2. Authenticate as User B (different account, no shared role).
3. From B's session, try to read or modify A's resource — direct URL access, direct API call, GraphQL query, RPC, whatever surfaces exist.
4. **Expected**: B sees nothing of A's. The check must hold even when B knows the exact ID.

If B can read A's data with any technique, every other test result is irrelevant — fix before any deploy.

---

## Pre-launch hardening checklist

Before the first real launch:

- [ ] All flows above pass on production with real data.
- [ ] Dependency audit clean (or known issues documented and accepted).
- [ ] Search codebase for "TODO" / "FIXME" / "XXX" — address or accept each.
- [ ] Check for hardcoded secrets (grep for your provider's secret prefixes).
- [ ] Per-row / per-resource authorization verified on every multi-user surface.
- [ ] User-data deletion flow exists and works (if you store user data — required by GDPR / CCPA for many surfaces).
- [ ] Privacy policy + terms exist (even if minimal).
- [ ] Error monitoring connected and confirmed it does NOT log PII.

---

Updated: YYYY-MM-DD
