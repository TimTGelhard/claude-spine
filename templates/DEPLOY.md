# Deploy — <PROJECT NAME>

> The runbook. Step-by-step for every deploy, every time.
> If a step is missing, add it after the deploy that revealed the gap.

## Environments

| Name | URL | Hosted on | Branch / trigger |
|------|-----|-----------|-------------------|
| local | http://localhost:3000 | dev machine | `npm run dev` |
| preview | <pr-slug>.vercel.app | Vercel | every PR |
| staging | staging.<project>.com | Vercel | `staging` branch |
| production | <project>.com | Vercel | `main` branch |

DB:
- local: Supabase local (`supabase start`)
- preview/staging/prod: same Supabase project (single env for MVP — split when needed)

## Secrets / env vars

See `.env.example` for the full list. Where each lives:

- **local**: `.env.local` (gitignored)
- **Vercel**: Vercel dashboard → Settings → Environment Variables (per environment)
- **Supabase**: only the dashboard secrets (service_role) — never committed

Confirm parity before deploy: `vercel env pull .env.preview` and diff against `.env.example`.

## Pre-deploy checklist

Before any deploy to production:

- [ ] All smoke tests in `SMOKE_TESTS.md` pass locally.
- [ ] `npm run typecheck` — clean.
- [ ] `npm run lint` — clean (or known-acceptable warnings).
- [ ] `npm audit` — no high/critical (or documented exceptions).
- [ ] `git status` — clean working tree.
- [ ] PR reviewed (if multi-person) or self-review of `git diff main` complete.
- [ ] Migrations to be applied? List them: ______.
- [ ] Env vars to be added? List them: ______.
- [ ] Schema changes regenerated types? (`supabase gen types typescript`).

## Deploy steps — production (Vercel + Supabase)

### 1. Apply migrations FIRST (if any)

```bash
# Verify what will be applied
supabase migration list

# Apply to production
supabase db push

# Verify on remote
supabase migration list --linked
```

⚠️ If migration fails partway, STOP. Don't push the code. Resolve DB state first.

### 2. Push code

```bash
git checkout main
git pull
git merge --ff-only <feature-branch>   # or use PR merge in GitHub
git push origin main
```

Vercel auto-deploys from `main`.

### 3. Verify deploy

- [ ] Vercel build green (check dashboard).
- [ ] Production URL loads.
- [ ] Walk `SMOKE_TESTS.md` against production with real credentials.
- [ ] Check error monitoring (Sentry/PostHog) for new errors in the next 10 minutes.

### 4. Update PROGRESS.md

Note the deploy: date, commit SHA, what shipped.

## Deploy steps — static client site (VPS via SSH/SCP)

### 1. Build

```bash
npm run build
```

### 2. Quality gates

- [ ] Lighthouse mobile ≥ 90 (Performance, Accessibility, Best Practices, SEO).
- [ ] WCAG AA contrast on all text.
- [ ] JSON-LD `LocalBusiness` present.
- [ ] Locale set correctly (`lang="<xx>"`, dates, phone, postcode formats).
- [ ] Contact form server endpoint working — test with real submission.
- [ ] All `alt` attributes on images.
- [ ] Visible focus states on interactive elements.

### 3. Upload to staging

```bash
# Replace <host> with your VPS hostname
scp -r dist/* user@<host>:/var/www/staging.<client>/
```

### 4. Visual check

- [ ] Open staging URL.
- [ ] Walk every page.
- [ ] Test on real iPhone Safari AND Android Chrome.
- [ ] Submit contact form, verify email arrives.

### 5. Promote to production

```bash
# Replace <host> with your VPS hostname
ssh user@<host> 'mv /var/www/live.<client> /var/www/archive-<date>'
ssh user@<host> 'mv /var/www/staging.<client> /var/www/live.<client>'
```

### 6. Verify production

- [ ] Production URL loads.
- [ ] Spot-check Lighthouse again on the live URL (CDN can differ from staging).
- [ ] Send client the link.

## Rollback

### Vercel (apps)

In Vercel dashboard → Deployments → find last-known-good → "Promote to Production."

If the bad deploy included a DB migration: rollback is HARDER. You may need a new migration to undo the change, not a rollback. Forward-only.

### Client site (VPS)

```bash
ssh user@<host> 'mv /var/www/live.<client> /var/www/broken-<date>'
ssh user@<host> 'mv /var/www/archive-<latest> /var/www/live.<client>'
```

## Post-incident

If a deploy caused production issues:

1. Roll back first, investigate after.
2. Add the missing check to the pre-deploy checklist above.
3. Update SMOKE_TESTS.md with the flow that should have caught it.

The runbook should grow over time. A deploy that surprised you reveals a missing step.

## DNS / domain

- Registrar: <name>
- DNS records: <Cloudflare / Vercel / etc>
- TTL: 3600s
- Cert: managed by Vercel (auto-renewed)

For DNS changes: make them, but expect 5-60 min propagation. Don't try to verify in the first 5 min.

---

Updated: YYYY-MM-DD
