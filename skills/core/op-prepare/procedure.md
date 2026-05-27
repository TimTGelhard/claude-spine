# op-prepare — the planning pass (procedure)

Loaded from [`SKILL.md`](SKILL.md). One dedicated session before any code. Output is plan files in `docs/`, nothing else. Done right, every subsequent session is cold-start-resistant and scope-locked.

## Step 1 — Confirm we're planning, not coding

State to the user: "This is a planning pass. Output will be plan files in `docs/`, no code. Continue?"

If user says "just start coding," push back once: this session locks scope for many future sessions — the upfront cost pays back 10x. If they still insist, hand off to `op-workflow` instead.

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

Typical sections for a CRUD-shaped app:

1. foundation (scaffolding + first deploy)
2. auth (login + RLS baseline)
3..N. resources (one section per major resource)
N+1. integrations (Stripe, webhooks, email, file storage)
N+2. landing (public marketing pages — can run in parallel with resources)
N+3. hardening (states, perf, a11y, security review)
N+4. ship (deploy + post-deploy smoke)

Adjust order to match real dependencies. Auth always before user-scoped resources. RLS planned in the section that introduces the table, not retro-fitted later.

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

These heuristics cover the common cases; the user's stack may differ:

| Build-step phrase | Inferred files |
|---|---|
| "Create schema" / "Add table" / "Add migration" | `supabase/migrations/YYYYMMDDHHMMSS_<name>.sql` (single file; include RLS in the same migration as the table — see `~/.claude-spine/templates/CLAUDE.md` conventions) |
| "Add RLS policy" / "Per-user access" | Same migration as the table — no separate file |
| "Add API route" / "POST/GET/PATCH /api/<x>" | `app/api/<x>/route.ts` |
| "Add server action" / "Submit / save / update from form" | `app/<route>/actions.ts` (named `action<Verb><Noun>`) |
| "Wire UI" / "Form" / "Page" | `app/<route>/page.tsx` + `components/<Feature>Form.tsx` (split server vs client) |
| "Add zod schema" / "Validate input" | `app/<route>/schema.ts` or `lib/schemas/<x>.ts` |
| "Add a webhook handler" | `app/api/webhooks/<service>/route.ts` |
| "Add a public/unauth flow" (contact form, public quote-accept) | `app/(public)/<route>/page.tsx` + matching server action |
| "Send email" | A new template under `lib/email/templates/` + a Resend call from `lib/server/email.ts` |

When the project's stack isn't TypeScript + Next.js + Supabase, swap the file shapes — the table is the *recipe*, not the contract. The discipline is: propose, then let the user edit.

### Step 6.2 — Scaffold the Verify block from a recognized pattern

Generic "test it works" verify lists are the failure mode this step exists to prevent ([05j](~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md) hard rule #4). Match the session's build steps + scope against the patterns below; when one matches, scaffold the Verify block with the listed concrete checks. The user refines (drops irrelevant rows, adds project-specific ones).

| Pattern | Scaffold the Verify block with… |
|---|---|
| **Auth flow** (sign-up / sign-in / sign-out / protected route) | (a) sign-up form submits → row appears in `auth.users`; (b) sign-in with wrong password returns error toast, no redirect; (c) sign-out clears session and redirects to `/`; (d) unauth user hitting a protected route is redirected to `/login`. |
| **CRUD resource** (table + list + form) | (a) Create → row appears in DB; (b) list view renders the new row; (c) edit → row updated in DB and re-rendered; (d) delete → row removed and disappears from list; (e) RLS: a non-owner session cannot SELECT another user's row. |
| **API + UI** (server action or route handler driving a UI) | (a) Happy path: action returns the expected shape; UI renders it; (b) error path: action returns a user-readable error and UI surfaces it (no raw stack); (c) no PII (email/phone/address) in client logs or error payloads. |
| **RLS section** (introducing per-user data) | (a) Non-owner session: SELECT returns 0 rows; (b) owner session: SELECT returns the row; (c) admin / service role behaves as designed (full access if intended, denied if not); (d) the migration that creates the table also ships the RLS policy. |
| **Public form** (unauthenticated input — contact, public quote-accept) | (a) Single-use token validated and consumed; (b) rate-limit returns 429 after N+1 attempts in the rate window; (c) bad input returns 400 with no leaked schema; (d) honeypot/captcha rejects the obvious bot pattern. |
| **Webhook ingestion** (Stripe, Resend, etc.) | (a) Signature verification passes for a real-payload fixture; (b) verification fails for a tampered payload — 400; (c) duplicate event-id is idempotent (already-processed returns 200, no double write); (d) processing errors are logged with the event id but never surface PII. |
| **Migration-only session** (no UI surface) | (a) Migration applies forward cleanly; (b) `supabase db diff` shows no drift after apply; (c) regenerated types are committed (`supabase gen types`); (d) one-line rollback recipe captured in the migration file's comments. |

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
- **Locking the plan as a contract.** Plans are working documents. Update them when reality diverges — see [05j](~/.claude-spine/chapters/workflow/05j-cold-start-protocol.md) "Hard rules".
