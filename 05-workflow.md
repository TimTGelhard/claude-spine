> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/workflow/`](chapters/workflow/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 05 — Workflow: from idea to shipped

The seven-stage project process. Each stage has a clear goal, deliverable, and exit condition.

## The seven-stage workflow

```
0. Decide       → Is this worth building? Scope it.
1. Prep         → Markdown files, stack, dependencies, decisions.
2. Architect    → Schema, routes, components, security boundaries.
3. Build        → One feature per session, with verification.
4. Integrate    → Wire features together, smoke test.
5. Harden       → Edge cases, error states, accessibility, perf.
6. Ship         → Deploy + monitor + retro.
```

Most of your projects skip stage 0 (going straight to building) and stage 5 (calling demoable "done"). Both are expensive omissions.

---

## Stage 0 — Decide (15-60 min)

Before you open Claude Code, answer these in writing:

- **Who is this for?** Specific user, not "people."
- **What's the one user-visible outcome?** The thing they can do after this exists that they can't do now.
- **What's the smallest version that still delivers that outcome?**
- **What are you NOT building?** The explicit non-goals.
- **Kill criteria.** When would you abandon this?

If you can't answer these clearly, Claude won't save you — you'll churn in build sessions on questions you should have settled cold.

**Output:** `templates/PROJECT_BRIEF.md` filled in.

---

## Stage 1 — Prep (1-2 hours, with Claude)

Open a fresh terminal. **Don't write any code in this session.** This is pure scaffolding.

### Tasks (in order)
1. Create the project directory, init git, push empty repo.
2. Set up the stack (Next.js + Supabase / Expo / static HTML — per global CLAUDE.md defaults).
3. Write project-level `.claude/CLAUDE.md` — covered in [12-skills-memory-claudemd.md](12-skills-memory-claudemd.md).
4. Copy templates from this repo's `templates/` folder into project:
   - `PROJECT_BRIEF.md` (from Stage 0)
   - `ARCHITECTURE.md` (fill in stack, data model sketch)
   - `PROGRESS.md` (initial state: empty)
   - `DECISIONS.md` (empty, but committed)
   - `SMOKE_TESTS.md` (the 3-5 critical flows, before you build them)
5. Lock dependencies (`package.json`, lockfile committed).
6. `.env.example` with all keys you'll need (placeholders).
7. First DB migration (auth + base tables if applicable). RLS from day 1.
8. Smoke test the empty app — does it run?

### Where to ask Claude questions vs decide yourself
- **Ask Claude:** "what's the cleanest schema for this?" "should this be one table or two?" "what's the idiomatic Next.js 16 pattern for this?"
- **Decide yourself:** brand, color, copy, UX choices, what the product *feels* like.

End stage 1 with a working "hello world" deploy. Commit, push, deploy to Vercel preview. *Before any feature exists.*

---

## Stage 2 — Architect (30-90 min, with Claude)

Fresh terminal again. This session produces `ARCHITECTURE.md` with the full system view.

### What goes in ARCHITECTURE.md
- **Stack** (versions pinned)
- **Data model** (tables + relationships, ASCII or Mermaid diagram)
- **Routes** (URL → page mapping)
- **Server boundaries** (what's a server action, what's an API route, what's an edge function)
- **Auth model** (who can do what, RLS strategy)
- **External services** (Stripe, Resend, R2, Anthropic — what touches what)
- **Cache + invalidation** (if relevant)
- **Deployment topology** (Vercel + Supabase, etc.)

This is the source of truth for every future session. When you open a feature session, Claude reads this first.

### Push back here
This is the most important session to engage Claude as a thinking partner. Bad architecture decisions cost 10x later.

- "Walk me through the auth flow. Where does the session live? What happens on token refresh?"
- "Show me the worst case: 1000 concurrent users on the dashboard. What breaks first?"
- "Where's the abstraction that would hurt us if we picked wrong?"

Don't accept the first proposal. Get 2-3 options with tradeoffs.

---

## Stage 3 — Build (one feature per session)

Each feature gets its own fresh terminal. Per-session ritual:

1. **Orient** — "Read CLAUDE.md, ARCHITECTURE.md, PROGRESS.md, and these files: [list]. Tell me what we're doing this session."
2. **Confirm scope** — "We're building X. Not building Y or Z. Agree?"
3. **Plan** — Claude proposes the approach (use `EnterPlanMode` for non-trivial features). You approve or push back.
4. **Build** — actual edits, in small commits if possible.
5. **Verify** — run the app, walk the smoke list for this feature, hit the API for real.
6. **Update `PROGRESS.md`** — what's done, what's next, what's blocked.
7. **Commit + push.**

If at any point Claude is contradicting itself or you've corrected the same misunderstanding twice → restart the session.

### Plan mode vs straight-to-code
Use plan mode (`ExitPlanMode` is the tool, plan mode is the state) when:
- The feature touches >5 files or >2 layers.
- There's a security boundary involved.
- You're not sure of the right approach.

Skip plan mode for:
- Single-file bug fixes.
- Mechanical tweaks (copy change, color change, one-line fix).

### Claude's signaling responsibilities during a build session

Per [11-proactive-signaling.md](11-proactive-signaling.md), Claude should signal proactively at these in-session checkpoints — the user shouldn't have to ask:

- **Mid-session if context fills** → flag the yellow-zone crossing, recommend wrapping after the current task.
- **When scope creeps** (8+ files, 4+ decisions, or the ask grew mid-session) → flag and offer to split.
- **When drift appears** (re-suggesting ruled-out ideas, repeated misunderstanding) → flag and recommend restart.
- **Before declaring done** → name the missing verification (run the app, run smoke list, two-session RLS for auth changes).
- **At natural stopping points** → prompt to commit + update PROGRESS.md / DECISIONS.md / FEATURES.md.

These signals are recommendations, not refusals. The user can always say "continue anyway." But the user shouldn't have to be the one tracking these — that's Claude's job as the senior dev in the room.

---

## Stage 4 — Integrate (after every 3-5 features)

Don't let features pile up un-integrated. Every few features, run an integration session:

- Walk the full user journey, not just the feature you just built.
- Test the boundaries between features (does login → dashboard → settings actually flow?).
- Re-run smoke tests in `SMOKE_TESTS.md`.
- Catch regressions early.

If you find regressions, fix them in a dedicated session — don't bundle with the next feature.

---

## Stage 5 — Harden (1-3 sessions, end of project)

This is the stage everyone skips. It's where the bugs that kill the launch live.

Walk the feature-completeness checklist from your global CLAUDE.md for each major surface:

- Empty / loading / error states present?
- Dark mode (if relevant)?
- i18n (no hardcoded strings if it's not English-only)?
- Time zones / locales (UTC in DB, locale in UI)?
- Mobile keyboard doesn't obscure inputs?
- Slow network doesn't break the screen?
- Accessibility: alt text, focus states, screen reader hints?
- Lighthouse / Web Vitals if web?
- RLS verified from two sessions if auth?

For each: open a session focused on that one cross-cutting concern.

**Slash commands that earn their keep at this stage:**
- `/code-review` — diff correctness review of recent changes.
- `/security-review` — independent security audit. Run this if auth, payments, or PII has been touched.
- `/verify` — end-to-end verification: drives the running app, walks the flow, confirms it actually works.
- `/ultrareview` — heavyweight multi-agent review before merging a significant branch / PR. **User-triggered only** — Claude can't launch this one. Pass `<PR#>` for a GitHub PR or no arg for the local branch.

