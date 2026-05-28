# Deploy — <PROJECT NAME>

> The runbook. Step-by-step for every deploy, every time.
> If a step is missing, add it after the deploy that revealed the gap.
>
> _Stack-agnostic shape. For a fully-filled Next.js-on-Vercel + Supabase example plus a static-site-via-SSH variant, see `templates/examples/web-saas-next-supabase/DEPLOY.md`. Other shapes you might fill this in for: Docker registry push, Kubernetes / Helm, AWS Lambda / SAM, GCP Cloud Run, library publish (`npm publish` / `cargo publish` / `pypi`), GitHub Releases binary, App Store / Play Store, homebrew / chocolatey._

## Environments

| Name | URL / target | Hosted on | Branch / trigger |
|------|--------------|-----------|-------------------|
| local | `<localhost / dev binary>` | dev machine | `<run command>` |
| preview / branch | `<per-branch URL or build artifact>` | `<host>` | every PR |
| staging | `<staging URL>` | `<host>` | `<branch / tag>` |
| production | `<prod URL>` | `<host>` | `<branch / tag>` |

`<datastore environment story — local / preview / staging / prod isolation, branch-based, or shared>`

## Secrets / env vars

See `.env.example` for the full list. Where each lives:

- **local**: `.env.local` / `.envrc` / shell rc (gitignored)
- **`<deploy host>`**: dashboard or platform-native env-var store (per environment)
- **`<datastore / external service>`**: only the secrets that live in the provider dashboard — never committed

Confirm parity before deploy: pull the deploy env and diff against `.env.example`.

## Pre-deploy checklist

Before any deploy to production:

- [ ] All smoke tests in `SMOKE_TESTS.md` pass locally.
- [ ] Typecheck / compile / build clean.
- [ ] Lint clean (or known-acceptable warnings).
- [ ] Dependency audit clean (no high/critical, or documented exceptions).
- [ ] `git status` — clean working tree.
- [ ] Change reviewed (if multi-person) or self-review of `git diff <base>` complete.
- [ ] Schema / data-model changes to be applied? List them.
- [ ] Env vars to be added? List them.
- [ ] Generated artifacts (types, OpenAPI, RPC stubs) regenerated and committed if applicable.

## Deploy steps — production

### 1. Apply schema / data changes FIRST (if any)

```bash
# Inspect what will run
<your migration tool's --dry-run / list>

# Apply
<your migration tool's apply>

# Verify on the target environment
<your verification command>
```

⚠️ If a data-layer change fails partway, STOP. Don't push the code. Resolve datastore state first.

### 2. Push code / publish artifact

```bash
<the specific publish step for your stack — push to main, build + push container, `npm publish`, `cargo publish`, `gh release create`, `eas submit`, etc.>
```

`<note any auto-deploy behavior triggered by the push>`

### 3. Verify deploy

- [ ] Build / publish pipeline green.
- [ ] Production target reachable / installable.
- [ ] Walk `SMOKE_TESTS.md` against production.
- [ ] Check error / metric monitoring for the next 10 minutes.

### 4. Update PROGRESS.md

Note the deploy: date, version / commit SHA / artifact ID, what shipped.

## Rollback

### `<primary deploy target>`

`<the specific rollback procedure — dashboard "promote previous deployment", `kubectl rollout undo`, `helm rollback`, deploy previous artifact, etc.>`

If the bad deploy included an irreversible schema / data change: rollback is HARDER. You may need a forward fix (a new migration that undoes the change), not a rollback. Document the rollback recipe at change-author time.

### `<secondary deploy target, if any>`

`<the specific rollback procedure>`

## Post-incident

If a deploy caused production issues:

1. Roll back first, investigate after.
2. Add the missing check to the pre-deploy checklist above.
3. Update SMOKE_TESTS.md with the flow that should have caught it.

The runbook should grow over time. A deploy that surprised you reveals a missing step.

## DNS / domain (if applicable)

- Registrar: `<name>`
- DNS records: `<provider>`
- TTL: `<value>`
- Cert: `<managed by / renewal mechanism>`

For DNS changes: make them, but expect 5-60 min propagation. Don't try to verify in the first 5 min.

---

Updated: YYYY-MM-DD
