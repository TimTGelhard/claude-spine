# Section: apply-01-efficiency-claim

> First apply section. Clears `FIXES.md` **A1** — the token-efficiency reframe (top "Blocking — before LC5").
> Plan-driven; 2 sessions. Drafted 2026-05-29 via `/prep` after the audit phase closed.
> **Filename note:** deliberately omits the substring "token" to dodge the `Read(**/*token*)` deny matcher
> (FIXES A16.3 / audit-05 PF5, still unapplied) — token-named plan files deadlock a cold session's Read
> (audit-02 lived this). Rename once A16.3 narrows the matcher to `Read(**/*_token*)`.

## Section goal

Make load-bearing claim #1 (token efficiency) **true on disk**. LC1 (executed 2026-05-28, audit-02 Path A) **refuted** the naive "spine saves tokens" framing — spine-on used **+75.9% more input tokens** than spine-off on the paired prompts (+28.6% cost/call, Sonnet 4.6). The constraint that actually holds is *bounded per-load cost* (heaviest single-skill load ≈ 8.2k tokens = 4.1% of Sonnet's 200k context — green-zone, audit-02 F3) plus *routing accuracy* (measured by `tests/skill-triggers/`, not this benchmark). This section (1) publishes the real LC1 number in `benchmarks/tokens/REPORT.md` and cleans the run residue, then (2) reframes the claim wording on the live surfaces (CLAUDE.md confirmed; README / landing / EXPLAINER swept) and closes A1.

## Done criteria

A non-developer could check these:

- [x] `benchmarks/tokens/REPORT.md` carries a **disk-derived** headline (per-call input-token delta from `aggregate.py` over the retained pairs — not transcribed from prose), the per-load worst-case (F3: ≈ 8.2k / 4.1%), a "_What this doesn't measure_" caveats section, and a "dropped: N failed runs of M" note. The number reconciles with audit-02 F0 (or the gap is explained in the report). _Done S1: headline +76.6% input (off 58,979 → on 104,148), +28.6% cost, −31.5% output; reconciles with F0's +75.9% (= per-prompt mean-of-means, 59,209) — gap explained in REPORT § Reconciliation. Dropped-runs note: 84 of 171 logged calls._
- [x] `.err` residue (114 files) archived under `benchmarks/tokens/results/archived-pre-publish/`; `results/` top-level retains only the published `__on__` / `__off__` pairs. _Done S1: 114 `.err` + 27 failed-OFF + 24 ON-only raw + full 171-record log archived; `results/raw/` = 63 paired JSON; live `results.jsonl` = 63 paired-ok records._
- [x] `run.sh` preflight (~L72) aborts non-zero on a `claude` version / binary-mtime change mid-run (the exact failure that wiped LC1's spine-on phase). _Done S1: `assert_claude_unchanged` (mtime + version pin, called before every call); unit-tested unchanged→0 / mtime-change→3 / vanished→3._
- [ ] `CLAUDE.md:42` + `:44` reframed: "prove the win" / "Cheaper is the answer" → bounded-per-load-cost + routing-accuracy; the stale "an actual baseline run is the LC1 launch task in FIXES" wording corrected (LC1 ran → cite REPORT.md).
- [ ] `README.md` + `landing/index.html` + `EXPLAINER.md` swept for any "fewer tokens than vanilla / cheaper / saves" comparative-reduction claim; each reframed or confirmed already-safe and noted.
- [ ] `FIXES.md` A1 "LC1 EXECUTED" + "A1 extended" blocks compressed to action lines + a pointer to audit-02 F0–F5 (CLAUDE.md rule 1 — FIXES is an action queue, not a results essay); A1 marked resolved.
- [ ] `CHANGELOG.md` `[Unreleased]` gains one slim Changed bullet; `tests/run.sh` still passes (the `run.sh` edit caused no regression).

## Cross-session notes

Discoveries from earlier sessions in this section that affect later ones. Updated at end-of-session.

- **Reconciled `n` + published headline (Session 1, 2026-05-29).** Session 2 must **cite these, not recompute**:
  - **n = 11 paired prompts** (30 spine-off + 33 spine-on ok calls). The 57/57-on-disk question resolved: 19 prompts × 3 runs × 2 cond = 114 first-pass calls (mostly failed) + a 57-call ON re-run = 171 logged; 87 ok; only 11 prompts kept a surviving pair (8 are ON-only — 4 `ctrl-*` + `hk-typecheck-after-edit`/`pr-bad-output`/`sa-parallel-subagents`/`sg-scope-check` — excluded from every delta).
  - **Headline (call-weighted, paired):** input **+76.6 %** (off 58,979 → on 104,148 tok/call); cost **+28.6 %** (off $0.0680 → on $0.0875); output **−31.5 %** (off 1,015 → on 696 — guidance = tighter answers). `bf-inherited-project` was the one prompt where spine-on was *cheaper* on input (−21.7 %): guidance stopped blind codebase exploration.
  - **Reconciliation with audit-02 F0 is exact:** F0's +75.9 % = the per-prompt **mean-of-means** (off 59,209.48 → on 104,147.88); this report's +76.6 % = the **call-weighted** mean. Both shown in REPORT § Reconciliation. Cost +28.6 % and cache picture (off cc 9.6k/cr 49k · on cc 12.6k/cr 91.5k) match F0 to the decimal.
  - **Per-load worst-case (F3) is the constraint that HOLDS:** heaviest single load `op-onboard --deep` ≈ 8.2k tok (4.1 % of 200k) @ 7 t/l proxy; ≈ 5.9k (2.9 %) at the LC1-measured ~5 t/l. The reframe Session 2 writes: drop "fewer tokens than vanilla" → **"bounded per-load cost + routing accuracy."**
  - **Out-of-scope finding surfaced (do NOT fix in this section):** `aggregate.py`'s **Totals** row is sum-based, so over unequal/unpaired call counts it over-reports (+94.2 % input vs the +76.6 % per-call mean). The published headline uses the per-call mean and REPORT documents why. Fixing `aggregate.py` to emit a per-call-mean row is a separate FIXES item, not A1 — flagged for the user, not actioned here (Session 1 scope = REPORT/run.sh/archive only).

## Section-level open questions

- **57 `__on__` / 57 `__off__` result JSON on disk vs audit-02's "n=11 paired prompts".** Resolve in Session 1 step 1 before publishing any headline. Likely 19 eval prompts × 3 runs = 57, with 11 prompts surviving as complete pairs after the mid-run `claude` upgrade wiped part of the spine-on phase — but the published number must be **what `aggregate.py` actually computes over the retained data**, not a copy of the audit-02 prose.

## Scope guardrail (whole section)

A1 touches **docs / benchmark / install surfaces only**: `CLAUDE.md`, `README.md`, `landing/index.html`, `EXPLAINER.md`, `benchmarks/tokens/*`, `FIXES.md`, `CHANGELOG.md`. **No `chapters/` or `skills/core/` edits** — claim #1's wording lives in `CLAUDE.md`, not a chapter. If a reframe seems to need a chapter or skill edit, stop: that is a different FIXES item, not A1.

---

## Session 1 — Publish the real LC1 number + clean the run residue

**Status**: `done` (2026-05-29) — REPORT.md published (headline +76.6 % input / +28.6 % cost / −31.5 % output, n=11 paired, reconciles with audit-02 F0 to the decimal); 114 `.err` + 51 unpaired/failed raw + full log archived to `results/archived-pre-publish/`; `run.sh` version+mtime guard added (`assert_claude_unchanged`, unit-tested 0/3/3). No API spend (reprocessed existing JSON). `tests/run.sh` green (7 suites). Out-of-scope `aggregate.py` Totals-row finding surfaced in Cross-session notes for the user.

**Goal**: `benchmarks/tokens/REPORT.md` carries the disk-true LC1 headline + per-load worst-case + caveats; the 114 `.err` files are archived; `run.sh` guards against a mid-run `claude` upgrade.

> **No API spend.** `aggregate.py` reprocesses the existing result JSON locally — no new `claude -p` calls. **Do NOT re-run `./run.sh` against the live API** — the LC1 data already exists in `results/`; re-running would cost ~$6+ and is not the task.

**Files to read** (orient before editing — exact list):

- `docs/plans/audit-02-token-cost.md` § Findings **F0–F5** — the executed LC1 numbers + methodology caveats (source for the headline, the "8 ON-only controls", "22-of-23 op-* installed", "single-shot, no cache amortization" notes).
- `benchmarks/tokens/REPORT.md` — current 11-line "_Not run yet_" stub (to be replaced).
- `benchmarks/tokens/README.md` — how the harness + `aggregate.py` work.
- `benchmarks/tokens/run.sh` — esp. the `# ---------- preflight ----------` block (~L72) where the version/mtime guard goes.
- `benchmarks/tokens/aggregate.py` — the columns it emits (drives the REPORT table shape).

**Files to write/edit** (scope — anything else is out of bounds):

- `benchmarks/tokens/REPORT.md` (rewrite stub → published report).
- `benchmarks/tokens/run.sh` (add version/mtime preflight only — no other logic changes).
- `benchmarks/tokens/results/archived-pre-publish/` (new dir; receives the `.err` + any superseded JSON).

**Build steps** (high-level):

1. **Reconcile the data.** Run `python3 aggregate.py` over `results/`; compare its output to audit-02 F0 (+75.9% input, +28.6% cost/call, n=11 paired). Resolve the 57/57-vs-11 count and document the run-multiplicity. The published headline = aggregate.py's output, not the prose.
2. **Archive residue.** `mkdir -p results/archived-pre-publish/`; move all `*.err` (114) + any result JSON not part of the retained published pairs into it. Leave `results/` with only the pairs the headline is computed from.
3. **Write REPORT.md.** Sections: **headline** (per-call input-token delta, sample size, model = Sonnet 4.6, date); **per-prompt table** (aggregate.py output); **per-load worst-case** (F3: heaviest load ≈ 8.2k = 4.1% of 200k — the constraint that *holds*); **_What this doesn't measure_** (ON-only controls lost to the mid-run upgrade; single-shot, no multi-turn cache amortization; 22/23 op-* at run time); **dropped-runs** note (N of M failed).
4. **Harden run.sh.** In the preflight block (~L72): capture `claude --version` + the binary mtime at start; re-check before each call (or at minimum abort if either changed mid-run); exit non-zero with a clear "claude upgraded mid-run — aborting" message.
5. **Regression check.** Run `tests/run.sh` to confirm the `run.sh` edit broke nothing.

**Verify** (concrete):

- `benchmarks/tokens/REPORT.md` headline shows a real number (not "_Not run yet_"), and that number equals `aggregate.py`'s output (re-run, eyeball the match).
- `find results -maxdepth 1 -name '*.err' | wc -l` → `0`; the 114 now live under `results/archived-pre-publish/`.
- Force a version mismatch (e.g., set the stored version string to a dummy) → `run.sh` aborts non-zero with the upgrade message. Revert the fake.
- `tests/run.sh` passes.

**Output**:

- Commit hint: `bench(tokens): publish LC1 results in REPORT.md + archive run residue + version-guard run.sh`
- Update: this section file (Session 1 → `done`; record the reconciled `n` + final headline in Cross-session notes for Session 2), `PROGRESS.md` (pointer → Session 2).

---

## Session 2 — Reframe claim #1 across the doc surfaces + close A1

**Status**: pending

**Goal**: The "spine saves tokens / cheaper" framing is gone from every live surface; `CLAUDE.md:42/44` reframed to "bounded per-load cost + routing accuracy" and citing the now-published REPORT.md; README / landing / EXPLAINER swept; `FIXES.md` A1 compressed + resolved.

**Files to read**:

- This section file's **Cross-session notes** — Session 1's final headline number (cite it; do not recompute).
- `docs/plans/audit-05-self-discipline.md` § Findings **Headline #2** — exact `CLAUDE.md:42/44` reframe rationale + the "README target partly stale — verify the exact line first" note.
- `benchmarks/tokens/REPORT.md` — the published number to cite.
- `CLAUDE.md` L30–44 (the "Token efficiency is the central design constraint" block).
- `README.md` + `landing/index.html` + `EXPLAINER.md` — the sweep targets.
- `FIXES.md` A1 entry (to compress + resolve).

**Files to write/edit** (scope):

- `CLAUDE.md` (L42 + L44 reframe).
- `README.md` / `landing/index.html` / `EXPLAINER.md` (only where a live comparative-reduction claim is found — prep-time sweep hit only CLAUDE.md, so expect minimal/no edits here; verify, don't assume).
- `FIXES.md` (compress the A1 "LC1 EXECUTED" / "A1 extended" blocks; mark A1 resolved).
- `CHANGELOG.md` (`[Unreleased]` Changed bullet).

**Build steps** (high-level):

1. **Broad sweep first** — widen beyond the prep-time grep: search README + landing + EXPLAINER for any "lean / fewer tokens / cheaper / less context / than vanilla / saves" phrasing implying *comparative reduction* vs vanilla Claude Code. List every hit before editing (PF1 methodology — verify, don't trust the prose).
2. **Reframe `CLAUDE.md:42`** — "prove the win" → characterize the per-load cost; drop the stale "an actual baseline run is the LC1 launch task in FIXES" (LC1 ran) → "see `benchmarks/tokens/REPORT.md` for the measured per-load cost."
3. **Reframe `CLAUDE.md:44`** — keep the spirit (don't bloat context) but reframe the test from "make it cheaper" to the real lever: "does this stay within the bounded per-load budget (green-zone), and does it improve routing accuracy?"
4. **Reframe any hit from step 1** → "bounded per-load cost + routing accuracy" (cite REPORT.md). A surface already in the safe "starts lean / on-demand" framing (e.g. README:92 per audit-05) — leave it, note "confirmed already-safe."
5. **Compress FIXES A1** — the ~15-line "LC1 EXECUTED" + "A1 extended" essays → a few action lines + pointer to audit-02 F0–F5 and audit-05 Headline #2 (rule 1). Mark A1 **resolved** per FIXES convention.
6. **CHANGELOG** — `[Unreleased]` → `Changed`: "Token-efficiency claim reframed from 'fewer tokens than vanilla' to 'bounded per-load cost + routing accuracy'; LC1 results published in `benchmarks/tokens/REPORT.md`."

**Verify** (concrete):

- Re-run step 1's broad sweep across CLAUDE.md + README + landing + EXPLAINER → zero remaining "comparative reduction vs vanilla" claims (acceptable framings: bounded-cost / routing-accuracy / lean-on-demand).
- `CLAUDE.md:42` no longer says "LC1 launch task in FIXES"; it cites REPORT.md.
- `FIXES.md` A1 block is action-shaped (no multi-line results essay); A1 marked resolved.
- `tests/run.sh` passes (docs-only edits, but confirm).

**Output**:

- Commit hint: `docs(claim-1): reframe token-efficiency to bounded-per-load-cost + routing-accuracy; close A1`
- Update: this section file (Session 2 → `done`), `PROJECT_PLAN.md` (apply-01 → `done`), `PROGRESS.md` (pointer → `apply-02` — next FIXES cluster by severity, scoped via `/prep`).

## Session log

Append-only. One heartbeat per assistant turn. `/done` rolls these up into a PROGRESS.md entry.

- session 1 @ 2026-05-29 22:45 — touched: docs/PROJECT_PLAN.md benchmarks/sessions/
- Session 1 **done** 2026-05-29. No API spend (reprocessed existing 171-record `results.jsonl` via jq + `aggregate.py`). Published `benchmarks/tokens/REPORT.md` (curated: headline + per-load worst-case + caveats + dropped-runs + F0 reconciliation; tables = `aggregate.py` over the 63 published-pair records). Archived 114 `.err` + 27 failed-OFF + 24 ON-only raw + the full 171-record log to `results/archived-pre-publish/` (with a provenance README); filtered live `results.jsonl` to 63 paired-ok. Hardened `run.sh` with `assert_claude_unchanged` (version+mtime pin before every call; unit-tested 0/3/3, zero API spend). `tests/run.sh` green (7 suites). **Tracked mutations: `benchmarks/tokens/REPORT.md` + `run.sh` only** (the `results/` reorg is gitignored — `benchmarks/tokens/.gitignore:4`); plus this section file + `docs/PROGRESS.md`. Per the heartbeat caveat, the `docs/PROJECT_PLAN.md` M + `benchmarks/sessions/` in the dirty tree are **pre-existing, not this session's**. Pointer → Session 2 (the doc-reframe + A1 close).
- session 2 @ 2026-05-29 23:07 — touched: benchmarks/tokens/REPORT.md benchmarks/tokens/run.sh docs/PROJECT_PLAN.md benchmarks/sessions/
- Session 1 closed via `/done` 2026-05-29. Pending-notes block reviewed: the one auto-captured entry (`aggregate.py` Totals-row finding) was **dismissed** — already promoted to Cross-session notes bullet 5 above. Pointer advanced to Session 2.
