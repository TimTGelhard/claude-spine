# Section: audit-01-architecture

> Section 1 of the audit pass. See `docs/PROJECT_PLAN.md` for the full master plan.
> **Audit phase: WRITE FINDINGS ONLY.** Do not edit `chapters/`, `skills/core/`, code, or templates in this section. Blocking findings flow to `FIXES.md` for apply sessions later.
> **🔒 No apply session runs until all six audit sections are `done`.** See `docs/PROJECT_PLAN.md` § Constraints — interleaving audit + apply breaks coherence across sections.

## Section goal

Audit the project's structural integrity against its own 5-layer architecture (skills → chapters → INDEX → bucket → global) declared in `CLAUDE.md`. Verify that op-* SKILL.md files route rather than carry teaching content; chapters are atomic (one concept per file); INDEX.md matches the actual `chapters/` tree; and the headline count claims (post-Section-0 baseline: **23 op-* / 9 commands / 4 default + 2 opt-in hooks / 84 chapters**) are accurate everywhere they appear.

## Done criteria

- [x] Every `skills/core/op-*/SKILL.md` reviewed for router shape (content type, not just length). _All 23 opened individually; verify-list "22" was stale wording._
- [x] Every `chapters/<topic>/*.md` file > 200 lines spot-checked for multi-concept content. _Zero files >200 lines (max 155); top-8 sampled for thoroughness._
- [x] `INDEX.md` cross-checked against actual `chapters/` folders in both directions. _F4 logged (1 missing row)._
- [x] Count claims swept across CLAUDE.md, README.md, EXPLAINER.md, install.sh, INSTALL.md, landing/index.html, op-welcome/SKILL.md, op-onboard/SKILL.md, 19b-profile-and-onboarding.md. _F5/F6/F7 logged._
- [x] All findings logged in the "Findings" table below with severity.
- [x] Blocking findings appended to `FIXES.md` under a new `A13+` cluster. _Zero blocking; the 4 drift items consolidated into a single A13 paragraph linking back here, per `docs/PROJECT_PLAN.md` L66 (apply order = FIXES severity)._
- [x] PROGRESS.md advanced to audit-02 at `/done`.

## Out of scope (do not drift here)

- **No edits to `chapters/`, `skills/core/`, or code.** Audit phase = write findings only.
- **No benchmark runs.** Section 2 (`audit-02-token-cost`) owns token-cost measurement.
- **No profile-field auditing.** Section 3 (`audit-03-personalization`) owns personalization.
- **No SKILL.md description rewrites.** Section 4 (`audit-04-skill-triggers`) owns triggering accuracy.
- **No anti-pattern audit beyond architecture.** Section 5 (`audit-05-self-discipline`) owns the broader self-discipline sweep.
- **No test-coverage audit.** Section 6 (`audit-06-tests-docs`) owns tests + docs freshness.

If a finding touches another section's surface, capture it in "Cross-section notes" below and move on. Do not bundle.

## Files to read for project understanding (cold-start orientation)

Read in this order at session start. Stop after this list — do not pull additional files until the procedure step calls for them.

1. `CLAUDE.md` — the project soul. The 5-layer architecture, 12 anti-drift rules, 3 load-bearing claims live here. Canonical reference for "what should be true."
2. `INDEX.md` — chapter routing fallback. Section list ↔ chapter folder map.
3. `RECONSTRUCTION.md` — frozen v2 architectural decisions. Supporting evidence for "why is X shaped this way."
4. `FIXES.md` — current open queue. Anything already named in `A1`–`A12` is known; avoid duplicate findings, escalate severity instead.
5. `docs/PROJECT_PLAN.md` — this audit's master plan.
6. This file.

## Pre-flagged findings (captured before Session 1 runs)

- **PF1 — Count-claim sweep already executed (Section 0, 2026-05-28).** During Section 0's pre-audit feature add, the 11-edit count-claim sweep ran across `CLAUDE.md`, `README.md`, `install.sh`, `skills/core/op-welcome/SKILL.md`, `landing/index.html`. Post-sweep claims read "23 op-* skills" and "84 atomic chapters" (exact numbers, no tilde). The sweep also resolved a pre-existing tilde-claim that the work uncovered: docs previously said `~80 chapters` but actual count was 83 before Section 0; post-feature is exact 84. **Session 1's job (changed from "discover the drift" → "verify the sweep is complete and consistent")**: grep the five files above for any residual stale numbers (`22 op-`, `~80`, `19 task-routers`, `83 atomic`, etc.) the sweep might have missed; cross-check against `EXPLAINER.md`, `global/INSTALL.md`, `op-onboard/SKILL.md`, `chapters/personalization/19b-profile-and-onboarding.md`, `INDEX.md`, `RECONSTRUCTION.md` — any of those that names a count must match the new exact totals. **Severity**: `info` (was `blocking` before Section 0 swept).

