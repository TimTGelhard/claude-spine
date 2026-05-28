# BIAS-AUDIT — restrictive or biased content in claude-spine

> **Archived 2026-05-28.** This is the original full-repo audit. Most findings (~75 of ~85) shipped across rounds 1–5 of the [`FIXES.md`](../../FIXES.md) Pass-4 sweep — see the per-round narrative + the "Shipped vs remaining" table there. The handful of still-open items have been folded into [`FIXES.md`](../../FIXES.md) **Pass 5 — folded from the archived BIAS-AUDIT** as `BA1`–`BA5`. Kept here as the original audit trail. **Do not file new fixes here** — file them in `FIXES.md`. References elsewhere in the repo that name "BIAS-AUDIT P0 #3", "P1 #7", "P3 #13", etc. resolve to the section IDs below.

> Generated 2026-05-28 by a full-repo audit pass. Scope: places where the spine narrows the experience to *one operator's* tools and workflow (Next.js + Supabase + Vercel + Stripe on macOS, GitHub, single-developer feature-build cadence, Anthropic Pro/Max subscription) rather than serving the global audience the README aspires to.
>
> Each finding ends with one of three labels:
>
> - **CLEAN** — rewrite to be neutral / stack-agnostic. The spine already aspires to be discipline-first; these are places it leaks through.
> - **ONBOARD** — surface the assumption as a calibrated preference so users opt in instead of inheriting.
> - **ACCEPTED** — the bias is intentional given the product scope (e.g., the spine is *for Claude Code*, so Anthropic-model name-drops in the model-tier chapter are scope, not bias). Flagged here for awareness only.
>
> A finding marked `(already disclaimed)` means the file has a "swap stack as appropriate" note but the *concrete example* still anchors the reader. Disclaimers don't undo bias — they soften it.

---

## 0. Executive summary

claude-spine ships as discipline + skills + templates. The *discipline* (chapters, op-* skills) is largely stack-agnostic. The *templates*, *global config*, *onboarding question set*, *hooks*, and *opinionated CLAUDE.md* are all calibrated to one stack and one project type: a solo founder building a Next.js + Supabase + Stripe SaaS on Vercel, on macOS, deploying via GitHub. A user outside that template — a Java backend engineer, a Rust systems programmer, a Python ML researcher, a Ruby on Rails team, a PHP/Laravel agency, a .NET shop, a Windows-native developer, a GitLab/Bitbucket user, a library author, a CLI maintainer, a data-engineering team — will see the spine reject their stack three times in the first 10 minutes:

1. **`/onboard` Q3** asks "what kind of tools or languages?" and gives four options: JS/TS, Python, Go, mobile. Their ecosystem is in "Other."
2. **`/onboard` B2** asks what to *avoid* and pre-lists PHP/Laravel, Java/Spring, Ruby on Rails, C#/.NET — telling them their tech is what others flag away from.
3. **The templates they're told to copy** are a Next.js+Supabase+Stripe quote-management SaaS with currency in EUR; only the "structure" generalizes.

The audit found **~85 distinct biases** across config, templates, hooks, chapters, onboarding, and surface docs. They fall into four large clusters:

1. **Stack monoculture in concrete artifacts** (settings.json, hooks, templates, opinionated global) — biggest source of "this isn't for me" reactions.
2. **Workflow prescription** (one-session-one-feature, mandatory docs/, /prep ladder, bucket loop) — fits solo MVP work, not researchers, teams, library authors, exploratory sessions.
3. **Platform monoculture** (GitHub-only, macOS-first, bash/jq required) — Windows-native and GitLab/Bitbucket users hit friction repeatedly.
4. **Audience framing** (founder/MVP/solo language; English-only; mixed USD/EUR pricing examples; "PR review", "release branch") — sets a Western-startup register.

**Treatment recommendation in one line:** keep the chapters (the discipline is good), neutralize the artifacts (templates / config / hooks / opinionated global), and expand `/onboard` from 7 essentials + 13 deep to surface the assumptions currently hard-coded.

---

## Table of contents

