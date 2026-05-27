# Smoke Tests — <PROJECT NAME>

> The 3-5 critical user flows that MUST work before any deploy.
> Walk these manually before declaring anything done.
>
> _Example flows (signup, dashboard, quote creation, RLS check) come from a Next.js + Supabase quote-management app. Replace with your critical paths — the structure (one flow per section, status legend, steps + expected outcome) is domain-agnostic._

## How to use

- Before merging to `main`: walk every flow in this file locally.
- After deploying: walk every flow on the deployed environment with real credentials.
- If any flow breaks, the deploy is broken — fix or roll back.

Add a new flow when a new critical capability ships. Remove a flow only if the feature is removed.

## Status legend

- ✅ Last verified <date>
- ❌ Last verified <date> — broken: <one-line reason>
- ⚠️ Not verified since major change

---

## Flow 1: New user signs up and lands on dashboard

**Status**: ⚠️

**Steps**:
1. Open in incognito.
2. Navigate to `/`.
3. Click "Sign up."
4. Enter test email + password.
5. Complete email verification.
6. Should land on `/dashboard` with empty state.

**Expected**: empty dashboard, no errors in console, session cookie set.

**Edge cases to also try**:
- Existing email → clear error message.
- Invalid password (too short) → clear error.
- Network slow → loading indicator shows.

---

## Flow 2: Returning user logs in

**Status**: ⚠️

**Steps**:
1. Open in incognito.
2. Navigate to `/login`.
3. Enter existing credentials.
4. Should land on `/dashboard` with their data.

**Expected**: data loads, session persists across refresh.

**Edge cases**:
- Wrong password → clear error.
- Logged out elsewhere → handled cleanly.

---

## Flow 3: Create and view a quote (or your core feature)

**Status**: ⚠️

**Steps**:
1. From `/dashboard`, click "New quote."
2. Fill in form with valid data.
3. Submit.
4. Should redirect to `/dashboard/quotes/<id>` showing the new quote.
5. Back to dashboard — new quote in list.

**Expected**: form submits cleanly, data persists, list updates.

**Edge cases**:
- Submit with empty required fields → field-level errors.
- Submit with very large amount → handled correctly (no overflow).
- Refresh mid-form → no data corruption.

---

## Flow 4: Authorization — user can't see another user's data

**Status**: ⚠️ — **most-important security flow**

**Steps**:
1. Log in as User A.
2. Note a quote ID owned by A.
3. Log out.
4. Log in as User B.
5. Navigate directly to `/dashboard/quotes/<A's ID>`.
6. Should get 404 or "not found" — never the actual quote.
7. Also: hit `/api/quotes/<A's ID>` directly with B's session. Should 403/404.

**Expected**: B sees nothing of A's. RLS holds even on direct URL access.

---

## Flow 5: Sign out

**Status**: ⚠️

**Steps**:
1. Logged in.
2. Click "Sign out."
3. Should redirect to `/`.
4. Try to navigate to `/dashboard`.
5. Should redirect to `/login`, not show stale data.
6. Browser back button shouldn't expose cached pages with session data.

**Expected**: clean session termination.

---

## Cross-cutting checks (do on the deployed environment)

- [ ] No console errors on any page load.
- [ ] No 404s on assets in network tab.
- [ ] Lighthouse mobile score ≥ 90 (for client sites) / ≥ 70 (for apps with auth).
- [ ] Open in actual mobile browser (not just devtools mobile view).
- [ ] Test on slow network (Chrome DevTools "Slow 3G").
- [ ] Dark mode works (if implemented).
- [ ] No secrets leaked in `_next/static/` JS files.

### Concrete commands

```bash
# Check no service-role key bled into client bundle
grep -r "service_role" .next/static/ 2>/dev/null && echo "❌ LEAKED" || echo "✅ clean"

# Check no Stripe secret key bled into client bundle
grep -rE "sk_(live|test)_" .next/static/ 2>/dev/null && echo "❌ LEAKED" || echo "✅ clean"

# Check no Anthropic key bled into client bundle
grep -r "sk-ant-" .next/static/ 2>/dev/null && echo "❌ LEAKED" || echo "✅ clean"

# Dependency audit
npm audit --omit=dev

# Typecheck + lint (must be green)
npm run typecheck && npm run lint

# Lighthouse from CLI (optional — install: npm i -g lighthouse)
lighthouse https://<project>.com --only-categories=performance,accessibility,best-practices,seo --form-factor=mobile --output=json --output-path=./lh.json --quiet
```

### Two-session RLS verification (auth apps only)

For auth-touching changes, this is the most-important security check.

```bash
# Terminal 1: log in as User A, note a resource ID
# Terminal 2: log in as User B
# In Terminal 2's browser, navigate directly to User A's resource URL
# Expected: 404 or "not found", NEVER the resource

# Also test via API directly:
curl -H "Cookie: <user-B-session-cookie>" https://<project>.com/api/quotes/<user-A-quote-id>
# Expected: 401, 403, or 404 — never 200 with A's data
```

If this returns A's data, every other test result is irrelevant — you have a critical security bug. Fix before any deploy.

---

## Pre-launch hardening checklist

Before the first real launch:

- [ ] All 5 flows above pass on production with real data.
- [ ] `npm audit` clean (or known issues documented and accepted).
- [ ] Search codebase for "TODO" / "FIXME" / "XXX" — address or accept each.
- [ ] Check for hardcoded secrets (`grep -r "sk_" .` etc).
- [ ] RLS verified on every table with user data.
- [ ] Delete-account flow exists and works.
- [ ] Privacy policy + terms exist (even if minimal).
- [ ] Error monitoring connected (Sentry or similar) — and confirmed it does NOT log PII.

---

Updated: YYYY-MM-DD