These beat ad-hoc manual review at this stage. Use them.

---

## Stage 6 — Ship

- Smoke list passes.
- **Run `/security-review` on the full diff against `main`.** This is the dedicated audit, not a search by hand.
- **Optionally run `/ultrareview`** if the changes are significant. Cost is non-trivial but cheaper than shipping a regression.
- `npm audit` clean.
- Migrations applied to production.
- Deploy.
- After deploy: walk the smoke list **against production** with real credentials.
- Consider `/verify` against the production URL to confirm the deploy is healthy end-to-end.
- For client work: write a short handover (login info, deploy process, contact).

---

## Anti-patterns to avoid

- **"Just have Claude figure it out."** If you don't know what you want, Claude will pick something and you'll discover you hate it later. Decide at stage 0.
- **"I'll do markdown files after the MVP works."** No, you won't. And without them, every session re-derives the project from scratch.
- **"One big PR at the end."** Massive diffs hide bugs. Commit per feature.
- **"Skip stage 5, the user won't notice."** They will. Missing-state bugs are the most common production issues.
- **Combining stages in one session.** Especially "prep + first feature" — by the time you start the feature, your context is half-full of stack setup.

## TL;DR

- 7 stages, not 4.
- Stage 0 (Decide) and Stage 5 (Harden) are the ones you skip.
- One session = one feature, fresh terminal each time.
- Every session ends with: verify + commit + PROGRESS.md updated.
