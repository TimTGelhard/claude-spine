# claude-spine — stress-test prompt for the reporter

> **Reporter instructions (read this first):**
>
> 1. You are reviewing **claude-spine** at `/Users/macbook/claude-spine`. The maintainer's claim: "an installable operating-discipline layer for Claude Code that turns the powerful-but-undisciplined assistant into a disciplined operator, with **token efficiency as the central design constraint**, and a product that works for **anyone — any stack, any platform, any project shape**." Your job: **prove or disprove that claim**, find every bias and broken promise, and verify the core features actually work as advertised.
>
> 2. You are not a friendly reviewer. Assume marketing > reality unless you find evidence otherwise. Be specific in findings — name files, line numbers, exact phrases. Lazy "I think this could be better" is failure; concrete "file X line Y claims A but file Z line W shows B" is the bar.
>
> 3. **Start your investigation at `CLAUDE.md`** (the maintainer-facing soul of the project), then `README.md`, `FIXES.md`, `INDEX.md`, `RECONSTRUCTION.md`. Then sample chapters (`chapters/`), skills (`skills/core/op-*`), templates (`templates/`), and the global install (`global/`).
>
> 4. **Write your full findings to a new file: `docs/evaluation/REPORT-<YYYY-MM-DD>.md`** in this same directory (substitute today's date). Use the return format specified at the bottom of this file. If multiple reports exist on the same date, add `-2`, `-3`, etc.
>
> 5. Be brutal. The maintainer wants the truth, not flattery. A report that finds nothing has failed.

---

## A. The big questions

Return a verdict + 2-3 sentences of evidence per question. Cite files and line numbers.

1. **Does the project deliver "token efficiency" as a *measurable* feature, or is it aspirational marketing?** Quantify if possible. If the benchmark hasn't run yet (LC1 in `FIXES.md`), say so. If the architecture *should* save tokens but no proof exists, name the architectural mechanisms.

2. **Could a Java/Spring backend engineer, a Rust systems programmer, a Ruby on Rails team lead, a Python ML researcher, an iOS Swift dev, a PHP/Laravel agency contractor, or a .NET enterprise developer install this and get value within the first hour?** Or do they bounce off in the first 10 minutes? Walk through the actual onboarding experience for at least 3 of these personas.

3. **Is the personalization layer *real* or *decorative*?** For every profile field captured by `/onboard`, is there a chapter or skill that actually branches on it? Find dead fields if any exist. Verify `chapters/personalization/19g-field-effects.md` claims against reality.

4. **Are the security rules enforced or merely documented?** The spine ships hooks (`block-env-staging.sh`, `block-env-commit.sh`); do they catch the cases they claim to? Are there bypass paths? Are the "always" / "never" rules in `chapters/anti-patterns/18f-security.md` backed by enforcement, or only documentation?

5. **Does the workflow discipline (`/prep → ambient → /done`) generalize beyond solo web-SaaS work?** What about debug sessions, exploratory research, code review, library maintenance, embedded firmware work, ML notebooks? Read `chapters/workflow/06-feature-sizing.md`'s six session types — do downstream skills/chapters actually handle non-Build sessions?

6. **Is the spine's own discipline (FIXES = open queue, CHANGELOG = canonical Keep-a-Changelog, routing skills route, chapters atomic, no static line-count ceilings) actually applied to *itself*, or only preached?** Find places where the project violates its own rules.

7. **A Free-tier Claude user installs the spine. Does the spine respect their context budget and burn rate, or does it assume Pro-class defaults?** Walk the Free-tier path through `/onboard`, the subscription tune, and the per-plan tables in `19f-subscription-aware.md`.

8. **The README says "for people already running real Claude Code sessions."** Is that audience gate honest, or is it hiding that the product doesn't yet serve beginners? Is that the right gate, or is it excluding users who *should* be served?

9. **What is the *single biggest broken promise* in the entire repo?** (One specific finding. Not "feels incomplete" — a specific gap between a claim made somewhere and the reality elsewhere. Name both files.)

10. **What is the *single biggest unstated assumption* a user must accept to get value from this?** (E.g. "you must adopt the /prep → /done ladder for ALL sessions, even though we say it's optional.")

---

## B. Universality + bias

### B1. Stack coverage

- `/onboard` Q3 (primary stack) has 4 product-shape buckets. List every common language/framework that lands in "Other" with no further structure. Are there ecosystems where the user ends the interview feeling unseen?
- The `global/stacks/` directory ships `ts-next-supabase` and `python-django`. What's the second-class-citizen experience for stacks that don't have a flavor stub? Walk through what `install.sh` + first session looks like for a Rust/axum developer, a Java/Spring developer, an iOS/Swift developer.
- `chapters/persistence/12b-claudemd.md` shows three worked examples (Next.js SaaS, Django REST, Go CLI). Are they balanced? Or is one example the "default" and the others appendix-flavored?
- `templates/DEPLOY.md` is stack-agnostic. The worked example is `templates/examples/web-saas-next-supabase/`. List every deploy shape (Docker registry, k8s/Helm, AWS Lambda, GCP Cloud Run, library publish via `npm publish` / `cargo publish` / PyPI, GitHub Releases binary, mobile app stores) that has NO worked template variant yet. (`FIXES.md` BA3 acknowledges this — verify the queue is honest.)
- `chapters/foundations/03c-project-fit.md` claims 11 project types are "handled well." Read each — does the actual chapter content support the claim, or is it a list with no follow-through?

### B2. Platform coverage

- `install.sh` exits on `MINGW*|MSYS*|CYGWIN*`. A Windows-native developer is told to use WSL or copy by hand. What percentage of Claude Code's potential user base does this gate cut off? Is there any path forward in the open queue? (FIXES B10 mentions this.)
- macOS-isms in install + tests + hooks? Find them. Check `notify-long-task.sh`, `timeout` usage in benchmarks, `osascript` calls, any Homebrew-specific guidance.
- ChromeOS / FreeBSD / Termux on Android — does anything in the install break for those?
- The README says "macOS or Linux (Windows works inside WSL)." Is that prominent enough? Or buried?

### B3. VCS coverage

- The `+vcs-gitlab.json` and `+vcs-bitbucket.json` fragments exist under `global/settings-extras/`. What about: GitLab self-hosted (different domains), Forgejo, Gitea, cgit, Phabricator, Azure DevOps Repos, AWS CodeCommit, SourceHut, Codeberg, SVN, Mercurial, Fossil, Perforce? Is the matrix honest?
- `/onboard` Q8 (VCS host) asks the question — is the wording neutral, or does it lean GitHub? Read the question text in `skills/core/op-onboard/questions-essential.md`.

### B4. Project-type coverage

- `op-spine-active` triggers on `docs/plans/` + `docs/PROGRESS.md` (or 3 fallback conventions per N6). What about projects with `.spec/`, `roadmap/`, Notion-synced, Linear-synced, JIRA-synced? What about monorepos with multiple `docs/` (one per app)?
- `/prep` writes a `PROJECT_BRIEF.md` — does that ladder make sense for a research notebook, a one-off shell script, a code review session, a debugging investigation, an OSS PR contribution, an academic paper's code supplement? Find chapters that admit this vs ones that pretend the ladder is universal.
- `chapters/workflow/06-feature-sizing.md` has 6 session types (Build/Debug/Refactor/Explore/Review/Explain). Do downstream chapters (workflow / prompting / signaling) actually handle non-Build sessions, or just the Build flow?

### B5. Cultural / business framing

- USD vs EUR vs other currencies — find every concrete cost mention. Is the convention consistent?
- "PR" / "MR" / "merge request" / "change request" — does the prose accommodate non-GitHub vocabulary or default to PR?
- Founder / MVP / solo / agency framing — find every place this register shows up. Does the README's gate ("for people already running Claude Code sessions") cover the disclaimer, or are there hidden assumptions deeper in?
- Anything English-idiom-heavy that would translate poorly?
- Read `CONTRIBUTING.md` — does the single-maintainer policy frame match the universal-product ambition?

---

## C. Core features — proof or disproof

### C1. Token efficiency (the headline claim)

- The repo has `benchmarks/tokens/` — has the baseline actually been run? Find evidence either way (REPORT.md, output files, etc.).
- Architectural mechanisms claimed in `CLAUDE.md`: "routing not loading," "atomic chapters," "default-off bucket," "default-off heavy plugins," "subscription-tuned `effortLevel` / `autoCompactWindow`." For each, find the code that implements it AND verify it actually saves tokens vs the alternative.
- Find places where the spine itself *loads more tokens than necessary*. (E.g., if `op-onboard/SKILL.md` is short but loads `questions-essential.md` every time, is that a saving or a wash? What about the routing skills that read large adjacent files?)
- What's the largest single file Claude reads at session start under a normal install? Is it justifiable?
- The Vercel, Playwright, frontend-design plugins flipped to default-off in round 6. How many tokens does that save per session? Estimate.

### C2. Personalization

- For each field in `skills/core/op-onboard/profile-template.md` (the canonical profile shape), find AT LEAST ONE chapter or skill that reads it and branches behavior. Flag fields with no consumer — those are decorative.
- `chapters/personalization/19g-field-effects.md` claims to be the canonical "field → consumer" map. Verify EVERY row is accurate. Find rows where the named consumer doesn't actually read the field.
- The Section W conditional questions (W1 deploy target / W2 database) — do downstream skills / chapters / templates actually use those answers? Or are they captured-and-ignored?
- The bucket-loop default flipped on→off in round 6. If a user opts in, does the curation nudge actually fire as documented in `chapters/personalization/19c-suggestion-loop.md`? Walk the conditions.
- "Push-back intensity" (Q4) has 4 levels. Find chapter / skill behavior that genuinely differs across all 4. Or is it 2-level (do-it-anyway vs argue) with two cosmetic intermediates?
- Profile-settable defaults under `## Spine defaults` — verify that the consuming code (e.g. `spine-writeback.sh` for turn thresholds, `op-curate-nudge` for nudge timing) actually reads from the profile, not from hard-coded fallbacks.

### C3. Security

- The "always" rules in `chapters/anti-patterns/18f-security.md` — are they enforced by hooks, or only documented?
- `block-env-staging.sh` and `block-env-commit.sh` — can they be bypassed by clever filename / staging tricks? Find edge cases. Run the test fixtures (`tests/hooks/test-block-env-*.sh`) and verify they catch what they claim.
- The settings-extras `jq` merge — could a malicious fragment inject a `hooks` entry, change the `model`, or modify `enabledPlugins`? The `op-onboard/SKILL.md` rule says "only `permissions.allow` + `permissions.WebFetch` arrays append-only" — is that actually enforced by the merge code in `skills/core/op-onboard/extras-merge.md`?
- `install.sh` writes to `~/.claude/`. What's the trust model? What if `~/.claude/` already has user content the spine overwrites? Verify the backup path works as documented.
- The default `global/settings.json` is broad-allow. Is anything in the allowlist actually dangerous when combined with a creative attacker prompt?

### C4. Subagent discipline

- `chapters/subagents/` teaches when to delegate. Does the spine itself use subagents disciplined-ly in its own skill definitions, or for theater?
- `op-subagents` skill: what's its actual trigger description? Is it sharp enough to fire when needed but not for trivial work? (Check against the failed Pillar 5 trigger benchmark history.)
- 19f per-plan fan-out budgets (Free: avoid; Pro: 2-3; Max 5×: 3-5; Max 20×: 10+) — is this actually enforced anywhere, or just suggested?

### C5. Push-back / signaling

- `op-signaling` SKILL.md — has it been tightened since the Pillar 5 round? Or is it still over-broad?
- `chapters/signaling/` — 5 categories (context, scope, drift, verification, meta). Does each have a real trigger or are some thin?
- "Meta scope" (`11e-meta-scope.md`) — does it actually catch Claude when she's being asked to extend her own setup? Or is it advisory text the loop doesn't enforce?
- Q4 push-back intensity options: "Just do it" / "Mention concerns, then continue" / "Argue your side" / "Teach me along the way." Find one chapter or skill that genuinely behaves differently across all four.

### C6. Workflow

- The `/prep → ambient → /done` flow is the canonical path. What % of real Claude Code sessions actually fit this shape? (Estimate based on session-type catalog in `06-feature-sizing.md`.)
- `/done` does verify checklist + roll-up + commit suggestion. What happens if the user never runs `/done`? Is anything broken, or just suboptimal?
- The `spine-writeback.sh` Stop hook: long-session signal at 30 turns / 2h. Is 30 turns universally right? (Hint: `CLAUDE.md` reframes static numbers as lazy. Is this signal subject to the same critique?) Verify the threshold can be overridden via `## Spine defaults` in the profile.
- What's the failure mode if `docs/PROGRESS.md` format drifts? The `.spine-parse-error` marker — is it actually surfaced by `/done` and `/spine` as documented?

---

## D. Onboarding + first-run UX

- Time a cold install from `git clone` to "Claude Code working with profile in place" (estimated, not actual). Find every friction point.
- `op-welcome` fires once when profile is missing. Verify trigger and exit conditions. Does it ever re-fire?
- `/onboard` essentials = 10 questions, deep = 18 + up to 2 conditional + 2 hook prompts. Does the user know what they're committing to *before* Q1? Read the SKILL.md's preview block — is it honest about time + scope?
- Q1 = `Other` (free-text). Does the subscription-tune mapping (Team / Enterprise / API / Bedrock / Vertex / OpenRouter) match the documented behavior in `19f` and in the README?
- If `/onboard --deep` is interrupted at Q12, does the essentials profile still save? Verify against the SKILL.md's claim.
- The handoff message at end of `/onboard` (`handoff.md`) — does it accurately report what changed in `settings.json` per the per-fragment Apply/Skip discipline?

---

## E. Anti-drift + maintenance

- `FIXES.md` is currently ~70 lines (forward-looking open queue only). Find any entry that's actually shipped — those are stale.
- `CHANGELOG.md` is canonical Keep-a-Changelog format (4 versions: `[Unreleased]` / `[0.11.0]` / `[0.10.0]` / `[0.9.0]`). Find any verbose per-pillar essay that's leaked back in.
- `RECONSTRUCTION.md` is frozen — find any newly-added "ongoing" content that doesn't belong there.
- `docs/MODELS.md` is the model registry. Find any chapter / template / script that still hard-codes a model ID (Opus 4.7, Sonnet 4.6, Haiku 4.5) instead of citing the registry.
- "Counts" claims throughout the repo (skills / commands / chapters / hooks / questions). Verify every count is accurate today. Common drift surfaces: README, EXPLAINER, INSTALL.md, `op-onboard/SKILL.md`, `op-welcome/SKILL.md`, command descriptions, the `/onboard` slash-command file.
- Lazy static-limit framings — `CLAUDE.md` explicitly reframes "150-line ceiling" and "≤55-line skills" as anti-patterns. Find any remaining place in the live docs where the static number is still framed as a rule.

---

## F. Failure modes + edge cases

- What happens when `install.sh` is run on a directory that's not at `~/.claude-spine`? Does it self-locate correctly per the symlink-via-pwd logic?
- What happens when the user has a custom `~/.claude/settings.json` with hand-edits and runs `/onboard --deep`'s extras-merge? Walk the failure path through `extras-merge.md`'s fail-fast logic.
- What happens if `jq` is uninstalled mid-session and a hook fires? Find the fail-fast behavior in each hook.
- `spine-writeback.sh` parsing PROGRESS.md — what's the failure surface when the user does a partial edit (e.g., changes the bold to italic on one bullet)? Does the marker actually warn the user?
- `op-curate` rule: never write to `chapters/` or `skills/core/`. Verify the hard refusal is actually in the SKILL.md, not just stated in a chapter. What happens if a user explicitly tells Claude to write to those paths during `/curate`?
- What happens to a half-finished `/onboard --deep` if the user does Cmd+C mid-flow? Verify against the documented "essentials block writes after Q9" claim.

---

## G. Honesty + alignment

- Compare README's "What you get" bullets to what `install.sh` actually installs. Are the counts honest?
- The `EXPLAINER.md` plain-English framing — is it consistent with the technical docs, or does it overpromise?
- The `landing/index.html` — find every claim made there and verify against actual installed behavior.
- `CONTRIBUTING.md` — is it consistent with the bucket-loop default-off stance? Or does it still imply a community contribution model that doesn't exist?
- `CLAUDE.md` claims "token efficiency is the central design constraint." Find places where token cost is *not* a consideration that probably should be.
- The marketing line on `README.md:5`: "For people already running real Claude Code sessions on real projects who want their workflow to stop leaking quality." Does the actual onboarding match this audience, or is it broader / narrower?

---

## H. Trust + audit trail

- After `install.sh` completes, what *exactly* was written to `~/.claude/`? Is there a manifest or just trust? Can a user audit the full change set?
- `uninstall.sh` — does it remove every spine artifact, or leave orphans? Verify the H5 fix (round-3 era) actually closed the "only removes 1 of 6 hooks" bug.
- Backups — `install.sh` claims it backs up `~/.claude-backup-<ts>/`. Verify and surface the location.
- The settings-extras `jq` merge writes to `~/.claude/settings.json`. Is there a backup before the merge? Or is the only safety the user's own version control?
- What can a user run today to see "what is the spine doing in my session right now"? (`/spine` and `/hooks` exist — do they cover everything? Are there hidden behaviors not surfaced?)

---

## I. The Free user (the most-likely first-time installer)

- Walk through `/onboard` as a Free-tier user. Does the experience feel calibrated for them, or like a hand-me-down from the Max experience?
- `chapters/personalization/19f-subscription-aware.md` — find every place the Free row says something different from Pro. Is the difference meaningful behavior, or token-anxiety theater?
- Cost-flagging: does the spine warn a Free user before running a token-heavy operation? Or assume they can afford it?
- Is there any path in `/onboard` that recommends a Free user *not* install certain heavy bits (e.g., decline both opt-in hooks, decline any stack-extras merge)?

---

## J. The deep "what's missing" question

What chapter / skill / template / mechanism does the spine clearly NEED but doesn't have yet? List the top 3 gaps, each with the user pain it would close.

---

## Return format

Write your report to **`docs/evaluation/REPORT-<YYYY-MM-DD>.md`** (substitute today's date). Use this structure:

```markdown
# claude-spine stress-test report — <YYYY-MM-DD>

Reporter: <model + run context if you can name yourself>

## Executive summary

3-5 sentences. What's the verdict, what's the top concern, what's the strongest finding.

## A. Big questions

For each of the 10 big questions:

### A1. <question short title>

**Verdict:** <one line>

**Evidence:** <2-3 sentences citing specific files + line numbers>

(repeat for A2–A10)

## B. Universality + bias

For each subsection B1–B5, return findings as:

- **Finding:** <one-sentence claim>
- **Evidence:** <specific files + line numbers>
- **Severity:** blocking / serious / minor
- **Recommended fix:** <1-2 sentences>

## C. Core features

(same shape — one finding block per feature where you found a gap)

## D. Onboarding + first-run UX
## E. Anti-drift + maintenance
## F. Failure modes + edge cases
## G. Honesty + alignment
## H. Trust + audit trail
## I. The Free user
## J. What's missing — top 3 gaps

## Verdict

1. **Is the project ready for the public-launch claim ("operating-discipline layer for any Claude Code user")?** YES / NO / NOT YET — with one paragraph of reasoning.
2. **What are the 3 highest-impact fixes the maintainer should land before LC5 (public launch)?** Cite the specific FIXES item or propose a new BA/LC/H-numbered ID.
3. **What's the single piece of evidence that would change your verdict?** (E.g., "an actual LC1 benchmark run with concrete token-savings numbers" or "evidence that the personalization fields actually fire downstream in at least 5 different user paths.")
```

Sign off with: model name, run timestamp, and an honest one-line statement of how confident you are in the findings (0-100%).

---

## What is OUT of scope for this report

- Do not propose new features beyond closing observed gaps. The point is to evaluate what's here, not to redesign.
- Do not run `tests/run.sh` or any cost-incurring benchmarks. Read-only analysis.
- Do not edit any files in the project. Your output is `docs/evaluation/REPORT-<YYYY-MM-DD>.md` only.
- Do not be diplomatic. Diplomatic reports are useless for pre-launch evaluation.
