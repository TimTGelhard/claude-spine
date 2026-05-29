# Profile-field effects — what each line in `claude-spine-profile.md` actually changes

> Reference for the "I changed X in my profile and nothing seems different" question. Maps each profile field to the chapters, skills, and hooks that read it, plus the user-visible behavior change you should expect.

If a field is missing from this table, the cause is usually one of two things:

- The field is captured but not yet wired downstream — see [`19f-subscription-aware`](19f-subscription-aware.md) for the worked example of subscription wiring (the rest of the profile follows the same pattern but in fewer places).
- The field is `(unfilled — run /onboard --deep to capture)`, in which case its consumers fall back to the shipped defaults and no per-user behavior fires.

To re-set a field, either re-run `/onboard` (and re-answer just the questions you want to change) or hand-edit `~/.claude/claude-spine-profile.md` directly — the file is plain markdown.

---

## Subscription

| Field | Read by | What changes when it changes |
|---|---|---|
| **Plan** (Q1) | `op-foundations` (chapter 04a model tiers, 04c budget), `op-tools` (15h MCP), `op-subagents` (16c parallel/background), `op-signaling` (11), `subscription-tune.md` in `op-onboard` | The eight levers in [`19f`](19f-subscription-aware.md) — model defaults (Opus vs Sonnet vs Haiku), when to run multi-agent review, parallel-vs-sequential subagent posture, cost-flag cadence, context-budget framing. Also drives the one-time `autoCompactWindow` + `effortLevel` tune proposed at the end of `/onboard`. |
| **Daily usage** (0A) | `op-foundations`, `op-tools`, `op-signaling`, the Cost-sensitivity branch in [`19f`](19f-subscription-aware.md) | Combined with **Cost sensitivity** below, biases recommendations toward cheaper / lighter approaches. "Heavy" + "very careful" produces the most conservative branch. |
| **Cost sensitivity** (0B) | Same as Daily usage — read by every chapter that branches on plan tier in [`19f`](19f-subscription-aware.md) | Modifies what a given Plan tier suggests. A Max 20× user who sets cost sensitivity to "very careful" gets Pro-like suggestions instead of "rip Opus on everything." |

## Developer profile

| Field | Read by | What changes when it changes |
|---|---|---|
| **Experience level** (Q2) | `op-prompting` (chapter 09 — phrasing for newer vs senior users), `op-foundations` (01 — depth of LLM-loop explanations), `op-onboard/handoff.md` (tone of the closing block) | Adjusts how much jargon Claude leans on. "Newer to coding" gets plain-English glosses on terms like "diff" or "stack"; "senior" gets terse, jargon-OK responses. |
| **Years coding** (A1) | Same as Experience level — finer-grained signal | Adjusts the same dial; mostly a tiebreaker when Q2 is ambiguous. |
| **Comfort areas** (A2) | `op-prompting`, `op-signaling` — bias *toward* mentioning these freely | Claude assumes you don't need definitions for items in this list (e.g., if "TypeScript" is listed, Claude won't gloss `tsc`). |
| **Lean-in areas** (A3) | `op-collaboration-modes` (07c explainer mode), `op-prompting` | Claude leans *toward* teaching when work touches these areas (e.g., if "concurrency" is in lean-in, Claude will explain the why of a `Mutex` choice in passing). |

## Stack preferences

| Field | Read by | What changes when it changes |
|---|---|---|
| **Primary** (Q3) | `op-prepare/procedure.md` (the per-stack file-shape table in Step 6.1), `templates/examples/` picks at scaffold time, `op-foundations` (03c project-fit examples) | Drives which worked-example pattern Claude follows when scaffolding (Next.js / Supabase shape vs Django REST vs Go CLI vs Rails, etc.). Generic prose is unchanged; only concrete examples flip. |
| **Secondary** (B1) | Same as Primary — secondary stack hint | When the active task touches the secondary stack, Claude uses its conventions instead of the primary's. |
| **Avoid** (B2) | `op-prepare`, `op-signaling`, all skills that propose dependencies | Claude doesn't suggest items in this list. A free-text "no Redis" entry causes Claude to skip Redis as a caching suggestion, propose alternatives. |

## Environment