## Cross-section notes

Discoveries that affect later sections.

- **PF1 partially overstated.** PF1 declared the Section-0 count-claim sweep "complete and consistent." Session 1 found two residuals in README.md (L14 chapter-folder enumeration + L135–143 folder tree both omit `personalization/`) plus a stale `~80 atomic files (<150 lines each)` claim in RECONSTRUCTION.md L11 that contradicts L41–L42 of the same file. The sweep covered five files; README's folder-list surfaces and RECONSTRUCTION's "What v2 was" preamble were not part of the sweep. Captured as F5, F6, F7. Audit-05 (self-discipline) should treat the RECONSTRUCTION L11 inconsistency as a candidate for its rule-violation sweep.
- **For audit-06 (tests + docs).** F8 (chapter 14b cites a non-existent op-onboard section heading) is a stale cross-reference. Audit-06's cross-reference sweep should look for similar broken anchor citations across chapters, not just bare file paths.

## Section-level open questions

- _(none)_

---

## Session 1 — Architectural integrity sweep

**Status**: `done` (2026-05-28)

**Goal**: Produce a triaged findings table naming every router-shape violation, multi-concept chapter, INDEX divergence, and count-claim drift. No code or content edits.

**Files to read** (orient list — exact cold-start budget):

- `CLAUDE.md`
- `INDEX.md`
- `RECONSTRUCTION.md`
- `FIXES.md`
- `docs/PROJECT_PLAN.md`
- This section file.

Additional files opened during the procedure (steps 1–7 below) are read on-demand, not as part of the orientation budget.

**Files to write/edit** (scope — anything else is out of bounds without explicit pause):

- This section file's "Findings" table (populate).
- `FIXES.md` — append a new `A13+` cluster entry per blocking finding.
- `docs/PROGRESS.md` — advance pointer at `/done`.

**Build steps**:

1. **Inventory.** Capture actual counts:
   ```bash
   wc -l skills/core/op-*/SKILL.md | sort -n
   find chapters -name "*.md" -type f | xargs wc -l | sort -n
   ls chapters/
   ls global/commands/
   ls global/hooks/
   ```
   Record: actual count of op-* skills, slash commands, hooks (default-on + opt-in separately), chapter files, chapter folders.

2. **Router-shape audit.** For each `skills/core/op-*/SKILL.md`:
   - Open and read. Is the body making routing decisions ("if X, read chapter Y") or carrying teaching content (procedure steps, question banks, anti-pattern lists)?
   - Flag any SKILL.md that crosses into teaching. **Length alone is not the diagnosis** — content type is. A 200-line router can be fine; a 60-line skill carrying step-by-step procedure is not.
   - Cross-check against the rule in `CLAUDE.md`: "If a SKILL.md is carrying procedure steps, question banks, or teaching material, it has stopped being a router."
   - Confirm adjacent-file pattern is used where applicable (`op-onboard/questions-deep.md`, `op-prepare/procedure.md`, etc.).

3. **Chapter-atomicity audit.** For each `chapters/<topic>/*.md` over 200 lines:
   - Open and skim for multi-concept content. Does the file teach one concept, or two?
   - If two: name the seam where the file should split.
   - For files under 200 lines: trust them unless a router or INDEX entry suggests something's off.

4. **INDEX accuracy.** Compare `INDEX.md`'s section list against the actual `chapters/` folder list:
   - Folders in `chapters/` not represented in `INDEX.md`.
   - INDEX sections that point at folders that don't exist.
   - Chapter files listed in INDEX but missing from disk (or vice versa).

5. **Count-claim sweep.** Compare actual counts (from step 1) against claims in:
   - `CLAUDE.md` (Current state section).
   - `README.md`.
   - `EXPLAINER.md`.
   - `install.sh` (post-install summary).
   - `global/INSTALL.md`.
   - `landing/index.html`.
   - `skills/core/op-welcome/SKILL.md`.
   - `skills/core/op-onboard/SKILL.md`.
   - `chapters/personalization/19b-profile-and-onboarding.md`.
   - `CHANGELOG.md` `[Unreleased]` and `[0.11.0]`.
   
   Known drift already in `FIXES.md`: **A7** (hook count drift — CLAUDE.md says "6 default + 2 opt-in", actual is "4 default + 2 opt-in") and **A8** (landing page lists 9 chapter folders, actual is 10). Avoid duplicating — confirm + reference, or upgrade severity if appropriate.