- [1. Tier-1 leaks — the first 10 minutes](#1-tier-1-leaks--the-first-10-minutes)
- [2. Workflow assumptions](#2-workflow-assumptions)
- [3. Platform assumptions](#3-platform-assumptions)
- [4. Project-type assumptions](#4-project-type-assumptions)
- [5. Subscription / billing assumptions](#5-subscription--billing-assumptions)
- [6. Cultural / audience framing](#6-cultural--audience-framing)
- [7. Anti-patterns phrased as universal laws](#7-anti-patterns-phrased-as-universal-laws)
- [8. Cross-cutting themes](#8-cross-cutting-themes)
- [9. Treatment plan](#9-treatment-plan)
- [10. Suggested new onboard questions](#10-suggested-new-onboard-questions)

---

## 1. Tier-1 leaks — the first 10 minutes

These are the things a fresh user hits during `/onboard` and the first hour. Highest-priority remediation.

### 1.1 `global/settings.json` is a TS / Python / Supabase / Vercel / GitHub manifest

The default allowlist is the strongest single signal of "what this product is for." Today it is a one-stack manifest.

- `global/settings.json:24-32` — Bash allows `node`, `npm`, `npx`, `pnpm`, `yarn` but no `cargo` (Rust), no `go` (Go), no `mvn`/`gradle` (Java/Kotlin), no `bundle`/`gem` (Ruby), no `composer` (PHP), no `dotnet` (.NET), no `swift`/`xcodebuild`, no `deno`/`bun` (newer JS runtimes). **CLEAN** — expand to cover the top 10 ecosystems, or move stack-specific entries into a per-onboard-stack inject.
- `global/settings.json:33-44` — Python toolchain pre-allowed (`python`, `pip`, `pytest`, `uv`, `poetry`, `venv`). Reasonable, but the *absence* of equivalents for other ecosystems makes this a JS+Python install. **CLEAN** as above.
- `global/settings.json:46-49` — `Bash(supabase status)`, `migration list`, `db diff`, `gen types` allow-listed by default. **ONBOARD** — only inject when the user picked Supabase.
- `global/settings.json:50-54` — `Bash(vercel ls)`, `inspect`, `logs`, `env ls`, `project ls`. **ONBOARD** — only inject when user picked Vercel.
- `global/settings.json:55-60` — Five `Bash(gh ...)` entries. **ONBOARD** — only inject when user picked GitHub (`gh`) over `glab`/`bb`/none.
- `global/settings.json:61` — `Bash(lighthouse:*)` — frontend perf tool, irrelevant for backends, libraries, mobile, ML. **ONBOARD**.
- `global/settings.json:67-79` — WebFetch domain allowlist pre-approves: `supabase.com`, `vercel.com`, `nextjs.org`, `react.dev`, `tailwindcss.com`, `context7.com`. Doesn't include `rust-lang.org`, `golang.org`, `docs.python.org`, `docs.djangoproject.com`, `rubyonrails.org`, `laravel.com`, `dotnet.microsoft.com`, `docs.oracle.com`, `kotlinlang.org`, `swift.org`, `mdn.io`, `developer.mozilla.org` (!), `pypi.org`, `crates.io`, `npmjs.com`, `pkg.go.dev`, etc. **CLEAN** — broaden the default WebFetch list to the top language/framework docs, and let `/onboard` add stack-specific extras.
- `global/settings.json:147-153` — `enabledPlugins` ships with `vercel@`, `playwright@`, `frontend-design@`, `skill-creator@`, `github@` on by default. **ONBOARD** — these are stack picks. A backend Java dev gets Vercel and Playwright they don't need; a GitLab user gets the GitHub plugin.

> **Why it matters:** every Claude Code user reads / asks permission against this file. It is the most-loaded sample of "what's been pre-decided for you." Today it pre-decides JS+Python+Supabase+Vercel+GitHub.

### 1.2 The 11 template files all describe the same quote-management SaaS

- `templates/PROJECT_BRIEF.md:18` — Sample domain: quote-management SaaS for tradespeople.
- `templates/ARCHITECTURE.md:6-18` (already disclaimed) — Frontend: Next.js 16. UI: Tailwind + shadcn. Backend: Next.js server actions. DB: Supabase. Hosting: Vercel. Payments: Stripe.
- `templates/ARCHITECTURE.md:45-90` — Hard schema example with `users`, `profiles`, `quotes`, RLS policies; `/api/webhooks/stripe`; `supabase/migrations/YYYYMMDDHHMMSS_<name>.sql` naming convention.
- `templates/ARCHITECTURE.md:112-122` — External services costed in EUR (`1.4% + €0.25 EU cards`, `Pro $25/mo`) — currency mismatch with the rest of the repo (which uses USD).
- `templates/ARCHITECTURE.md:130-138` — `NEXT_PUBLIC_SUPABASE_URL`, `STRIPE_SECRET_KEY`, etc. as the example env vars.
- `templates/ARCHITECTURE.md:148-153` — Observability stack: Sentry + Vercel Analytics + Supabase logs as the *example*.
- `templates/CLAUDE.md:13-22` (already disclaimed) — Same five-line stack. Same hard `supabase/migrations/` convention.
- `templates/CLAUDE.md:80,102-103` — Domain-specific examples (`NEXT_PUBLIC_SITE_URL`, "Customer phone numbers are PII", "Quote PDFs may contain customer addresses").
- `templates/DEPLOY.md:6-78` (already disclaimed) — Entire runbook is Vercel + Supabase; the only alt path (`SSH/SCP`) is a footnote. No npm-publish, no `cargo publish`, no `mvn deploy`, no Docker registry push, no PyPI release, no App Store submission, no homebrew/chocolatey distribution.
- `templates/SMOKE_TESTS.md:24-114` (already disclaimed) — Flows are signup → dashboard → create quote → RLS check. The "cross-cutting checks" (Lighthouse, mobile browser, dark mode) only apply to web UIs.
- `templates/SMOKE_TESTS.md:132` — `# Check no Stripe secret key bled into client bundle`.
- `templates/SMOKE_TESTS.md:178` — "Error monitoring connected (Sentry or similar)" — Sentry as the canonical observability example.
- `templates/DECISIONS.md:35-41` — Example ADR baked to Next.js server actions ("If we move off Next.js, the migration is non-trivial. Acceptable for v1.").
- `templates/FEATURES.md:32,41,42` (already disclaimed) — Backlog rows reference "Vercel preview", "Supabase Storage", "Stripe subscription".
- `templates/PROJECT_PLAN.md:13-29` — Section table assumes foundation → auth → resources → landing → hardening → ship: a SaaS shape. Libraries, CLIs, ML pipelines don't have an "auth" or "landing" section.

**Treatment for all of section 1.2: CLEAN.** The disclaimers help, but the only concrete example anchors the reader. Two paths:
- (a) Add **parallel** template variants under `templates/web-saas/`, `templates/library/`, `templates/cli-tool/`, `templates/ml-pipeline/`, `templates/data-pipeline/`, `templates/native-mobile/`, `templates/desktop-app/`, `templates/embedded/`, and pick which set to copy based on an onboard answer. Or
- (b) Strip the templates back to *abstract section structure only* with placeholders, drop the worked example, and link out to a `templates-examples/` directory with the worked SaaS example clearly labeled as "one possible filling-in."

The second is easier and lighter; the first is more useful.

### 1.3 The opinionated CLAUDE.md prescribes the same stack as a rule

- `global/opinionated/CLAUDE.md.template:174-187` — "Pick from these unless I say otherwise. — Web apps: Next.js + TypeScript + Tailwind + Supabase + Vercel. — Native mobile: Expo. — Client websites: plain HTML. — Landing pages: plain HTML + Tailwind. — Internal tools: Vite + React. — Auth: Supabase or Clerk. — File storage: Supabase Storage or R2. — No Redis / Kafka / microservices / k8s for an MVP. Ever." **CLEAN** — these are the maintainer's defaults stated in the imperative. Rename the section "Stack defaults (example)" and replace with a stack-neutral schema + an example block clearly labeled as `<!-- example: solo founder TS stack -->`.
- `global/opinionated/CLAUDE.md.template:189-237` — The entire "Security — non-negotiable" section uses Next.js + Supabase + Stripe + Anthropic terminology (`NEXT_PUBLIC_*`, `EXPO_PUBLIC_*`, RLS, `service_role`, `supabase db push`, `STRIPE_SECRET_KEY`, "zod", `npm audit`). The *principles* generalize (server-side validation, no secrets in client, signed webhooks) but every concrete piece of advice is stack-specific. **CLEAN** — separate "principles" from "stack-specific recipes" and link the recipes to a per-stack appendix.
- `global/opinionated/CLAUDE.md.template:199-209` ("Supabase + RLS") — Whole subsection assumes Supabase. **CLEAN** — make this an optional appendix.
- `global/opinionated/CLAUDE.md.template:239-243` ("Anthropic API") — Names specific models, default tier, caching strategy. **ACCEPTED** (the file is opinionated by definition; users who choose `--opinionated` opt in) but `claude-sonnet-4-6` will date-rot.
- `global/opinionated/CLAUDE.md.template:248-250` — Project conventions hard-code git workflow ("`main` is deployable") and a JS-only `.gitignore` set (`.next/`, `.vercel/`, `.expo/`, `dist/`, `build/` — no `.venv`, `__pycache__`, `target/`, `.gradle`, `bin/obj`, `vendor/`, `*.pyc`, etc.). **CLEAN** — broaden the .gitignore list and language about git workflow.
- `global/opinionated/CLAUDE.md.template:8` ("Solo founder. This machine builds…") — Tone is single-developer-on-personal-machine. Doesn't fit shared CI, company laptops, agency setups, paired sessions. **ACCEPTED** for the opinionated path, but should be noted in `INSTALL.md`.

### 1.4 Hooks silently support only 4 toolchains

- `global/hooks/format-on-save.sh:11-19` — Detection map: Prettier (TS/JS/JSON/MD/CSS/HTML/YAML), Black (Python), gofmt (Go), rustfmt (Rust). Silent skip otherwise. **Missing:** rubocop / standardrb (Ruby), php-cs-fixer / pint (PHP), spotless / google-java-format (Java), ktlint (Kotlin), swiftformat (Swift), `dotnet format` (.NET), clang-format (C/C++), shfmt (shell), stylua (Lua), elm-format (Elm), mix format (Elixir), ormolu / fourmolu (Haskell), zls (Zig), and language-specific Python alternatives (Ruff format, autopep8, yapf). **CLEAN** — expand the detection map and document the extension surface so users can register their own formatter. The hook description in `op-onboard/SKILL.md:140-160` is also incomplete.
- `global/hooks/typecheck-after-edit.sh` (referenced in `SKILL.md:122-128`) — Only `.ts`/`.tsx` (project tsc) and `.py` (`python -m py_compile` — which isn't even type-checking, just parse-check). Missing: `mypy`, `pyright`, `ruff` (Python), `go vet`/`staticcheck` (Go), `cargo check` (Rust), `mvn compile` / `javac` (Java), `dotnet build` (.NET), `tsc --noEmit` for plain JS projects with `// @ts-check`, etc. **CLEAN** — broaden detection and treat "no type-checker available" as a silent skip across all languages.

### 1.5 `/onboard` Q3 buckets the user into 4 ecosystems

- `skills/core/op-onboard/questions-essential.md:43-54` — Q3 options: "Websites and web apps (JS/TS, React, Next.js)", "Python (scripts, Django, FastAPI)", "Go", "Phone apps (Swift/Kotlin/Expo/RN)". **ONBOARD** — broaden. At minimum: add "Rust", "Java / Kotlin / JVM", "Ruby (Rails / scripts)", "PHP (Laravel / WordPress)", "C# / .NET", "C / C++ / systems", "Data / ML (Python / R / Julia / notebooks)", "Native desktop (Electron / Tauri / Qt / WinForms)", "Game development (Unity / Unreal / Godot)", "Embedded / firmware (C / Rust / MicroPython)". 11 options is too many for a single AskUserQuestion; consider:
  - Q3a: "Pick the closest family" (web / mobile / desktop / backend service / library / data / ML / game / embedded / systems / scripting).
  - Q3b (conditional): "Within {family}, what's your primary language?" — gives an open-but-grouped path.
- `skills/core/op-onboard/questions-essential.md:48-51` — "Phone apps (iOS with Swift, Android with Kotlin, or cross-platform with Expo / React Native)" pre-bundles three quite different stacks. Native Swift devs are bucketed with RN devs. **ONBOARD** — split mobile native vs cross-platform.

### 1.6 B2 "Stacks to avoid" frames 4 ecosystems as the default things to flag

- `skills/core/op-onboard/questions-deep.md:88-98` — B2 options: "PHP / Laravel (older web language and framework)", "Java / Spring (enterprise web framework)", "Ruby on Rails (web framework popular in startups)", "C# / .NET (Microsoft's ecosystem)". This is **the worst single bias in the product.** It tells every PHP, Java, Ruby, and .NET developer: *the maintainer thinks of your stack as the "things to avoid" list.* The descriptors compound this — "older", "enterprise" (often pejorative), "popular in startups" (an aside that misses the point), "Microsoft's ecosystem" (the smallest framing of .NET imaginable). **CLEAN — urgent.** Two paths:
  - (a) Replace with an empty multi-select free-text: "Anything you'd rather I not suggest? Add as many as you like."
  - (b) Show a *neutral roster* (every major language family) and let the user multi-select. Don't pre-load the "avoid" slot with specific tech.

### 1.7 The README centers personalization + bucket loop

- `README.md:14-15` — "Personalization layer — a profile (`/onboard`) that calibrates Claude to you, plus a capture/curate loop that grows your personal bucket as patterns emerge." — frames the bucket as a core feature.
- `README.md:97-107` — "Bucket loop" subsection is 11 lines, longer than the description of any other component. Implies that running `/curate` and growing a personal library is expected.
- `chapters/personalization/19a-overview.md`, `19c-suggestion-loop.md`, `19d-curation-session.md`, `19e-extending-the-bucket.md` — Four atomic files dedicated to the bucket. The amount of doc surface implies the loop is required, not optional.

**Why this is bias:** many users will install the spine, run `/onboard`, and want the discipline + skills + templates without ever building a personal bucket. The current framing makes the bucket a default workflow rather than an opt-in. **ONBOARD** — add an essentials question asking whether the user wants the bucket workflow active (a default-off `op-suggest` is plausible), and reframe the README's personalization section as "two layers, one optional."

---

## 2. Workflow assumptions

### 2.1 "One session = one feature" baked as a universal rule

- `chapters/workflow/06-feature-sizing.md:6-9` — "One session = one feature. Not one app, not five small features" — stated as a hard rule.
- `chapters/workflow/06-feature-sizing.md:20-31` — Capacity table calibrated for web CRUD: "Components touched," "API routes added," "DB migrations". Irrelevant for libraries, CLIs, ML notebooks, refactors, debugging sessions, code reviews, exploratory analysis.
- `chapters/workflow/06-feature-sizing.md:44` — "MVP app (e.g., Next.js + a managed DB) — auth + 3–5 resources + 2–3 integrations ≈ 15–25 features. Plan for 15–25 sessions." Assumes a CRUD+auth shape across the whole product.
- `chapters/workflow/06-feature-sizing.md:94-102` — "Hard 'no'" list ("Auth + a feature that uses auth"). "Always" is too strong; depends on team experience.
- `chapters/workflow/05-overview.md:42` — "rule that holds across stages: one session = one focused job."

**Treatment:** **CLEAN** the language to "one session = one cohesive goal" (which is what the discipline really is); keep the CRUD-specific capacity table but label it explicitly "for web CRUD work"; add a callout "for other domains (libraries, CLIs, ML, refactors, debugging, exploration), substitute 'feature' with 'subsystem' / 'command' / 'experiment' / 'cleanup goal' / 'investigation'." Or **ONBOARD** — add a question about the user's typical session shape (feature-build / debug-investigate / refactor-cleanup / explore-research / read-and-explain).

### 2.2 PROJECT_BRIEF → ARCHITECTURE → master plan → section plan ladder

- `chapters/workflow/05h-multi-session-planning.md` — Hierarchy assumes a brief, an architecture doc, a master plan, and N section plans. Heavy upfront for a 1-hour script. Useful for a multi-month SaaS.
- `chapters/workflow/05a-stage-0-decide.md` — "PROJECT_BRIEF before code" — appropriate for a SaaS, overkill for a research notebook or a one-off helper script.
- `skills/core/op-prepare/procedure.md:70` — "N+1. integrations (Stripe, webhooks, email, file storage)" — section ordering example explicitly names Stripe.
- `skills/core/op-prepare/procedure.md:100` — Conventions table example uses `supabase/migrations/YYYYMMDDHHMMSS_<name>.sql`.
- `skills/core/op-prepare/procedure.md:110` — "When the project's stack isn't TypeScript + Next.js + Supabase, swap the file shapes" (already disclaimed).

**Treatment: CLEAN + ONBOARD.** The ladder is good discipline but should scale. Add a "lightweight project" variant: `/prep --quick` writes a single planning note and skips the brief→arch→plan ladder. The current docs implicitly assume "real project" = "needs the full ladder." Also, prep's procedure should not name Stripe / Supabase in its examples — substitute generic placeholders like `<payment-provider>`, `<db-migrations-path>`.

### 2.3 Mandatory `docs/` folder for plans

- `chapters/workflow/05j-cold-start-protocol.md:5,17-18` — Protocol references `docs/plans/` and `docs/PROGRESS.md` as the canonical location.
- `chapters/workflow/05b-stage-1-prep.md:12-17` — Stage 1 says "Copy templates from `templates/` folder into the project's `docs/`."
- `templates/SESSION_STARTER.md` — Templates assume the project has a `docs/` directory.

**Why biased:** many projects don't have a `docs/` folder. Libraries often have a single `README.md`. Embedded projects may put docs in `firmware/docs/`. Monorepos have docs at `packages/*/docs/`. A library author who already has docs at `docs/api/` doesn't want their plans dumped next to their generated API docs.

**Treatment: CLEAN.** Make the plans location a `CLAUDE.md` setting (`plans_dir: docs/plans` is the default; override per project). The cold-start protocol then reads that setting. Or **ONBOARD** — ask once in `/onboard --deep` where the user wants planning files to live by default.

### 2.4 `/prep → build → /done` as the canonical session shape

- `README.md:62-78` — Slash command table presents `/prep`, `/done` as primary.
- `README.md:78` — "The plan-driven flow is `/prep` → (open Claude; `op-spine-active` auto-loads scope) → build → `/done`."
- `skills/core/op-spine-active/SKILL.md` — Ambient skill assumes a plan exists.
- `chapters/workflow/05j-cold-start-protocol.md` — Cold-start is the per-session contract.

**Why biased:** plenty of valid sessions don't fit `/prep → build → /done`:
- Quick Q&A ("explain this regex to me")
- Brownfield diagnosis ("why is this slow?")
- Code review of someone else's PR
- Pair-programming-style exploration
- Read-the-codebase orientation
- One-off scripts that don't merit a brief

`/prep` is gated correctly (the skill description says "new project or major new section") but the cold-start protocol's framing of "every session has a plan" is overly strong.

**Treatment: CLEAN.** Add explicit "session types" early in the workflow chapter — feature-build, debug, review, explore, explain, refactor. Each has its own discipline. The `/prep` ladder is the *feature-build* one. Today the spine documents only that one in detail.

### 2.5 Personalization / bucket loop assumed wanted

- Repeated across `chapters/personalization/19a-19e`, `README.md:97-107`, `op-suggest`, `op-curate`, `op-curate-nudge`, `op-bucket-router`.
- `op-curate-nudge` is an *ambient* skill, meaning it fires automatically to nag the user about uncurated suggestions.

**Why biased:** the bucket loop is one specific theory of personal knowledge management. Many users prefer the spine as-is and don't want a personal library, curation queue, or nudge skill. Currently they can ignore the loop, but the nudge skill, the four atomic chapters, the README emphasis, and the four slash commands all signal that the loop is core.

**Treatment: ONBOARD.** Add an essentials-tier question: "Do you want the bucket loop active (capture moments, curate later) or just the spine + your profile?" If off, install does not symlink `op-suggest`, `op-curate`, `op-curate-nudge`, `op-add-skill`, `op-bucket-router`. Or **CLEAN** — reframe in README as one of two layers, both optional.

---

## 3. Platform assumptions

### 3.1 GitHub-only

- `global/settings.json:55-58` — Five `gh` allow-listed entries; no `glab` (GitLab), no `bb`/`bitbucket` (Bitbucket).
- `global/settings.json:72,150` — WebFetch allows `github.com`; plugins include `github@`.
- `chapters/recovery/17c-high-stakes-cases.md:7` — "Don't try to 'git remove' first — assume the key is compromised the moment it hit GitHub." Public-VCS scanning isn't unique to GitHub.
- `chapters/tools/15i-slash-commands.md:11` — "Pass `<PR#>` for a GitHub PR, or no arg for local branch."
- `chapters/workflow/05f-stage-5-harden.md:30` — Same `<PR#>` GitHub framing.
- `chapters/prompting/10-visuals.md:63,75` — "Mermaid (renders on GitHub, supported in many viewers)" / "Mermaid for human-facing docs (README on GitHub)." GitHub-first framing.
- `skills/core/op-visuals/SKILL.md:28` — "Diagram for ARCHITECTURE.md? → ASCII for Claude-readable, Mermaid for GitHub-readable."
- `templates/DEPLOY.md:67` — "git merge --ff-only <feature-branch>   # or use PR merge in GitHub".
- `landing/index.html:52,75,122,134` — Landing page assumes GitHub repo location.
- `README.md:28` — Clone URL is `github.com/TimTGelhard/claude-spine` (correct — this is where the repo lives).

**Treatment: CLEAN for prose.** Where chapters say "GitHub", broaden to "your VCS provider (GitHub, GitLab, Bitbucket, etc.)". **ONBOARD for settings** — onboarding can ask the user's VCS host and inject `gh`/`glab`/`bb` allow entries accordingly.

### 3.2 macOS-first, Linux second, Windows = WSL only

- `install.sh:78-86` — OS gate: `Darwin|Linux` proceed; `MINGW*|MSYS*|CYGWIN*` exit with "Run inside WSL"; anything else proceeds with "Proceeding — expect breakage."
- `install.sh:96-98` — jq install instruction: macOS first (`brew install jq`), Linux second (`apt-get install jq`), no Windows guidance.
- `README.md:58` — "macOS or Linux (Windows works inside WSL)."
- `landing/index.html:86` — Same message.
- `global/INSTALL.md:78-79,86` — Same.
- `benchmarks/tokens/run.sh:83,86,95` — `timeout` (GNU coreutils) — falls back to "brew install coreutils" guidance only for macOS.
- `global/hooks/notify-long-task.sh:29` — Uses macOS `osascript` for desktop notifications. Linux users get no notification.
- `tests/skill-triggers/README.md:18`, `tests/skill-triggers/run.sh:77`, `tests/run.sh:29` — "Install one of: brew install python@3.12 | brew install uv" — macOS only.

**Treatment:** **CLEAN** the prose ("macOS, Linux, or Windows with WSL — native Windows requires symlink support"). **CLEAN** the hook (`notify-long-task.sh`) to support `notify-send` (Linux) and `BurntToast` / `msg` (Windows). **ACCEPTED** that symlinks are required (real constraint), but document the canonical alternative path explicitly (copy instead of symlink) for native Windows users in `INSTALL.md`.

### 3.3 bash / zsh / jq required

- `install.sh` requires bash (shebang `#!/usr/bin/env bash`).
- `global/hooks/*.sh` all bash scripts.
- `install.sh:92-103` — jq is hard-required (preflight error) unless `--skip-hook`. Justified for the env-leak hook, but the *only* way to skip is to skip all hooks.
- `global/INSTALL.md:109` — "If it errors, install `jq` (`brew install jq` on macOS)."

**Treatment: ACCEPTED.** bash + jq is the cheapest portable choice. **CLEAN** — let `--skip-hook env-leak` skip only the jq-requiring hook, not all hooks. **ONBOARD** — surface that hooks are optional; the user can decline the jq requirement.

### 3.4 Web/browser focus across MCP recommendations and default plugins

- `chapters/tools/15h-mcp.md:5-27` — Lists "Chrome DevTools MCP", "Context7", "Playwright MCP" as the canonical baseline. Useful for frontend devs; irrelevant for backend, library, ML, embedded.
- `global/settings.json:151` — Playwright plugin enabled by default.
- `global/settings.json:149` — `frontend-design@claude-plugins-official` plugin enabled by default.

**Treatment: ONBOARD.** Only enable Playwright + frontend-design when the user picked a frontend / mobile stack. Chrome DevTools MCP / Playwright recommendation in the chapter should be gated to "for browser-driven projects."

---

## 4. Project-type assumptions

### 4.1 Web SaaS is the implicit default

Pervasive across templates and the opinionated CLAUDE.md. See §1.2 and §1.3 for citations. Re-emphasized here as a thematic point.

- `chapters/workflow/05b-stage-1-prep.md:20` — "First DB migration (auth + base tables if applicable). RLS from day 1." — assumes DB + auth.
- `chapters/workflow/05c-stage-2-architect.md:14` — Example external services: "Stripe, Resend, R2, an LLM provider."
- `chapters/workflow/06-feature-sizing.md:12,17` — Stripe-billing example feature.
- `chapters/persistence/12b-claudemd.md:22-32` — Stack template hardcodes Next.js + Supabase + Tailwind + Vercel as the example.
- `chapters/persistence/12b-claudemd.md:36` — Convention example: "Server actions named `action<Verb><Noun>`" — Next.js-specific.
- `chapters/prompting/09b-prompt-structure.md:28` — Example constraint "Tailwind only, no extra deps".
- `chapters/tools/15h-mcp.md:21` — "before writing Next.js / Supabase / Stripe code".

**Treatment: CLEAN.** Replace specific stack examples with abstract placeholders in chapter prose (`<framework>`, `<db>`, `<payment-provider>`); move the SaaS-specific worked examples to a clearly-labeled appendix or to the personalization-aware variant of the templates.

### 4.2 Database + RLS assumed

- `chapters/workflow/05b-stage-1-prep.md:20` — "RLS from day 1."
- `templates/SMOKE_TESTS.md:148-161` — "Two-session RLS verification" smoke test.
- `templates/ARCHITECTURE.md:75-78,100-110` — Whole "Data model" + "Auth model" sections assume Postgres + RLS.
- `global/opinionated/CLAUDE.md.template:199-209` — "Supabase + RLS" subsection in the security rules.

**Why biased:** libraries have no DB; many APIs use other DBs (Mongo, Dynamo, Firestore); many apps use JWT-based RBAC instead of RLS; many SaaS apps run on Postgres without RLS at all (auth-server-side checks). RLS is one specific Postgres pattern, not a universal.

**Treatment: CLEAN.** Move RLS-specific guidance into a labeled appendix; the principle ("enforce auth at the data layer when possible") is the universal, "use Postgres RLS" is the recipe.

### 4.3 Deploy assumes Vercel

- `templates/DEPLOY.md:8-19` — environments are "preview (Vercel), staging, production"; commits to `main` deploy.
- `templates/DEPLOY.md:45-79,132-135` — Steps are "Vercel preview green", "Promote to Production" in Vercel dashboard.
- `templates/DEPLOY.md:84-129` — Alt runbook is a single VPS via SSH/SCP, framed as "static client sites only."
- Missing deploy patterns: Docker / Kubernetes / Helm charts; AWS Lambda + API Gateway; Cloud Run / App Engine / Azure App Service; library publish (`npm publish`, `cargo publish`, `pip publish`, `mvn deploy`); container registries; binary releases (`gh release`); App Store / Play Store; package managers (homebrew, chocolatey, scoop, snap, flatpak).

**Treatment: CLEAN.** Either keep `templates/DEPLOY.md` as the Vercel example and add `templates/deploy-variants/{library-publish,docker,k8s,lambda,gh-release,mobile-app-store}.md`, or rewrite `DEPLOY.md` as a stack-neutral runbook structure with the Vercel example clearly labeled as one filling.

### 4.4 Smoke tests assume web UI flows

- `templates/SMOKE_TESTS.md:24-114` — Flows: signup → dashboard → quote create → RLS check. All web-UI flows.
- `templates/SMOKE_TESTS.md:116-125` — Cross-cutting checks: "no console errors, no 404s on assets, Lighthouse score, mobile browser test, dark mode." Web-only.

**Treatment: CLEAN.** Smoke-test shapes for CLI tools (command exit codes, output snapshots), libraries (unit tests + integration tests + API contract tests), services (load test, health endpoint, contract test), ML projects (model evaluation set, regression vs baseline), and so on, are all valid and absent.

---

## 5. Subscription / billing assumptions

### 5.1 Hard-coded Anthropic May-2026 plan names

- `skills/core/op-onboard/questions-essential.md:13-20` — Q1 options: Free / Pro / Max 5× / Max 20×. Anthropic-specific. Doesn't include Team / Enterprise / API-only / Self-hosted (Bedrock, Vertex, OpenRouter passthrough).
- `chapters/personalization/19f-subscription-aware.md` — Whole chapter is keyed to those four tiers.
- `docs/SUBSCRIPTION-AWARENESS.md:14-17,24-33` — Same tier table.
- `global/INSTALL.md:111-115` — "Tuning for Max 20x / 1M context".
- `chapters/signaling/11-overview.md:104-107` — Branches behavior on "Max 20× + Don't worry about it" vs "Pro / Max 5× + Balanced".

**Treatment: ACCEPTED** (the spine is for Claude Code, so Anthropic-plan awareness is in scope) **+ CLEAN** for dating — Anthropic ships new plans regularly. Names like "Max 20×" will date-rot. Add a single source of truth (`docs/subscription-tiers.json` or similar) and reference it from chapters + onboard, so a future plan change is a one-place edit.

Also: the **Other** branch (Team / Enterprise / API) is documented as "skip silently" — that's a worse experience than helping those users calibrate. **ONBOARD** — add a Team / Enterprise / API-passthrough branch with sensible defaults rather than skipping.

### 5.2 Currency examples mix USD and EUR without note

- `templates/ARCHITECTURE.md:117` — `1.4% + €0.25 EU cards`.
- `templates/ARCHITECTURE.md:120` — `Pro $20/mo per member`.
- `README.md:184,195` — Cost estimates in USD.

**Treatment: CLEAN.** Pick one currency for examples and note "approximate" with a region remark. Mixed signals confuse the reader.

### 5.3 Cost flagging is Anthropic-model-aware only

- `chapters/foundations/04a-model-tiers.md` — Whole chapter on Opus / Sonnet / Haiku.
- `chapters/signaling/11-overview.md:104-107` — Cost flagging assumes Anthropic models.

**Treatment: ACCEPTED.** Claude Code = Anthropic. But: be careful with date-bound model names (`claude-opus-4-7`, `claude-sonnet-4-6`) — they appear in chapters, in tools/token-check.py:33, in benchmarks/tokens/run.sh:31, in op-onboard descriptions, etc. Consider a single `MODELS.md` registry pulled by reference rather than duplicated. (This is a maintenance concern, not strictly a bias one.)

---

## 6. Cultural / audience framing

### 6.1 "Founder / MVP / solo developer" framing in opinionated globals

- `global/opinionated/CLAUDE.md.template:1,8` — Placeholder + tone: solo founder, personal machine.
- `global/INSTALL.md:129` — "opinionated for solo-founder / MVP / agency work in TS / Next.js / Supabase."
- `EXPLAINER.md:141-142` — "A grandma learning to code gets gentle, patient explanations. A senior engineer gets blunt, fast answers with no hand-holding." (Plausible spectrum, but two-pole framing misses domain experts new to Claude — e.g., a senior researcher who is brand new to coding.)
- `templates/PROJECT_BRIEF.md:18` — Quote-management SaaS for tradespeople (UK-coded — "tradespeople" + EUR pricing).
- `README.md:5` — "For people already running real Claude Code sessions on real projects who want their workflow to stop leaking quality." — gate set at "already a user", excludes onboarding-from-zero.

**Treatment: ACCEPTED** for the opinionated variant (`--opinionated` is opt-in). **CLEAN** elsewhere — README and EXPLAINER should target both startup founders *and* enterprise team members, research engineers, learners, contributors to OSS, library maintainers, etc. **ONBOARD** — capture working-context preferences (solo / team / org / OSS / academic / freelance / agency) so chapters and signaling can adapt.

### 6.2 English-only

- The entire repo is English. No i18n. Examples use English variable names and English-language stock concepts ("user persona", "PR review", "release branch").

**Treatment: ACCEPTED for now** but worth noting if "the wide public, the globe" is the target. At a minimum the README can welcome non-English contributors and indicate that translations are appreciated. Localizing chapters is a large project; localizing the onboard interview is feasible.

### 6.3 US / Western business culture defaults

- `chapters/workflow/05a-stage-0-decide.md:9-10` — "Who is this for? A specific user, not 'people.'" — Western product-design "persona" framing.
- `templates/DEPLOY.md:40` — Pre-deploy checklist: "PR reviewed (if multi-person) or self-review of `git diff main` complete." — assumes GitHub PR workflow.
- Multiple chapters use "release branch", "main is deployable", "PR review", "ship", "MVP", "stakeholder", "ICP" (assumed in marketing language).

**Treatment: CLEAN.** These are usually workable but skew toward Western SaaS culture. Where possible, prefer culture-neutral phrasing ("change for review" instead of "PR").

---

## 7. Anti-patterns phrased as universal laws

The anti-pattern chapters are valuable but some entries are *opinions stated as rules.* These rules have valid counterexamples in workflows the spine doesn't currently target.

- `chapters/anti-patterns/18g-workflow.md:20-23` — "One big PR at the end" framed as always-bad. Some teams mandate single-PR merges from a long-lived feature branch and it works fine. **CLEAN** — soften.
- `chapters/anti-patterns/18g-workflow.md:15-18` — "`PROGRESS.md` written after MVP" — assumes markdown-based tracking. Many teams use Jira / Linear / GitHub Projects / Asana. **CLEAN** — generalize to "track progress somewhere; markdown is one option."
- `chapters/workflow/05b-stage-1-prep.md:39-40` — "Skipping the templates as 'I'll write them when I have something to write about.' You won't." — strong opinion; valid for plan-driven feature work, wrong for exploratory R&D. **CLEAN** — scope to plan-driven sessions.
- `chapters/persistence/13d-skill-anti-patterns.md` (referenced from README:163) — "Speculative library trap" — collecting skills you'd never fire. Treated as universal anti-pattern. Some learners genuinely benefit from browsing a shared catalog before they know what they need. **ACCEPTED** as the maintainer's stance; the wording is strong but the README disclaims it as "this is your toolbox, not your subreddit."
- `global/opinionated/CLAUDE.md.template:187` — "No Redis / Kafka / microservices / k8s for an MVP. Ever." — strong stance with "Ever." Reasonable in the opinionated variant but should be softened in any neutral-by-default doc that quotes it.

**Treatment: CLEAN for prose; ACCEPTED for the opinionated CLAUDE.md.** Anti-pattern entries are most useful when they include *the conditions under which they apply.* Soften "always" / "never" / "ever" into "in the contexts this spine targets" or "in plan-driven solo MVP work."

---

## 8. Cross-cutting themes

A few patterns repeat across the audit:

1. **Discipline good, examples narrow.** The chapters' actual *principles* are stack-agnostic. The *concrete examples* used to illustrate them are not. This is the easiest fix: substitute generic placeholders for proper names. Cost: a few hours. Benefit: every non-TS/Python/Supabase reader stops bouncing off.
2. **Disclaimers don't undo anchoring.** Most templates have an italic header saying "Replace with your own — structure is domain-agnostic." A Java developer reading a 200-line Next.js + Supabase + Stripe example will not feel served. The disclaimer is a tax they pay to read the example. Either provide multiple parallel examples or strip the worked example to a separate file.
3. **The product slants solo / startup / web.** Founders, MVPs, agency client work, single developer on a personal machine. The README is honest about this (`CONTRIBUTING.md:7-9` admits the maintainer is one operator). For "wide public, global", the slant has to widen — at minimum, the onboard interview needs to ask "what kind of project / what kind of organization / what kind of session" so chapters can adapt.
4. **Hooks and slash commands ship enabled.** Many ambient features (`op-spine-active`, `op-curate-nudge`, the Stop hook for spine-writeback, the Notification hook for long tasks) are installed by default. Users should opt into them, not opt out.
5. **GitHub + macOS + bash is the platform monoculture.** Each individually is defensible; together, a Windows + GitLab + fish user is fighting the install in three places.
6. **Onboarding is too narrow.** 7 essentials + 13 deep questions; many critical preferences (VCS host, OS, project type, session shape, deploy target, observability, languages-to-learn-vs-avoid, team/solo, currency/region, plan-vs-explore) are unasked. Today these are silently assumed to be the maintainer's defaults.

---

## 9. Treatment plan

In priority order, with effort estimates.

### Priority 0 — Tomorrow

1. **Fix B2 ("Stacks to avoid")** in `questions-deep.md:88-98`. Replace pre-loaded list with empty multi-select free-text. Effort: 10 min. Impact: removes the single worst frame.
2. **Broaden Q3 ("Primary stack")** in `questions-essential.md:43-54`. Add Rust, Java/Kotlin, Ruby, PHP, C#/.NET, native mobile (split from cross-platform), data/ML, native desktop, game, embedded, systems. Or restructure as family→language. Effort: 30 min. Impact: removes the "your stack is in 'Other'" experience.
3. **Strip stack-specific names from chapter prose.** Pass over `chapters/persistence/12b-claudemd.md:22-36`, `chapters/workflow/05b-stage-1-prep.md:20-25`, `chapters/workflow/05c-stage-2-architect.md:14`, `chapters/workflow/06-feature-sizing.md:12,17,44`, `chapters/tools/15h-mcp.md:21`, `chapters/prompting/09b-prompt-structure.md:28`, `skills/core/op-prepare/procedure.md:70,100`. Replace named stacks with placeholders. Effort: 1–2 h. Impact: chapters stop reading as Next.js manuals.

### Priority 1 — This week

4. **Split templates into a "structure" set and an "example" set.** Either (a) parallel `templates/{web-saas,library,cli-tool,ml-pipeline,native-mobile,data-pipeline,...}/` directories, or (b) strip `templates/` to abstract structure + placeholders and move the SaaS example to `templates/examples/web-saas/`. Effort: 1–2 days. Impact: the single largest source of "this isn't for me."
5. **Move stack-specific Bash + WebFetch allowlist out of `global/settings.json`.** Make Supabase / Vercel / lighthouse / `gh` / specific WebFetch domains conditional on `/onboard` answers. Inject via a small generator instead of static JSON. Effort: half a day. Impact: settings.json becomes a true neutral default.
6. **Make `enabledPlugins` conditional.** Don't ship Vercel + Playwright + frontend-design enabled by default. Effort: 1h. Impact: people not building web frontends stop seeing five irrelevant plugins.
7. **Expand `format-on-save.sh` + `typecheck-after-edit.sh` to cover 10+ languages.** Or document the extension surface so users can register their own formatters. Effort: 1 day. Impact: hook accepts opt-in becomes useful for non-JS/Python users.

### Priority 2 — This month

8. **Add the onboard questions from §10** to extend `/onboard` and `/onboard --deep`. Effort: 1–2 days. Impact: surfaces the assumptions currently silently inherited.
9. **Rewrite `chapters/workflow/06-feature-sizing.md`** to separate the universal "one session = one cohesive goal" principle from the web-CRUD capacity table. Add explicit session-type framing (build / debug / explore / refactor / review / explain). Effort: half a day.
10. **Broaden platform support in install + hooks.** Native Windows note in `INSTALL.md`. `notify-long-task.sh` should support `notify-send` and Windows. Effort: 1 day.
11. **Reframe personalization / bucket loop as optional.** README emphasis; `op-curate-nudge` defaults off; `op-suggest` defaults off until user opts in via onboard. Effort: half a day.

### Priority 3 — When ready for a 2.x release

12. **`templates/DEPLOY.md` rewrite** as stack-neutral runbook + per-platform variants (Vercel, Docker, k8s, Lambda, library publish, mobile store, binary release).
13. **Anti-pattern softening pass** — replace "always / never / ever" with conditioned statements.
14. **VCS-host-aware install** — let onboard pick GitHub / GitLab / Bitbucket / none and inject the right `gh`/`glab`/`bb` Bash allowlist + WebFetch domains.
15. **Single source of truth for Anthropic plan tiers + model names.** A `docs/anthropic-models.md` registry that chapters, op-onboard, and benchmarks reference rather than duplicate.
16. **Subscription "Other" branch** — defaults for Team / Enterprise / API / Bedrock / Vertex / OpenRouter, instead of silently skipping.

---

## 10. Suggested new onboard questions

The current `/onboard` captures 7 essentials + 13 deep. To remove the biases above, the interview should grow by ~8 questions. Distribute across essential and deep as makes sense; some are conditional.

**New essentials (in addition to current 7):**

- **E-new — Operating system.** macOS / Linux / Windows native / Windows (WSL) / Other. Drives install paths and hook compatibility.
- **VCS-new — VCS host.** GitHub / GitLab / Bitbucket / Self-hosted Git / None / Other. Drives Bash allowlist (`gh`/`glab`/`bb`), WebFetch domains, chapter prose ("PR" vs "MR" vs "merge request").
- **PT-new — Project type.** Web app / Backend service / Mobile app / Native desktop / Library or framework / CLI tool / Data pipeline or ML / Game / Embedded / Other. Drives template choice, deploy runbook, smoke test shape.

**Replace existing essentials:**

- **Q3 replace** — Stack family / primary language. Either expand options or restructure as two-step (family → language).
- **B2 replace** — Free-text "anything to avoid" instead of pre-loaded ecosystems.

**New deep:**

- **D-new — Session shape mix.** What does a typical session look like? Mostly building new features / mostly debugging / mostly refactoring / mostly reading-and-explaining / mostly exploring-and-prototyping / a mix. Drives whether `/prep`'s ladder applies, whether mandatory plan files make sense.
- **D-new2 — Documentation home.** Where do you want plan files to live? `docs/plans/` / `.claude/plans/` / Project root / Custom / I'll set per-project. Drives cold-start protocol.
- **D-new3 — Bucket loop opt-in.** Do you want the personalization/bucket loop active, or just the spine + your profile? On / Off. Drives whether `op-suggest`, `op-curate`, `op-curate-nudge`, `op-bucket-router` install.
- **D-new4 — Team or organization shape.** Solo developer / Co-founder pair / Small team / Mid-size company / Large org / OSS contributor / Academic / Freelance / Agency / Other. Drives signaling tone, default git workflow assumption, chapter framing.
- **D-new5 — Region / currency (optional).** USD / EUR / GBP / JPY / Other. Drives example currency in cost prompts and any cost flag the spine generates.

**New deep, conditional on PT-new = web/mobile:**

- **WM-new — Deploy target.** Vercel / Netlify / Cloudflare / AWS / GCP / Azure / Self-hosted VPS / Docker registry / Mobile app stores / Other. Drives DEPLOY.md variant pick.
- **WM-new2 — Database default.** Postgres / MySQL / SQLite / Mongo / Dynamo / Firestore / None / Other. Drives ARCHITECTURE.md template variant.

These additions take the onboard from a "what stack do you use" calibration to a "who are you and how do you work" calibration. The current 7 essentials are about *Claude Code* (subscription, experience, push-back, length, depth, project context); the additions are about *the user's situation* (OS, VCS, project type, session mix, org shape). Both are needed to remove the maintainer-specific defaults baked into the spine today.

---

## Appendix — files scanned

- `README.md`, `EXPLAINER.md`, `INDEX.md`, `CONTRIBUTING.md`, `RECONSTRUCTION.md`, `LAUNCH.md` (skim), `FIXES.md` (skim)
- `install.sh`, `uninstall.sh`, `init.sh`
- `global/settings.json`, `global/INSTALL.md`, `global/neutral/CLAUDE.md.template`, `global/opinionated/CLAUDE.md.template`
- `global/hooks/*.sh`
- All 22 `skills/core/op-*/SKILL.md` (sampled — onboard, prepare, spine-active, welcome, signaling, foundations, tools, persistence, suggest, curate, curate-nudge, visuals, anti-patterns)
- All chapters under `chapters/{foundations,workflow,prompting,signaling,persistence,tools,subagents,recovery,anti-patterns,personalization}/`
- All 11 files under `templates/`
- `landing/index.html`
- `docs/SUBSCRIPTION-AWARENESS.md`, `docs/clean-room-install-report.md`, `docs/archive/*` (skim)
- `benchmarks/tokens/README.md`, `benchmarks/tokens/run.sh`, `tools/token-check.py`
- `tests/skill-triggers/README.md`, `tests/run.sh`

Findings count: ~85 distinct biases across config (8), templates (15), opinionated global (8), hooks (4), chapters (35), onboard (6), platform/OS prose (5), other (~4).

---

## Note on scope

This audit is about *bias toward specific tools, platforms, workflows, project types*, not about correctness, code quality, or design. The discipline content of the chapters is largely good. The product's *positioning* (solo founder, web SaaS, macOS) is what narrows the audience; the audit is a punch list of where that positioning leaks into surfaces a generic user touches.

A defensible alternative read is that claude-spine is intentionally opinionated and should *stay* a founder's tool. The README and CONTRIBUTING openly say so. If that's the chosen positioning, the right response to this audit is to keep most of it as-is and just be explicit in marketing ("this is for solo founders building TS SaaS — fork if your stack is different"). The user's instruction here is to widen, so the audit assumes the widen-it-up direction.
