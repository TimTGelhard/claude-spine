# op-prepare — the planning pass (procedure)

Loaded from [`SKILL.md`](SKILL.md). One dedicated session before any code. Output is plan files in `docs/`, nothing else. Done right, every subsequent session is cold-start-resistant and scope-locked.

## Step 1 — Announce the contract, then proceed

Open with a one-line statement of the contract: *"Planning pass — plan files only this session, no code. Scaffolding now."* **Do not ask "Continue?" or otherwise gate on a Y/N answer.** Claude cannot meaningfully wait for the answer mid-turn (the procedure runs in the same turn the user invoked `/prep` in), so a gate creates fake friction — the user already chose to run `/prep`; trust the choice.

If the user pushes back *during the flow* with "just start coding," push back once: this session locks scope for many future sessions — the upfront cost pays back 10x. If they still insist, hand off to `op-workflow` instead.

## Step 2 — Establish the brief

Check whether `docs/PROJECT_BRIEF.md` exists.

- **If it doesn't:** ask the user for the brief. One big prompt covering: what they're building, who for, key constraints, what success looks like, any non-negotiables (security, compliance, performance).

  **Before writing the file, check the answer is real.** If the response is a category-word ("a calorie tracker", "a CRM", "a marketplace") with no audience, no platform, no v1 cut — *do not* move on. Go to Step 2.5 first to fill the gaps. Writing `PROJECT_BRIEF.md` from a one-liner produces an architecture shaped for the wrong product.

  When you have enough to fill the template's required fields (audience, the one outcome, scope-IN, scope-OUT, constraints), write `docs/PROJECT_BRIEF.md` using `~/.claude-spine/templates/PROJECT_BRIEF.md` as scaffold.

- **If it does:** read it. Treat it as input. If big product-shape questions are still open (no audience, no platform, no v1 cut), run Step 2.5 anyway before architecture.

## Step 2.5 — Product shape (before any stack questions)

A product's shape determines the architecture. You cannot ask "which framework?" before you know mobile vs web vs CLI vs local-file. Run this step whenever the brief doesn't already answer all of these.

Ask in one round (not as a drip):

1. **Who's it for?** A specific persona — solo me / team of 5 / public SaaS users / power users on CLI. Not "everyone."
2. **Where does it live?** Mobile native (iOS/Android) / responsive web / desktop / local file (`file://`) / CLI / browser extension. This sets the whole stack.
3. **Primary user journey in v1** — the one flow that has to work end-to-end. ("Open app → log a meal → see day's total" — that level.)
4. **Top 3 features in v1.** Order them. Anything below #3 is v2.
5. **Top 3 things explicitly NOT in v1.** Forces naming the deferral — prevents creep.
6. **Single-user or multi-user?** Drives auth + RLS + sync model. "Just me on my laptop" is a valid answer.
7. **Online or offline-first?** Drives whether a backend exists, where state lives, sync strategy.

Cap at these 7. The point is to nail the *shape*, not every detail — detail belongs in section plans.

If the user's answers contradict their original one-liner, surface the conflict and ask which is the real version. Update `PROJECT_BRIEF.md` accordingly. Don't silently pick.

## Step 3 — Ask clarifying questions (only the ones that change the plan)

Now that product shape is clear, ask only what still affects:

- Section count or ordering
- Stack / architecture choices (the specific library/service picks, once the platform from Step 2.5 has narrowed the field)
- Security / compliance constraints
- Definition of "done" for the project as a whole
- Hard dependencies on external systems (Stripe approval, third-party API access, etc.)

For 2-3 architectural choices, surface alternatives with honest tradeoffs (per global CLAUDE.md). Never silently pick the first thing.

Cap at 5-7 questions in one round. More than that, you're trying to plan in detail what should be deferred to per-section planning.

## Step 4 — Draft `docs/ARCHITECTURE.md`