6. **Layer-boundary check.** Scan for upward references (chapters citing skills, skills citing each other in non-routing ways). Spot-check 3–5 files chosen randomly across topics.

7. **Log findings.** Append to the "Findings" table below using this format:
   ```
   | F# | Severity | File / Loc | Finding | Recommendation |
   ```
   Severities:
   - `blocking` — must fix before further work in this area.
   - `drift` — count / cross-ref drift, schedule normally.
   - `polish` — improvement, not strictly broken.

8. **Triage to `FIXES.md`.** For every `blocking` finding: append under a new heading `## Architecture-audit follow-ups (A13+, 2026-05-28)` (or extend an existing cluster if appropriate). Keep each entry one paragraph; link back to this section file for detail. **Keep entries action-shaped** — if the cluster needs narrative (rationale, discovery context, comparative analysis), let that live in this section file's Findings table and write a single one-paragraph summary entry in FIXES that links here. Discipline is queue-shape, not line count.

**Verify**:

- Every op-* SKILL.md was opened (not just listed). Verify by checking the inventory output covers all 22.
- Every `chapters/<topic>/` folder appears in the INDEX comparison output.
- Counts sourced from disk (step 1) match each file checked in step 5, or each divergence is logged with file:line reference.
- At least one finding exists in the Findings table OR the section file explicitly states "no findings" with the step-1 inventory snapshot as evidence.
- `FIXES.md` after the session is queue-shaped: every entry a discrete, triageable action item; no narrative essays. If audit-01's cluster has drifted into narrative, compact it back into action items + link to this section file's Findings table for the detail before merge.

**Output**:

- Commit message hint: `docs(audit): section 1 — architectural integrity findings`
- Update at `/done`: this section file (Findings filled, status `done`), `docs/PROGRESS.md` (pointer → `audit-02-token-cost`, refresh next session reading list), `FIXES.md` (new `A13+` cluster entries if any).

---

## Findings

Session 1 inventory (2026-05-28, session-start commit `f08b258`): **23 op-* SKILL.md files** (range 32–108 lines), **84 chapters** (range 33–155 lines, max `chapters/persistence/12b-claudemd.md`), **10 chapter folders**, **9 slash commands**, **6 hooks** (4 default-on per `global/settings.json` + 2 opt-in scripts on disk). All counts match the post-Section-0 baseline declared in `CLAUDE.md` L217.

No chapter exceeds the 200-line spot-check threshold; Step 3's audit set is empty by spec. At max effort, the top 8 chapters (12b/155, 06/134, 10-visuals/131, 17b/124, 05k/123, 19f/122, 11-overview/121, 05j/119) were each spot-checked and confirmed one-concept-shaped per the RECONSTRUCTION L34–L40 decomposition rule.