| Field | Read by | What changes when it changes |
|---|---|---|
| **OS** (Q7) | `op-tools` (15c execution), `op-recovery` (17), all Bash command suggestions | Shell command flavor (`brew install` vs `apt-get install` vs WSL hints), path separators (`/` vs `\`), and which install instructions get surfaced. |
| **VCS host** (Q8) | `op-onboard/handoff.md` (suggests the matching CLI + documents the `{{PR_OR_MR}}` substitution table), `op-spine-active` (applies the substitution at chapter-read time). Chapter source-prose under `chapters/workflow/` + `chapters/anti-patterns/` uses the literal `{{PR_OR_MR}}` placeholder; resolution happens at read-time. | CLI suggestions (`gh` vs `glab` vs `bb`), URL patterns for cross-references, and "pull request" vs "merge request" wording wherever Claude quotes or paraphrases a chapter back to you. Note: the spine surfaces the CLI as a *suggestion* in the handoff; it does not auto-add the CLI to your Bash allowlist — copy the suggested line into `~/.claude/settings.json` to grant permission. |
| **Plans dir** (G2) | `op-spine-active`, `spine-writeback.sh` | Overrides the four built-in plan-layout conventions (`docs/plans/`, `docs/specs/`, `plans/`, `specs/`). Precedence (first match wins): (1) project-level `CLAUDE.md` line `Plan layout: <dir> <progress-file>`, (2) this profile field, (3) the four built-ins. Both the hook and the cold-start skill apply the same precedence — a malformed value at any level falls through to the next. |
| **Currency** (H3) | `op-foundations` (04c budget — cost-flag prose), `op-signaling` (11 — cost-flag templates) | Example dollar amounts in cost flags switch to your currency. Cosmetic — the underlying threshold is still token-count-based. |

## Project context

| Field | Read by | What changes when it changes |
|---|---|---|
| **Typical work** (Q6) | `op-workflow` (chapter 06 feature sizing — sizing the cohesive goal), `op-prepare` (Step 5 section-ordering templates) | "MVP / new builds" surfaces the brief→architect→build ladder. "Brownfield / maintenance" surfaces `op-brownfield` patterns (chapter 08) and the discovery sequence before action. "Mixed" stays neutral. |
| **Artifact** (Q9) | `op-prepare` (per-project-type section templates — web SaaS vs backend service vs CLI/library vs ML/data pipeline), `templates/examples/`, deploy runbook variants | Drives which `templates/examples/<variant>/` Claude pulls from at scaffold time, which Verify scaffolds in `op-prepare/procedure.md` Step 6.2 fire, and how the deploy section reads (Vercel / Docker / library publish / mobile store / binary release). For UI apps, also gates whether Section W (Deploy target + Database) runs in `/onboard --deep`. |
| **Deploy target** (W1, conditional on Q9 = UI app) | `op-prepare` (Step 6 deploy section), the `templates/examples/.../DEPLOY.md` variant pick (once per-platform variants ship — see BA3 in [`FIXES.md`](../../FIXES.md)), env-var convention examples in chapter 12b + 18f | Selects which deploy runbook + CLI flavor (`vercel`, `aws`, `kubectl`, `flyctl`, `fastlane`, …) appears in examples, and which environment-variable conventions (`NEXT_PUBLIC_*`, `EXPO_PUBLIC_*`, `VITE_*`, plain `process.env`, `AWS_PROFILE`, …) Claude reaches for first. Skipped automatically (unfilled) when Q9 isn't UI-bearing; hand-edit the profile to fill it for backend service / library users who still want the routing. |
| **Database** (W2, conditional on Q9 = UI app) | `op-prepare` (Step 6.2 — Per-row authorization scaffold), `templates/examples/` ARCHITECTURE.md variant pick, migration-tooling examples | Selects the "Per-row authorization" pattern Claude reaches for first (RLS for Postgres, security rules for Firestore, IAM for Dynamo, decorator-based for ORMs over Other-SQL), and which migration tooling (`alembic` / `prisma` / `drizzle` / `flyway` / native SQL) shows up in examples. Same conditional shape as Deploy target — unfilled when Q9 isn't UI-bearing; hand-editable. |
| **Team size** (C1) | `op-workflow` (PR vs self-review framing in 05f/g), `op-anti-patterns` (18g — solo vs multi-person workflow tradeoffs) | Solo gets "self-review the diff" framing; team gets "open a PR, request review" framing. The hard discipline (verify, smoke test) is identical. |
| **User scale** (C2) | `op-signaling` (11 — when to flag perf, observability), `op-foundations` (03c) | Higher user scale triggers earlier flags around observability, error tracking, rate limits. A "0 users" project doesn't get nagged about Sentry. |
| **Org shape** (H2) | `op-signaling` (tone — "agency" vs "OSS contributor" vs "solo" lands different), `op-onboard/handoff.md` | Subtle phrasing shifts — "ship to the client" (agency) vs "merge to main" (solo) vs "open a PR for community review" (OSS). |

## Working style

| Field | Read by | What changes when it changes |
|---|---|---|
| **Push-back intensity** (Q4) | `op-signaling/SKILL.md` Step 0 (reads the field), `chapters/signaling/11g-push-back-phrasing.md` (canonical phrasing table), both stack templates' `{{Q4}}` placeholder (substituted at chapter-read time per `op-onboard/handoff.md`) | Adjusts both *threshold* (which signals fire) and *tone* (how they're phrased). The five signal categories (11a–11e) don't change; their delivery does. "Just do it" → only blocking risks fire, terse one-liners. "Mention concerns, then continue" → meaningful risks surface once with the action, then proceed. "Argue your side" → meaningful risks surface with the case for the alternative; hold ground. "Teach me along the way" → fire on learning moments too, name the underlying principle. Full per-category phrasing table in [`11g`](../signaling/11g-push-back-phrasing.md). |
| **Answer length** (Q5a) | Every response. Read implicitly by Claude's general response policy, surfaced explicitly in `op-prompting` (09) | Terse / Standard / Verbose. "Terse" suppresses summaries and explanatory paragraphs; "Verbose" keeps them. |
| **Reasoning depth** (Q5b) | Every response, similar to Length but on a different axis | "Just the answer" → no chain-of-thought visible. "Show the path" → key decision points narrated. "Teach me the why" → full reasoning + alternatives considered. |
| **Active signals** (D1) | `op-signaling` (which categories of flags fire) | Pruning the list silences whole categories. If "context filling" is dropped from the list, Claude stops flagging high-context turns; if "scope creep" is dropped, Claude lets scope drift without naming it. |
| **Session shape** (G1) | `op-collaboration-modes` (chapter 07), `op-workflow` (chapter 06 — sizing) | Determines the implicit default cohesive-goal shape. "Mostly building features" gets the `/prep` → build → `/done` ladder presented as the obvious path. "Mostly debugging / exploring" presents `op-recovery` and brownfield discovery patterns earlier. |

## Output format

| Field | Read by | What changes when it changes |
|---|---|---|
| **Explanation style** (set via `/explain` — no onboarding question) | Every response (read implicitly by Claude's response policy); surfaced + written by the `/explain` command | Simple / Standard / Detailed. "Simple" → plain language, minimal jargon, *what* changed + *why* in a line or two, technical detail on request. "Detailed" → full technical register, trade-offs spelled out. A distinct axis from **Answer length** (how much text) and **Reasoning depth** (how much reasoning is shown): this controls register / plainness. Defaults to Standard; change with `/explain <level>` or by hand-editing the line. |
| **Code presentation** (E1) | Every response that emits code, surfaced explicitly in `op-prompting` | "Diffs and snippets" (default) → Claude shows the change, not the surrounding file. "Whole files" → Claude pastes the full file every edit (verbose). "Patches only" → unified diff format. |
| **Comments / emojis** (E2) | Every response, surfaced in `op-prompting` (09) and in CLAUDE.md (the spine's global stub also says "no emojis unless asked") | "Minimal comments, no emojis" (default) is what the spine ships. Allowing comments turns up the WHY-line frequency. Allowing emojis is rare and explicit. |

## Risk + safety

| Field | Read by | What changes when it changes |
|---|---|---|
| **Command tolerance** (F1) | Every Bash invocation Claude considers, surfaced in `op-tools` (15c) and the spine's global CLAUDE.md "Executing actions with care" rules | "Ask before running anything that writes" (default) → Claude proposes destructive commands and waits. "Auto-run reversible writes" → small reversible edits proceed without ask. "Show me first, I'll run it" → Claude never executes Bash; only suggests. |

## Spine defaults

These knobs override threshold and cue-phrase defaults inside the spine's skills + hooks. Set them in the `## Spine defaults` section at the bottom of your profile.

| Field | Read by | What changes when it changes |
|---|---|---|
| **Bucket loop:** `on` / `off` | `op-suggest`, `op-curate-nudge`, `op-add-skill`, `op-bucket-router` | `off` silences the capture/curate flywheel entirely. The profile + spine still load every session; nothing captures, nothing nudges, nothing routes through the personal library. Explicit user invocation (`/suggest`, `/curate`, `/add-skill`) is honored as a one-shot override. |
| **Curate nudge pending threshold:** `5` (default) | `op-curate-nudge/SKILL.md` | Pending-count above which the nudge fires at conversation start. Raise to silence on a smaller bucket; lower to nudge earlier. |
| **Curate nudge cooldown days:** `30` (default) | `op-curate-nudge` | Days between successive nudges. Combined with the threshold above (both must be true). |
| **Stale review never-fired age days:** `90` (default) | `op-curate/stale-review.md` | Age above which a never-fired bucket skill becomes a stale candidate during `/curate --review-stale`. |
| **Stale review last-fired age months:** `6` (default) | `op-curate/stale-review.md` | Months-since-last-fire above which a once-fired bucket skill becomes a stale candidate. |
| **Add-skill minimum fire count:** `3` (default) | `op-add-skill` | Pattern-fire count above which Claude proposes adding a bucket skill. Lowering this captures more aggressively; raising biases toward conservative library growth. |
| **Prep clarifying questions cap:** `5-7` (default) | `op-prepare/procedure.md` | Upper bound on questions during `/prep`'s clarifying pass. Raise for complex projects; lower for "just start" briefs. |
| **Prep section count target range:** `5-12` (default) | `op-prepare/procedure.md` | Suggested section count in `PROJECT_PLAN.md`. Raise for larger projects. |
| **Prep session entry split lines:** `100` (default) | `op-prepare/procedure.md` | Lines per session-entry above which `/prep` proposes splitting the session. Raise to allow chunkier sessions. |
| **Long-session turn threshold:** `30` (default) | `spine-writeback.sh` | Turn count above which the once-per-session long-session signal fires at the next Stop event. Raise if you routinely run longer sessions. |
| **Long-session elapsed seconds:** `7200` (default) | `spine-writeback.sh` | Wall-clock seconds since session start above which the long-session signal fires (whichever-first with turn threshold). Raise for slower-cadence work. |
| **Cross-session note cues:** (extend by bullets) | `spine-writeback.sh` | Each bullet under this field is appended to the regex the Stop hook uses to capture forward-looking notes. Add phrases that match your idiolect (e.g., `note this for tomorrow`, `remember next week`) so capture catches your voice, not just the shipped defaults. |

---

## How to confirm a change actually fired

A few quick checks if a profile change "doesn't seem to do anything":

1. **Open a new conversation** — profile is read at session start; mid-session edits don't apply until the next Claude Code launch in that project.
2. **Run `/spine`** — it shows the profile path and whether the file exists. Quick sanity check.
3. **For threshold fields** — the Stop hook reads them fresh on every assistant turn, so they DO apply mid-session. If a threshold change isn't firing, check the bullet shape matches `- **<Field>:** <value>` exactly (parser is regex-based).
4. **For Plan / Cost sensitivity** — open [`19f-subscription-aware`](19f-subscription-aware.md) and find the row your tier+sensitivity maps to. If the behavior you expected isn't in that row, the field isn't the right lever — file a finding or hand-edit `19f` to extend it.
5. **For Stack / Artifact** — these are scaffold-time signals. Re-running `/prep` after the change is the surface that picks them up; mid-session edits don't retroactively rewrite existing plan files.

---

## When this chapter is the wrong answer

This is a *reference*. If you actually want to **change a field**, run `/onboard` or hand-edit the profile — don't reach for this file. If you want to **understand the overall personalization architecture**, see [`19a-overview`](19a-overview.md). If you want to **add a new field**, that requires changes to `questions-essential.md` / `questions-deep.md`, `profile-template.md`, plus a downstream consumer — see [`19e-extending-the-bucket`](19e-extending-the-bucket.md) for the general "extending the spine" pattern.