Stack, layout, data model, key boundaries. See `~/.claude-spine/chapters/workflow/05c-stage-2-architect.md` for what goes in.

Keep it high-level — schemas, route shape, where server/client boundary lives, what's in `lib/server` vs `lib/`. Not implementation detail.

## Step 5 — Draft `docs/PROJECT_PLAN.md`

Ordered sections with dependencies. Use `~/.claude-spine/templates/PROJECT_PLAN.md` as scaffold.

The right section list depends on the project type. Some templates:

**CRUD-shaped web app:**
1. foundation (scaffolding + first deploy)
2. auth (login + per-row-authorization baseline)
3..N. resources (one section per major resource)
N+1. integrations (payment provider, webhooks, email, file storage)
N+2. landing (public marketing pages — can run in parallel with resources)
N+3. hardening (states, perf, a11y, security review)
N+4. ship (deploy + post-deploy smoke)

**Backend service / API:**
1. foundation (scaffolding + health endpoint + first deploy)
2. auth + AuthZ baseline
3..N. domains (one section per bounded context — `payments`, `users`, `inventory`, etc.)
N+1. integrations (external SDKs, queues, schedulers)
N+2. observability (metrics, logs, traces, alerts)
N+3. hardening (rate limits, idempotency, retry)
N+4. ship

**CLI tool / library:**
1. foundation (scaffolding + first binary or first published version)
2. core API surface (the 1-3 commands or methods everything else depends on)
3..N. commands or features (one per cohesive capability)
N+1. distribution (release flow, package registry, install docs)
N+2. hardening (golden tests, fuzzing, fixture set)
N+3. ship (first public release)

**ML / data pipeline:**
1. foundation (data loaders + a baseline that runs end-to-end)
2. eval set + metrics
3..N. experiments (one section per hypothesis — "try X loss", "swap optimizer", etc.)
N+1. productionization (serving, monitoring, drift detection)
N+2. ship (handoff or first production deploy)

Adjust order to match real dependencies. Auth always before user-scoped resources. Per-row authorization planned in the section that introduces the data, not retro-fitted later. For libraries: lock the public API shape before downstream features depend on it.

Target: 5-12 sections for a typical MVP. More than 15, your sections are too granular — merge.

## Step 6 — Draft `docs/plans/<section-1>.md` — the FIRST section only

Use `~/.claude-spine/templates/SECTION_PLAN.md` as scaffold. Break the section into 2-5 sessions. For each session entry, compose the fields in this order — the order matters because the later fields are *inferred* from the earlier ones:

1. **Goal** — one line.
2. **Files to read** — the exact orient list a cold session loads.
3. **Build steps** — 3-7 high-level items.
4. **Files to write/edit** — propose from the build steps (Step 6.1), user edits.
5. **Verify** — scaffold from a recognized pattern when one matches (Step 6.2), otherwise ask for 2-4 concrete checks.
6. **Output** — commit-message hint + plan-file updates.

Keep each session entry under 100 lines. If it needs more, the session is too big — split.

### Step 6.1 — Infer the scope list from build steps (don't ask the user from scratch)

Read the build steps you just drafted. Propose the "Files to write/edit" list by inferring from them. Surface the proposal and ask "Edit this scope list before I write the session entry?" — the user adds, removes, or corrects. Never silently pick.

**Pick the right column from the table below based on the project's stack** (sniff `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / `Gemfile` / `pom.xml` if not already known; if the stack isn't in the table, use the closest match as a template and adapt). The build-step phrases are the rows; the file shapes are per-stack:

| Build-step phrase | Next.js / Supabase | Django / Django REST | FastAPI / SQLAlchemy | Rails | Go (net/http or gin) | Rust (axum / actix) | Java / Spring | Generic CLI (Go / Rust / Python) |
|---|---|---|---|---|---|---|---|---|
| **Create schema / Add table / Add migration** | `supabase/migrations/<ts>_<name>.sql` (RLS inline) | `apps/<app>/models.py` + `apps/<app>/migrations/<n>_<name>.py` | `app/models/<x>.py` + `alembic/versions/<rev>_<name>.py` | `db/migrate/<ts>_<name>.rb` + `app/models/<x>.rb` | `db/migrations/<n>_<name>.sql` (raw) or ORM equivalent | `migrations/<ts>_<name>.sql` (sqlx) or ORM equivalent | `src/main/resources/db/migration/V<n>__<name>.sql` (Flyway) | n/a — config or local file shape |
| **Per-row authorization / Per-user access** | Same migration as the table (RLS policies inline) | Permission class in `apps/<app>/permissions.py` + applied on each ViewSet | Dependency in `app/api/deps.py` checked per route | Pundit policy in `app/policies/<x>_policy.rb` | Middleware or per-handler check, with `userID` in context | Tower middleware + extractor per handler | Method-level `@PreAuthorize`; or service-layer guard | n/a |
| **Mutation endpoint (POST/PATCH/DELETE) / Server-side write** | `app/<route>/actions.ts` (server action `action<Verb><Noun>`) or `app/api/<x>/route.ts` | ViewSet method or APIView in `apps/<app>/views.py` | Router handler in `app/api/routes/<x>.py` | Controller action in `app/controllers/<x>_controller.rb` | Handler func in `internal/<feature>/handler.go` registered in `cmd/server/main.go` | Handler in `src/routes/<x>.rs` registered in `src/main.rs` | `@RestController` method | New subcommand in `cmd/<bin>/cmd/<x>.go` (cobra) or `src/cli/<x>.rs` (clap) |
| **Read endpoint / Query / List view** | Server component in `app/<route>/page.tsx` (RSC) or `app/api/<x>/route.ts` for JSON | ViewSet list/retrieve or APIView GET | Router GET handler | Controller `index` / `show` | Handler func + query helper | Handler + query func | `@GetMapping` method | Same subcommand pattern as above |
| **Input validation** | `app/<route>/schema.ts` or `lib/schemas/<x>.ts` (zod) | DRF serializer in `apps/<app>/serializers.py` | Pydantic model in `app/schemas/<x>.py` | Strong-params in controller + model validations | Struct tags + `validator.v10`; or per-handler decode | `serde` derive + `validator` crate | DTO class + `@Valid` + Bean Validation annotations | `flag` / `cobra` / `clap` argument types + custom validators |
| **UI surface (form / page / component)** | `app/<route>/page.tsx` + `components/<Feature>Form.tsx` (split server vs client) | Django template in `templates/<app>/<x>.html` + view-rendered form, or React frontend | Frontend separate from API (often Next.js or Vue) | ERB view in `app/views/<x>/`, or Hotwire / Stimulus | Frontend separate; or `templ` / `html/template` for SSR | Frontend separate; or `askama` for SSR | Thymeleaf in `src/main/resources/templates/`, or React frontend | n/a — CLIs render to stdout |
| **Webhook ingestion (Stripe / GitHub / external sender)** | `app/api/webhooks/<service>/route.ts` (verify signature → ack 2xx → enqueue/process) | View in `apps/<app>/views.py` mounted at a dedicated URL | Router in `app/api/webhooks/<service>.py` | Controller in `app/controllers/webhooks/<service>_controller.rb` | Handler in `internal/webhooks/<service>/handler.go` | Handler in `src/routes/webhooks/<service>.rs` | `@RestController` in `webhooks/<Service>Controller.java` | n/a (typically) |
| **Public / unauthenticated flow (contact form, public token-accept)** | `app/(public)/<route>/page.tsx` + matching server action | Public-prefix URL in `apps/<app>/urls.py` + `AllowAny` permission | Public router in `app/api/public/<x>.py` | Public namespace in `config/routes.rb` | Public route in router; no auth middleware | Public route; no auth middleware | `permitAll()` in security config for the route | n/a |
| **Send email / external notification** | Template under `lib/email/templates/` + call from `lib/server/email.ts` | `django.core.mail.send_mail` or `apps/<app>/services/email.py` + template in `templates/email/` | `app/services/email.py` (FastMail / Sendgrid) + Jinja template | `ActionMailer` class + view in `app/views/<mailer>_mailer/` | `internal/email/` package wrapping the provider SDK | `src/services/email.rs` wrapping the provider SDK | `@Service` class wrapping `JavaMailSender` | n/a |