| F# | Severity | File / Loc | Finding | Recommendation |
|---|---|---|---|---|
| F1 | polish | `skills/core/op-onboard/SKILL.md` L31–50 + L52–85 | Two literal ~25-line preview text blocks embedded inline in the "How to run the interview" Step 1. The preview text is emit-payload (operational data), not routing logic. The skill already uses the adjacent-file pattern for every other payload (`questions-essential.md`, `questions-deep.md`, `profile-template.md`, `subscription-tune.md`, `hook-tune.md`, `extras-merge.md`, `handoff.md`); the previews are the lone inline exception and account for ~50 of the 108 lines that put this skill 43 over the 65-line guidance from RECONSTRUCTION L41. | Extract to `skills/core/op-onboard/preview.md` with two named blocks (`essentials-first-run`, `deep-first-run`); SKILL.md Step 1 reads the file and emits the matching block. Drops SKILL.md to ~60 lines. |
| F2 | polish | `skills/core/op-approach/SKILL.md` L75–80 | Redundant TL;DR section. Restates the frontmatter description + the "Output shape" + the "Sibling skills" lines that already appear above. Pure additive content in a router. | Drop the TL;DR. |
| F3 | polish | `skills/core/op-prepare/SKILL.md` L48–54 | Same pattern — redundant TL;DR restates "What to read first" + handoff behaviors already named above. | Drop the TL;DR. |
| F4 | drift | `INDEX.md` (signaling section, L82–89) | `chapters/signaling/11g-push-back-phrasing.md` (98 lines, written 2026-05-28 in bias-audit round 6) exists on disk and is cited by `skills/core/op-signaling/SKILL.md` L22 + `skills/core/op-onboard/handoff.md` + `skills/core/op-spine-active/SKILL.md` L79 — but has no INDEX row. Bidirectional diff: 83 chapter entries in INDEX vs 84 files on disk; exactly this one is missing. | Append row under the Signaling section: `\| Push-back phrasing per Q4 — threshold + tone table, per-category examples \| chapters/signaling/11g-push-back-phrasing.md \| 11 \| written \|`. |
| F5 | drift | `README.md` L14 | Chapter folder enumeration reads "foundations, workflow, prompting, signaling, persistence, tools, subagents, recovery, anti-patterns" — **9 folders, missing `personalization`**. Same drift as A8 (which fixed the equivalent in `landing/index.html` L105). Section-0's 5-file count-claim sweep included README.md but did not touch the topic-list surface. | Append `, personalization` to the comma list. |
| F6 | drift | `README.md` L135–143 | Folder tree under `chapters/` shows 9 subfolders, missing `personalization/`. Tree marker `└──` is on `anti-patterns/`. Same root drift as F5, different surface. | Insert `│   ├── personalization/        # how the spine becomes personal per-user` and demote `anti-patterns/` from `└──` to `├──`; make `personalization/` the new `└──`. |
| F7 | polish | `RECONSTRUCTION.md` L11 | "v2 breaks them into ~80 atomic files (<150 lines each)" carries two stale framings: the count (now 84) and the sizing ceiling (revised to "sized to the concept, not a number" at L41–L42 during pre-launch cleanup). Per CLAUDE.md anti-drift rule 3 RECONSTRUCTION is frozen build history, so the "~80" is defensible as a description of the v2 reconstruction snapshot — but the "<150 lines each" framing now directly contradicts L41–L42 within the same file. | Minimal-touch: append `(see L41–L42 for the revised sizing stance)` to the L11 sentence, or rephrase to `"v2 breaks them into ~80 atomic files at v2 freeze (now 84; sizing approach revised — see L41 below)"`. Frozen-history discipline says don't rewrite, so a one-clause forward-pointer is preferable. |
| F8 | drift | `chapters/persistence/14b-hook-recipes.md` L55 | Cites `skills/core/op-onboard/SKILL.md \`## Hook tuning (deep mode only)\`` — that section heading does not exist in `op-onboard/SKILL.md`. Hook tuning is at Step 7 of the SKILL.md procedure list (line 94, `**If deep ran:** run the **Hook tuning** pass — load \`hook-tune.md\` and follow its flow`); the detailed procedure lives in the adjacent file `skills/core/op-onboard/hook-tune.md` (7137 bytes, written 2026-05-28). The chapter is referring to content that moved during the adjacent-file refactor. | Replace the citation with `skills/core/op-onboard/hook-tune.md` (the file that now holds the procedure). |

**Severity totals:** 0 blocking, 4 drift (F4, F5, F6, F8), 4 polish (F1, F2, F3, F7).

**Done-criteria checkbox basis:**

- Router shape — every op-* SKILL.md opened individually; over-cap-five (op-onboard/108, op-spine-active/92, op-approach/80, op-suggest/71, op-bucket-router/70) given deepest scrutiny. None are content-shaped; the over-cap counts are operational-data inlines (F1) or workflow-encoder carve-outs per RECONSTRUCTION L41.
- Chapter atomicity — zero files >200 lines (max 155); top-8 sample confirmed one-concept-shaped.
- INDEX accuracy — bidirectional diff produced exactly F4 (1 missing row, 0 broken refs).
- Count-claim sweep — 9 named files + RECONSTRUCTION cross-check; F5/F6/F7 are the residuals. PF1 partially overstated (see Cross-section notes).
- Findings logged — table above.
- Blocking findings to FIXES — zero blocking, so no `A13+` cluster created. Drift findings summarized in a single linking entry in `FIXES.md` so the apply pass can order against severity per `docs/PROJECT_PLAN.md` L66.
- PROGRESS.md advance — deferred to `/done`.

---

## Session log

_(per-turn heartbeats appended automatically by `spine-writeback.sh` Stop hook during the active session)_

### 2026-05-28
- Section drafted. Awaiting Session 1.
- Session 1 done. 8 findings (0 blocking, 4 drift, 4 polish); A13 cluster appended to `FIXES.md`. Writes confined to this section file + `FIXES.md`; no `chapters/`/`skills/core/`/code/templates edits this session. (Stop-hook heartbeats — 15:39 and 15:52 lines — reflected the whole-working-tree dirty list per pre-flight rule 3's caveat; actual mutations were 3 Edit calls on 2 files. The verification-method gap is captured in audit-05 PF-cluster territory.)
