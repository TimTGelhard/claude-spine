# Section: apply-03-self-discipline

> Third apply section. Clears `FIXES.md` **A16** — the self-discipline / audit-infrastructure cluster
> (5 items: PF2/PF3/PF5 bugs + PF4 wording + the rule-12/04a model-ID finding).
> Plan-driven; 2 sessions. Drafted 2026-05-30 via `/prep` (next cluster by severity after apply-02 closed A15).
> **Source of the apply-ready detail:** `docs/plans/audit-05-self-discipline.md` § Findings + § PF1–PF5 table
> (exact loci + fix recipes live there; FIXES A16 summarizes). **`global/` + `skills/core/` + `chapters/` + `CLAUDE.md`
> edits are sanctioned here** — A16 is an audit-routed cluster (not a single user complaint), and the apply phase
> is edit-allowed against these surfaces per `docs/PROJECT_PLAN.md` § Phase 2. The "stable surface" rule in
> `CLAUDE.md` does not block this.
>
> **⚠️ Template-vs-live caveat (load-bearing — read before verifying).** Every A16 fix edits a repo *source*
> (`global/hooks/`, `global/settings.json`, `skills/core/`, `global/commands/`). The *installed* copies that
> actually fire on this machine (`~/.claude/…`) are unchanged until a re-install/sync. So this section fixes the
> shipped template; it does **not** change this session's own heartbeats or the live deny matcher. Verify the repo
> edit + tests; **do not claim the live behavior changed** without a sync. Same class as audit-05 PF5's "running
> `~/.claude/settings.json` needs a manual sync." The live sync is offered as a follow-up at S2 close (like LC6).

## Section goal

Make the spine's **own workflow machinery live the discipline it teaches.** Audit-05 ran the audit phase as a
dogfooding sample and found five places where the spine's tooling doesn't practice what the chapters preach — most
of them surfaced *by biting this very audit/apply pass*: the heartbeat hook that logs the whole dirty tree instead
of the per-turn delta (A16.1 — polluted every audit-phase Session log, including this one), the cold-start skill
that builds from a stubbed section instead of halting for `/prep` (A16.2), the `Read(**/*token*)` deny matcher that
deadlocks reads of any token-named file (A16.3 — forced apply-01/02/03 to dodge file names), the `/done` status
wording that assumes the wrong lifecycle (A16.4), and the rule-12 ↔ `04a` model-ID contradiction plus a CHANGELOG
overclaim and live Opus-4.7→4.8 rot (A16.5). **Session 1** fixes the three functional machinery bugs
(hook / skill / settings — the high-leverage "fix your tools" set). **Session 2** lands the wording tweak +
model-ID reconciliation, then compresses & resolves A16.

## Done criteria

A developer could check each of these:

- [x] **A16.1 — heartbeat delta.** `global/hooks/spine-writeback.sh` computes the `touched:` list as a **per-turn
  delta** (diff against a session-start tree snapshot keyed by `$SESSION_ID`), not the whole dirty tree; the
  cue-capture block no longer re-matches its own `## Pending` notes; `tests/hooks/test-spine-writeback.sh` is
  extended with a delta-tracking case (the path is currently untested) and green.
- [x] **A16.2 — stub handler.** `skills/core/op-spine-active/SKILL.md` Step 2 gains a 4th bullet: status =
  `pending` + a sketch marker → *"Section is stubbed; run `/prep <section>` first."* Stop.
- [x] **A16.3 — deny matcher.** `global/settings.json` deny narrows `Read(**/*token*)` → `Read(**/*_token*)`
  (underscore-anchored, matching the sibling `Read(**/*_secret*)`); optional bonus `Read(**/.env.*)` added. No test
  broke (prep grep confirms nothing asserts the matcher string).
- [x] **A16.4 — `/done` wording.** `global/commands/done.md` Step 2 reflects the `pending`→`done` lifecycle (not
  only `in-progress`→`done`) and makes the section-file-entry-status vs PROGRESS-status split explicit.