Out-of-table stacks (PHP/Laravel, .NET, Elixir/Phoenix, Kotlin/Ktor, embedded, ML training scripts, data pipelines, etc.): use the closest column as a template and translate the file shapes. The discipline is the same — propose specific files, let the user edit. Never propose a generic "the relevant files" placeholder.

### Step 6.2 — Scaffold the Verify block from a recognized pattern

Generic "test it works" verify lists are the failure mode this step exists to prevent ([05j](../../../chapters/workflow/05j-cold-start-protocol.md) hard rule #4). Match the session's build steps + scope against the patterns below; when one matches, scaffold the Verify block with the listed concrete checks. The user refines (drops irrelevant rows, adds project-specific ones).

The patterns are named for the *concept*, not the framework. The checks are framework-agnostic; substitute "the auth table" / "the mutation endpoint" / "the per-row guard" for whichever object provides that concept in your stack:

| Pattern | Scaffold the Verify block with… |
|---|---|
| **Auth flow** (sign-up / sign-in / sign-out / protected route) | (a) sign-up form submits → user row appears in the auth store (Supabase `auth.users`, Django `auth_user`, custom users table, Cognito pool, etc.); (b) sign-in with wrong password returns a user-readable error, no session created; (c) sign-out clears session + redirects to a public page; (d) unauth client hitting a protected route is redirected / receives 401, not the page content. |
| **CRUD resource** (entity + list + form) | (a) Create → record appears in the datastore; (b) list view / GET endpoint renders the new record; (c) edit → record updated and re-rendered / re-fetched; (d) delete → record removed and disappears from list; (e) per-row authorization: a non-owner cannot read or mutate another user's record (see "Per-row authorization" pattern below for the precise checks). |
| **Mutation endpoint + UI** (server-side write driving a client surface) | (a) Happy path: endpoint returns the expected shape; UI / caller renders it; (b) error path: endpoint returns a user-readable error and the UI surfaces it (no raw stack / no leaked schema); (c) no PII (email, phone, address, payment info) in client logs, error payloads, or analytics events. |
| **Per-row authorization** (per-user / per-tenant data isolation — RLS, rules, IAM, decorators, app-layer guards) | (a) Non-owner session: read returns 0 records / 403; (b) owner session: read returns the record; (c) admin / service role behaves as designed (full access if intended, denied if not); (d) the *write* path that creates the data also ships its authorization rule — never land the table first and the policy in a later session. |
| **Public form** (unauthenticated input — contact, public token-accept, public webhook submit) | (a) Single-use token (if any) validated and consumed exactly once; (b) rate-limit returns 429 after N+1 attempts in the rate window; (c) bad input returns 400 with no leaked schema or stack; (d) honeypot / CAPTCHA / signed-form-token rejects the obvious bot pattern. |
| **Webhook ingestion** (Stripe, GitHub, Resend, any external sender) | (a) Signature / HMAC verification passes for a real-payload fixture; (b) verification fails for a tampered payload — 4xx, not 2xx; (c) duplicate event-id is idempotent (already-processed returns the same response, no double write); (d) processing errors logged with the event id but never surface PII or full payload. |
| **Migration-only session** (no UI surface) | (a) Migration applies forward cleanly on a clean DB; (b) drift check passes (`supabase db diff`, `python manage.py makemigrations --check`, `alembic check`, `bin/rails db:migrate:status`, `flyway info`, whichever your stack uses — no surprise changes); (c) regenerated types / models committed alongside the migration; (d) one-line rollback recipe captured in the migration file's comments or PR description. |
| **CLI subcommand** (new command on a CLI tool — `<bin> <subcmd>`) | (a) `<bin> <subcmd> --help` exits 0 and prints the subcommand's flags; (b) golden-output test on a `testdata/` fixture passes; (c) non-zero exit code on invalid input + error written to stderr (not stdout); (d) the README / man page row for this command is added or updated. |
| **Library public method** (new exported function / method on a library) | (a) Method's contract test green; (b) example in the docstring / README compiles and runs; (c) error paths return typed errors (not panic / unwrap / throw `Error("")`); (d) public-API change documented in CHANGELOG with a one-line migration note if breaking. |

If no pattern matches, ask the user for the 2-4 concrete checks — naming what would have to be true for this session's work to count as done. *Don't ship generic "test it works."* That defeats the verify-list discipline and turns `/done` into a rubber stamp.

### Step 6.3 — Compose the entry

Now write the entry: goal, files-to-read, files-to-write/edit (from Step 6.1), build steps, verify (from Step 6.2), output. Past 100 lines, split into two sessions.

**Do NOT pre-plan sections 2..N in detail.** Section plans drift as earlier sections discover real shape. The master plan stays in sync; only the active section plan is fully detailed.

## Step 7 — Initialize `docs/PROGRESS.md`

Use `~/.claude-spine/templates/PROGRESS.md`. Set:

- Active section: section 1
- Active session: session 1 from the section file
- Last session outcome: "(no sessions run yet)"
- Blockers: (empty)
- Next session reading list: copied from session 1's "Files to read" entry

## Step 8 — Hand back to user

Report concisely:

- `docs/PROJECT_BRIEF.md` — drafted (or read, if it existed)
- `docs/ARCHITECTURE.md` — drafted with: stack, layout, data model, boundaries
- `docs/PROJECT_PLAN.md` — drafted with N sections
- `docs/plans/<section-1>.md` — drafted with M sessions
- `docs/PROGRESS.md` — initialized, pointing at section 1 session 1
- Next step: user reviews. Push back welcomed before any code. When ready, open Claude in the project — the ambient `op-spine-active` skill loads scope and proceeds.

## When to draft subsequent section plans

Just-in-time, right before that section starts. Two options:

1. **User runs `/prep <section-name>`** to plan one section explicitly.
2. **Cold-start detects** the next active section has no plan file → halts and tells the user "section N has no plan; run `/prep <section-name>` first."

Don't draft section 2 during the section 1 planning pass — wait for section 1 work to inform it.

## Anti-patterns

- **Pre-planning every section in detail upfront.** Plans drift. Detail section N when section N starts.
- **Writing code in the planning pass.** Plans only. The next session executes.
- **Writing the brief from a one-liner.** "A calorie tracker" / "a CRM" / "a marketplace" is a *category*, not a brief. Without audience, platform, v1 cut, and explicit deferrals, the architecture you draft will fit the wrong product. Run Step 2.5 before committing the file.
- **Asking stack questions before product shape is clear.** "Which library should we use?" is meaningless until Step 2.5 has fixed mobile vs web vs CLI vs local-file. Product shape first, stack second.
- **Asking the user 20 clarifying questions.** Ask only what changes the plan structure. Defer rest to per-section planning.
- **Skipping the brief.** "I'll figure it out from chat messages" loses fidelity. Write the brief file.
- **Bloating session entries.** A session entry should be <100 lines. If it needs more, the session is too big — split.
- **Silently picking architectural choices.** Per global CLAUDE.md, surface 2-3 alternatives with tradeoffs before deciding.
- **Locking the plan as a contract.** Plans are working documents. Update them when reality diverges — see [05j](../../../chapters/workflow/05j-cold-start-protocol.md) "Hard rules".