- [x] **A16.5 — model IDs reconciled.** The rule-12 ↔ `04a` contradiction is resolved (chosen option applied — see
  open question); `CHANGELOG.md`'s `04a` "replaced with pointers" line is corrected to match disk; `docs/MODELS.md`
  (+ `04a` if its table is kept) refreshed **Opus 4.7 → 4.8** (`claude-opus-4-7` → `claude-opus-4-8`).
- [x] **Honest verify.** The template-vs-live caveat is stated at close; the live `~/.claude` sync is **offered**,
  not silently performed, and not claimed as done unless the user accepts.
- [x] **No bundling.** The CHANGELOG `### Fixed` block also contains the A17.1 `uninstall.sh` H5 line — it is **left
  untouched** (different cluster). `git diff` shows only the A16 files.
- [x] `FIXES.md` A16 compressed to an action-shaped **✅ RESOLVED** entry + pointer to audit-05 Findings (rule 1);
  `CHANGELOG.md` `[Unreleased]` gains one slim bullet. `tests/run.sh` green (7 suites).

## Cross-session notes

Disk-grounded findings from the `/prep` pass (2026-05-30). Both sessions honor these; S2 cites S1's handoff.

- **A16.1 loci (verified).** `spine-writeback.sh`: the `CHANGED=` block is **`:241–254`** (FIXES says `:247` — it's
  inside this block; `git status --porcelain` at `:247`). Cue-capture is **`:294–350`** (`DEFAULT_CUES` `:307`,
  `CANDIDATES` grep `:326`, dedup `grep -qF` `:343`). `$SESSION_ID` is parsed at **`:32`**; a per-session `$TMPDIR`
  convention **already exists** at **`:359–366`** (`SIGNAL_DIR=${TMPDIR}/spine-signals`, per-session marker files) —
  extend it with a `$SESSION_ID.tree` snapshot rather than inventing a new temp scheme. **`test-spine-writeback.sh`
  exists (7.5 KB) but greps clean for `touched`/`CHANGED`/`porcelain`/`delta`/`Session log`** → the heartbeat-delta
  path is **untested**; S1 reads the test first, then adds coverage (don't assume its shape).
- **A16.2 locus (verified).** `op-spine-active/SKILL.md` Step 2 ("Handle missing pieces gracefully") is `:41–45`,
  **exactly 3 bullets** (missing field / missing file / `done`). No `pending`+sketch case. Sketch markers seen in
  stubbed sections: `to be detailed`, `(to be drafted via /prep)`, `Sketch:`.
- **A16.3 locus (verified).** `settings.json:113` = `"Read(**/*token*)"`; sibling `"Read(**/*_secret*)"` at `:112`
  (underscore-anchored — the model to match). Env denies `:108–110` lack `Read(**/.env.*)` (nested dotted env like
  `config/.env.local`) — low-stakes bonus. **No test asserts the matcher** (prep grep over `tests/` clean) → safe.
- **A16.4 locus (verified).** `done.md` Step 2.1 = `:35` ("change from `in-progress` to…"); the audit lifecycle is
  `pending`→`done`. Section-file-status (Step 2) vs PROGRESS-status (Step 4) split is implicit. Low priority.
- **A16.5 loci (verified + sharpened).** `04a-model-tiers.md:9–11` = the literal IDs; `:13` = the "registry wins /
  convenience read" note that *designs* 04a as a sanctioned mirror. Rule-12 wording lives at **two** places —
  `CLAUDE.md:174` (rule 12 proper) **and `:66`** (the "single source of truth … never duplicate names" sibling
  line). The CHANGELOG overclaim is the `04a` "model IDs replaced with pointers" bullet in the `[0.11.0]`
  `### Fixed` block (**same block as the A17.1 `uninstall.sh` H5 line — edit only the 04a bullet**). `docs/MODELS.md`'s
  real model table is **above `:90`** — the audit's `:97–99` citation points at the "How to update this file" steps
  (stale citation; PF1 — find the real table at build time). `MODELS.md:96–99` + `04a:13` together establish 04a as
  a *deliberate* sanctioned mirror → strengthens open-question option (a).
- **Model identity (for A16.5 refresh).** Current lineup per this session's env: **Opus 4.8 = `claude-opus-4-8`**
  (04a says 4.7 — stale), Sonnet 4.6 = `claude-sonnet-4-6` (already current), Haiku 4.5 =
  `claude-haiku-4-5-20251001` (already current). So the refresh is **Opus-only** (4.7→4.8 + the `[1m]` note); don't
  touch Sonnet/Haiku rows.
- **Session 1 → Session 2 handoff** (filled at S1 close 2026-05-30):
  - **A16.1 hook** (`spine-writeback.sh`, +45/−8, now 443 lines). The `CHANGED` block was rewritten: build `CURRENT_TREE` (whole dirty tree, plan/progress filtered, `sort -u`), then compute the per-turn delta via `grep -Fxv -f "$TREE_SNAPSHOT"` against a per-session snapshot at `${SIGNAL_DIR}/${SESSION_ID}.tree`, refreshing the snapshot every turn. **Reused `SIGNAL_DIR`** (`${TMPDIR:-/tmp}/spine-signals`) — redefined locally in the new `[ -n "$SESSION_ID" ]` branch; the long-session block keeps its own identical definition (harmless duplicate, deliberately not hoisted, to keep the diff focused). **Design call:** the first turn of a session = baseline only, **no heartbeat** (a Stop hook can't snapshot before turn-1 edits, so the turn-1 delta is undefined; emitting nothing beats mislabeling pre-existing dirt). No-`SESSION_ID` path falls back to whole-tree. Cue-capture gained one line — `grep -vE '^[[:space:]]*[-*]?[[:space:]]*[(]turn @ '` — to skip the hook's own `- (turn @ …)` Pending entries.
  - **A16.1 test** (`test-spine-writeback.sh`, +109/−9). 5 single-run layout cases → **8 assertions**: `run_hook` takes a 3rd `sid` arg; new `run_hook_delta` helper (baseline → change → delta run). **The real wrinkle (beyond the plan's "add one case"):** the old cases all hardcoded `session_id:"test"` and shared `$TMPDIR`, so per-session snapshots would leak across cases — fixed with a per-run `SID_BASE="spinetest-$$"` prefix + per-case suffixes + cleanup. Cases 1–5 converted to two-run; **6a/6b** = delta correctness (turn 1 baselines silently; turn 2 lists only the new file); **7** = cue self-skip. **Fixture gotcha discovered + fixed:** the cue test must emit **compact JSONL** (`jq -c`), because the hook parses transcripts with `awk /"type":"assistant"/` — a pretty-printed `"type": "assistant"` (with space) never matches. (No transcript path was exercised by the old suite at all.)
  - **A16.2** (`op-spine-active/SKILL.md`, +1). Step 2 gained a 4th bullet: status `pending` + a stub marker (`to be detailed` / `(to be drafted via /prep)` / `Sketch:`) → "run `/prep`; stop."
  - **A16.3** (`settings.json`, +2/−1). Deny narrowed `Read(**/*token*)` → `Read(**/*_token*)`; added `Read(**/.env.*)` after `Read(**/.env)`. JSON re-validated; glob proven both ways (rejects `audit-02-token-cost.md`, still catches `auth_token.json`).
  - **Live-vs-repo (load-bearing — corrects the plan's premise; for the S2 sync offer).** Neither live file is a symlink. **Live hook** = old **301-line** build (`TREE_SNAPSHOT=0`, old whole-tree `CHANGED`, no cue-skip) → genuinely **lags** repo (443); the sync must reconcile this. **Live `settings.json`, however, was already hand-narrowed** to `Read(**/*_token*)` at some earlier point (file dated 2026-05-29) — so the A16.3 token fix is *already effectively live*; live only lacks the new `Read(**/.env.*)` bonus. The plan/FIXES assumption "live deny still `*token*`" was **stale** — verified at S1. This session's own heartbeats still used the **old whole-tree hook**. The S2 sync = re-run `install.sh` (backs up + overwrites per CLAUDE.md), user-offered, never silent.
  - **Line shift:** the hook grew ~+37 net; everything below the `CHANGED` block moved down. S2 doesn't edit the hook, so no action — but re-grep if S2 ever re-cites hook line numbers.
  - **Plan loci were accurate.** A cold-start verification pass re-confirmed every A16 locus against disk (CHANGED `:241/:247`, cue-capture `:294–350`, `SIGNAL_DIR` `:366`, settings `:113`, op-spine-active Step 2 `:41–45`). An early mis-read of the large source files as truncated wrongly flagged the plan as confabulated; corrected via `wc -l`/`grep -n` — **no re-prep was needed.**

## Section-level open questions

- **A16.5 reconciliation — option (a) or (b)?** _(decide at S2 start; it edits the soul file.)_
  - **(a) Reword rule 12** (`CLAUDE.md:174` + `:66`) to sanction *a registry-citing convenience-mirror* while still
    forbidding an un-cited duplicate. Keeps 04a's at-a-glance table.
  - **(b) Reduce `04a`'s table to a pure pointer** (drop the IDs), satisfying rule 12 as currently worded.
  - **Default → (a).** `MODELS.md:96–99` + `04a:13` already *design* 04a as a sanctioned mirror, so the wording is
    what's out of step, not the table; (b) deletes a deliberately-built convenience read. S2 surfaces this to the
    user before editing `CLAUDE.md` (soul file — explicit confirm, not silent).
- **Fold A16.4 into S1 or S2?** It's a `global/commands/done.md` wording tweak (low-pri, discipline-class not
  machinery). **Default: S2.** Cheap to pull into S1 if S2 looks light or S1 finishes early.
- **Live `~/.claude` sync — now or defer?** Offer to sync the user's *installed* hook + settings (re-run
  `install.sh`, or one-line manual edits) at S2 close vs leave as a flagged follow-up like LC6. **Default: offer at
  S2 close; user decides.** Never edit `~/.claude/*` silently — it's the user's machine config, outside the repo diff.

## Scope guardrail (whole section)

A16 touches: `global/hooks/spine-writeback.sh` (+ its test), `skills/core/op-spine-active/SKILL.md`,
`global/settings.json`, `global/commands/done.md`, `chapters/foundations/04a-model-tiers.md`, `CLAUDE.md` (rule 12),
`docs/MODELS.md`, `CHANGELOG.md`, and `FIXES.md` at close (+ an optional status-note in
`docs/plans/audit-05-self-discipline.md`). **No `chapters/` beyond `04a`. No `skills/core/` beyond
`op-spine-active`.** **Do NOT touch the A17.1 `uninstall.sh` line** even though it sits in the same CHANGELOG
`### Fixed` block — that's a different cluster. **Do NOT edit the live `~/.claude/*` installed copies as part of the
repo diff** (that's a separate, offered follow-up). If a fix seems to need a surface outside this list, **stop** —
it's a different FIXES item, not A16.

---

## Session 1 — Fix the workflow-machinery bugs (heartbeat / cold-start / deny)

**Status**: `done` — 2026-05-30 (no API spend). A16.1 (hook per-turn delta + cue self-skip + test 5→8 assertions), A16.2 (op-spine-active stub bullet), A16.3 (deny matcher narrowed + nested-env deny). `tests/run.sh` green (7 suites). Repo sources only — live `~/.claude` copies not synced (see handoff). See the **S1 → S2 handoff** under Cross-session notes.

**Goal**: The three functional self-tooling bugs that degraded this very audit/apply pass are fixed at the source —
the heartbeat hook logs per-turn deltas (A16.1), `op-spine-active` halts on a stubbed section (A16.2), and the deny
matcher stops over-matching token-named paths (A16.3).

**Files to read** (orient before editing — exact list):

- `docs/plans/audit-05-self-discipline.md` § **PF1–PF5 table** (PF2/PF3/PF5 rows) + § **Findings** — confirmed
  extent + fix loci.
- `global/hooks/spine-writeback.sh` — full (A16.1: `CHANGED` block `:241–254`, cue-capture `:294–350`, `$SESSION_ID`
  `:32`, `SIGNAL_DIR` per-session pattern `:359–366`).
- `tests/hooks/test-spine-writeback.sh` — full (see what's covered; the delta path is likely untested).
- `skills/core/op-spine-active/SKILL.md` — Step 2 (`:41–45`).
- `global/settings.json` — the deny array (`:105–115`).
- `tests/run.sh` (top) — confirm how the suites are invoked; reconfirm nothing under `tests/` asserts the
  deny-matcher string before editing it.

**Files to write/edit** (scope — anything else is out of bounds):

- `global/hooks/spine-writeback.sh` — A16.1: delta-since-session-start `CHANGED` + cue-capture self-skip.
- `tests/hooks/test-spine-writeback.sh` — extend with a delta-tracking case (and a cue-self-capture case if feasible).
- `skills/core/op-spine-active/SKILL.md` — A16.2: the 4th Step-2 bullet.
- `global/settings.json` — A16.3: narrow `:113` → `Read(**/*_token*)`; optional `Read(**/.env.*)`.

**Build steps** (high-level):

1. **Read all + the PF table.** Confirm each locus still matches (PF1 — FIXES line numbers are known-approximate;
   e.g. `:247` is inside the `:241–254` block).
2. **A16.1 hook fix.** At a session's first turn (keyed by `$SESSION_ID`), snapshot `git status --porcelain` to a
   per-session marker under the existing `SIGNAL_DIR` (e.g. `$SESSION_ID.tree`); compute `CHANGED` as the delta vs
   that snapshot, refreshing it each turn — so a heartbeat lists only files dirtied *this* turn. Then fix cue-capture
   so candidate lines that match the Pending block's own shape (e.g. lead with `- (turn @`) or already appear there
   are skipped.
3. **A16.2.** Add the 4th bullet to `op-spine-active` Step 2 (`pending` + sketch-marker → "Section is stubbed; run
   `/prep <section>`; stop").
4. **A16.3.** Narrow the deny matcher (`*token*` → `*_token*`); optionally add the nested-env deny. Re-confirm no
   test asserts the old string.
5. **Extend the hook test** for the delta behavior; run `tests/run.sh` (7 suites green).

**Verify** (concrete):

- **Hook delta:** a constructed two-turn fixture where turn 2 dirties a *new* file shows **only that file** in the
  turn-2 heartbeat (not the whole pre-existing dirty tree); the test asserts it.
- **Cue self-skip:** a turn whose text echoes a prior Pending note does **not** re-append it.
- **op-spine-active:** Step 2 now has a 4th bullet covering `pending` + sketch.
- **settings.json:** `Read(**/*_token*)` replaces `Read(**/*token*)`; reason through the glob — a `…-token-…`
  hyphenated path is no longer denied (the running install is unchanged until sync; **state this**).
- `tests/run.sh` passes (7 suites). **Template-vs-live caveat stated:** the running hook/settings are unchanged
  until a re-install/sync — do **not** claim this session's own heartbeats improved.

**Output**:

- Commit hint: `fix(self-tooling): heartbeat per-turn delta + op-spine-active stub handler + deny-matcher narrow (A16.1–A16.3)`
- Update: this file (S1 → `done`; fill the **S1 → S2 handoff** note — hook diff shape, snapshot reuse of
  `SIGNAL_DIR`, new test-case name, any line-number shift), `PROGRESS.md` (pointer → Session 2).

---

## Session 2 — Discipline wording + model-ID reconciliation + close A16

**Status**: `done` — 2026-05-30 (no API spend). A16.4 `done.md` wording + A16.5 rule-12 reword (**option (a)**, user-confirmed) + Opus 4.7→4.8 refresh + CHANGELOG overclaim correction; **A16 compressed & RESOLVED**. `tests/run.sh` green (7 suites). Repo sources only — live `~/.claude` sync **offered at close, not performed**. Detail in the S2 Session log entry below. **apply-03 section COMPLETE.**

**Goal**: The low-priority `/done` wording (A16.4) + the rule-12 ↔ `04a` model-ID contradiction, CHANGELOG
overclaim, and Opus 4.7→4.8 refresh (A16.5) land; `FIXES.md` A16 is compressed + resolved; the live-sync follow-up
is offered.

**Files to read**:

- This file's **Cross-session notes** + the **S1 → S2 handoff** (cite it; don't re-derive what shipped).
- `docs/plans/audit-05-self-discipline.md` § **Findings** (Headline #1 rule-12/04a + the PF4 row).
- `global/commands/done.md` — Step 2 (`:32–46`).
- `chapters/foundations/04a-model-tiers.md` — the table (`:7–13`).
- `CLAUDE.md` — rule 12 (`:174`) + the sibling statement (`:66`).
- `docs/MODELS.md` — find the actual "Current model lineup" table (**above `:90`**; the audit's `:97–99` is stale).
- `CHANGELOG.md` — the `[0.11.0]` `### Fixed` block (the `04a` "replaced with pointers" bullet; **do not touch the
  adjacent `uninstall.sh` H5 line** — A17).
- `FIXES.md` § **A16** — the block to compress.

**Files to write/edit** (scope):

- `global/commands/done.md` — A16.4 wording (lifecycle + section-vs-PROGRESS status split).
- **A16.5 reconciliation (resolve the open question first):** *(a)* `CLAUDE.md:66` + `:174` reword **or** *(b)*
  `chapters/foundations/04a-model-tiers.md` table → pure pointer.
- `docs/MODELS.md` (+ `chapters/foundations/04a-model-tiers.md` **only if option (a) keeps the table**) — refresh
  Opus 4.7 → 4.8 (`claude-opus-4-7` → `claude-opus-4-8`); move the 4.7 row to "Older releases" per MODELS.md's own
  "How to update" steps.
- `CHANGELOG.md` — correct the `04a` "replaced with pointers" bullet to match disk (table kept + pointer added); add
  one `[Unreleased]` bullet for A16. **Leave the `uninstall.sh` H5 line.**
- `FIXES.md` — compress A16 → action-shaped **✅ RESOLVED** + pointer to `audit-05` Findings (rule 1).
- _(optional)_ `docs/plans/audit-05-self-discipline.md` — status-note "A16 applied 2026-MM-DD" (don't re-open the
  frozen findings).

**Build steps** (high-level):

1. **Resolve the A16.5 (a)/(b) open question** with the user (recommend (a)).
2. **Apply A16.4** done.md wording.
3. **Apply the chosen A16.5 reconciliation** (CLAUDE.md reword OR 04a→pointer).
4. **Refresh Opus 4.7→4.8** in MODELS.md (+ 04a if its table is kept); confirm Sonnet/Haiku rows are already current
   (they are — don't touch them).
5. **Correct the CHANGELOG `04a` bullet**; add the `[Unreleased]` A16 bullet. **Do not touch the uninstall H5 line.**
6. **Compress + resolve FIXES A16** (rule 1).
7. **Offer the live-sync follow-up** (re-run `install.sh`, or one-line manual edits to `~/.claude/settings.json` +
   the installed hook); user decides — don't edit `~/.claude/*` silently.
8. **Run `tests/run.sh`.**

**Verify** (concrete):

- `done.md` Step 2 reflects the `pending`→`done` lifecycle + an explicit section-file-vs-PROGRESS status split.
- `grep -rEn 'claude-(opus|sonnet|haiku)-' chapters/` matches the **chosen** design — either rule 12 now sanctions
  the cited mirror in `04a`, or `04a` carries no literal IDs (option b).
- `docs/MODELS.md` (+ `04a` if kept) say Opus **4.8 / `claude-opus-4-8`**; no `4-7` left labeled "current."
- The CHANGELOG `04a` bullet matches disk; the `uninstall.sh` H5 line is **untouched**.
- `FIXES.md` A16 is action-shaped **✅ RESOLVED** + pointer; `CHANGELOG.md` `[Unreleased]` has one new bullet.
- `tests/run.sh` passes (7 suites).

**Output**:

- Commit hint: `fix(self-tooling): /done wording + reconcile rule-12↔04a model IDs + refresh Opus 4.7→4.8; close A16`
- Update: this file (S2 → `done`), `PROJECT_PLAN.md` (apply-03 → `done`; Sections table + Status log),
  `PROGRESS.md` (pointer → `apply-04` — next FIXES cluster by severity: A17 / A2 / A12, scoped via `/prep`).

## Session log

Append-only. One heartbeat per assistant turn. `/done` rolls these up into a PROGRESS.md entry.

- `/prep apply-03` @ 2026-05-30 — section drafted (2 sessions): S1 fixes the 3 functional machinery bugs
  (A16.1 heartbeat delta + A16.2 op-spine-active stub handler + A16.3 deny-matcher narrow); S2 does A16.4 `/done`
  wording + A16.5 rule-12↔04a model-ID reconciliation + Opus 4.7→4.8 refresh, then compresses & closes A16. Chose
  **A16** per FIXES severity (user-confirmed against A17 / A2 / A12 — the documented lead + cheapest early-apply +
  fixes tools that bit this very pass). Disk-grounded at prep (PF1): CHANGED block `:241–254` not `:247`; rule-12
  wording at **both** `CLAUDE.md:174` + `:66`; CHANGELOG `04a` overclaim shares a `### Fixed` block with the A17.1
  uninstall line (no-bundling flag); MODELS.md model table is above `:90` (audit `:97–99` = stale "How to update"
  region); `test-spine-writeback.sh` greps clean for the heartbeat-delta path (untested → add a case); no test
  asserts the deny matcher (A16.3 safe). **Template-vs-live caveat** recorded as load-bearing: A16 edits repo
  sources; the installed `~/.claude` copies need a sync before behavior changes. Filename `self-discipline` omits
  `token` to clear the still-live A16.3 deny matcher. No code/doc edits this session (plan only). Pointer → apply-03
  Session 1.
- session 1 @ 2026-05-30 09:21 — touched: docs/PROJECT_PLAN.md benchmarks/sessions/
- session 2 @ 2026-05-30 10:19 — touched: docs/PROJECT_PLAN.md global/hooks/spine-writeback.sh global/settings.json skills/core/op-spine-active/SKILL.md tests/hooks/test-spine-writeback.sh benchmarks/sessions/
- **Session 2 done 2026-05-30 (no API spend) — apply-03 section COMPLETE.** A16.4 + A16.5 + close A16. **A16.4:** `done.md` Step 2 reworded — set the section-file Session-N status (no longer assumes `in-progress`; the plan/audit lifecycle is often `pending`→`done`) + explicit section-file-vs-PROGRESS status split. **A16.5 (option (a), user-confirmed at S2 start):** rule 12 (`CLAUDE.md:174`) + the `:66` sibling reworded to sanction a *registry-citing convenience mirror* (today only `04a`) while still forbidding un-cited duplicates — resolves the rule-wording-vs-design contradiction without deleting 04a's at-a-glance table; `04a:9` + `MODELS.md` (lineup row + 1M-variant note + new Older-releases row + date) refreshed **Opus 4.7→4.8 / `claude-opus-4-8`** (Sonnet/Haiku already current — untouched; the two `claude-opus-4-7` literals in `docs/v1-archive/` + `docs/evaluation/REPORT-2026-05-28.md` are frozen historical records, left); `CHANGELOG:112` 04a "replaced with pointers" overclaim corrected to match disk (table kept + pointer added). **A16 compressed** in FIXES (intro + 5 sub-bullets → one action-shaped ✅ RESOLVED entry + pointers, rule 1); `CHANGELOG [Unreleased]` gained one Fixed bullet. **No-bundling honored:** the adjacent `CHANGELOG:107` A17.1 `uninstall.sh` H5 line left untouched; `git diff` = only A16 files + plan/progress docs. **Verify:** `tests/run.sh` 7 suites / 0 fail; model-ID grep clean (chapters/ carries only the sanctioned 04a mirror, now 4-8; no 4-7 labeled current); deny matcher confirmed `*_token*`+`.env.*` (S1). **Template-vs-live caveat (unchanged, load-bearing):** all edits are repo *sources* — the installed `~/.claude` hook is still the old 301-line whole-tree build, so this session's own heartbeats still logged whole-tree, not the new delta. **Live sync (re-run `install.sh`) offered at close, NOT performed.** Pointer → apply-04 (needs `/prep`; A17 / A2 / A12 by FIXES severity).
