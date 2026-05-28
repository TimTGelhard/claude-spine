# 05k — Work shapes: identify the shape before planning the work

Before deciding *how* to tackle a piece of work, decide *what shape* it is. Different shapes have different default phase structures and different hard rules. Mismatched shape is a predictable failure mode: an audit run as audit-and-apply produces incoherent findings; a refactor that smuggles in feature work bloats the diff; a migration without a cutover plan leaves orphan data; a spike that becomes production decays for years.

This chapter is the catalog. The router is [`op-approach`](../../skills/core/op-approach/SKILL.md), which fires before `op-prepare` for any non-build multi-session work.

## The seven work shapes

Each shape has a default phase order, one or more hard rules, and a small set of common traps. Identify the shape from the user's phrasing; if genuinely ambiguous, ask one short question.

### Build — new feature, project, or capability

- **Phrasing**: *"I want to build X"*, *"let's start a new project"*, *"add a feature for Y"*, *"scope this out"*.
- **Default phases**: scaffold → core → polish → ship. The full seven-stage workflow is the canonical expansion.
- **Hard rule**: ship one feature at a time. If a second feature comes up mid-build, write it down as a follow-up section; do not bundle.
- **Common traps**:
  - Feature creep — more features added mid-build, scope unbounded.
  - Premature optimization — abstracting before the second use case exists.
  - Skipping "scaffold" and starting at "core" — invariably means re-doing it twice.
- **Routes to**: standard `op-prepare` walk → `op-workflow` per session. See [`05-overview.md`](05-overview.md) and the stage chapters [`05a`](05a-stage-0-decide.md) through [`05g`](05g-stage-6-ship.md).

### Audit / review — assess existing structure against a standard

- **Phrasing**: *"audit X"*, *"review the project"*, *"check whether Y holds"*, *"assess the structure"*, *"the project has grown"*.
- **Default phases**: audit-all-domains → triage → apply. One section per audit dimension; one apply section per priority cluster.
- **Hard rule**: **no apply session runs between audit sessions.** An apply-N session mutates state that audit-N+1 was about to read; findings become cross-section-incoherent, and apply sessions planned against different snapshots of the repo can re-break each other's fixes. Audit-then-apply is the load-bearing phase boundary, not a soft preference.
- **Common traps**:
  - Interleaving audit + apply ("incremental: audit-01 → fix → audit-02 → …") — the canonical coherence failure.
  - Findings dumped raw into `FIXES.md` until it's a 2000-line history — see [12b](../persistence/12b-claudemd.md) on FIXES discipline and [18g](../anti-patterns/18g-workflow.md) on the failure mode.
  - Mid-section scope drift — auditing X under cover of auditing Y. Each audit section's "Out of scope" should name sibling sections by ID.
- **Routes to**: `op-prepare` drafts the audit plan; each audit dimension becomes one section. See [05h](05h-multi-session-planning.md) for the hierarchy and [05i](05i-execution-plan-anatomy.md) for the per-section file shape.

### Refactor — change structure, preserve behavior

- **Phrasing**: *"refactor X"*, *"clean up the structure of Y"*, *"split this module"*, *"rename this surface"*.
- **Default phases**: identify seam → write characterization tests → small step → verify → next step.
- **Hard rule**: **no feature work mixed in.** If you find a missing feature mid-refactor, write it down as a follow-up; do not bundle. Reviewers can't distinguish "behavior-preserving" from "behavior-changing" diffs when both are in one PR.
- **Common traps**:
  - Big-bang refactors that can't be reviewed.
  - Mixed-in feature work — diff balloons, review collapses.
  - Untestable seams — refactor proceeds without a safety net; regressions land silently.
- **Routes to**: `op-prepare` with one section per seam. Often pairs with [`op-brownfield`](../../skills/core/op-brownfield/SKILL.md) if the code is inherited or unfamiliar — see [08a](08a-discovery-sequence.md), [08b](08b-safety-patterns.md), [08d](08d-rewrites.md).

### Migration — move from system A to system B

- **Phrasing**: *"migrate to X"*, *"move from A to B"*, *"swap out the Z layer"*, *"deprecate the old path"*.
- **Default phases**: dual-write → backfill → cutover → cleanup of the old path.
- **Hard rule**: **don't leave partial state.** Either complete the migration or revert. An indefinite dual-write becomes a permanent maintenance burden; an incomplete cutover leaves orphan data.
- **Common traps**:
  - Indefinite dual-write — old path lives forever because cleanup never gets scheduled.
  - Orphaned data on cutover — rows written to old system after cutover, lost.
  - Cutover before backfill is verified — irrecoverable data loss in the worst case.
- **Routes to**: `op-prepare` with one section per phase row above. Pair with [17c](../recovery/17c-high-stakes-cases.md) (mid-flight migration recovery) for the high-stakes case.

### Investigation / debug — find a root cause

- **Phrasing**: *"why is X happening?"*, *"debug Y"*, *"investigate the failure"*, *"this keeps breaking"*.
- **Default phases**: reproduce → minimize → bisect → fix → verify.
- **Hard rule**: **fix the root cause, not the symptom.** A symptom-patch makes the error message go away while the bug stays — and surfaces somewhere else later.
- **Common traps**:
  - Symptom-patching — wrapping the failing call in a try/except, hiding the failure.
  - Skipping the repro — fixes that nobody can verify and which can regress silently.
  - Bisect ignored — random hypothesis chosen over the disciplined narrowing-down.
- **Routes to**: often single-session; `op-prepare` overkill. For thorny multi-day bugs, plan as one section. See [17a](../recovery/17a-failure-triage.md) and [17b](../recovery/17b-recovery-moves.md).

### Research / spike — find what's possible

- **Phrasing**: *"can we…?"*, *"spike X"*, *"prototype Y"*, *"explore whether Z is feasible"*.
- **Default phases**: define the question → time-box → learn → decide → discard the spike or operationalize.
- **Hard rule**: **throw away the spike code.** If you decide to operationalize, write the production version fresh — spike code optimizes for learning speed, not maintainability or safety.
- **Common traps**:
  - Spike code becomes production — and decays for years because it was never written to be maintained.
  - No time-box — spike eats the schedule because the question was never bounded.
  - Learning lost — no decision recorded at the end; the team spikes the same question again next quarter.
- **Routes to**: usually outside the full `op-prepare` walk. A short plan note is sufficient: question, time-box, what counts as "learned enough," decision criteria.

### Cleanup / janitor — remove dead code, old TODOs, stale config

- **Phrasing**: *"clean up X"*, *"remove dead code"*, *"prune old TODOs"*, *"delete the legacy Y"*.
- **Default phases**: inventory → confirm-dead → delete → verify nothing broke.
- **Hard rule**: **don't delete what you can't confirm dead.** Grep, run tests, check git blame, check production logs. "I don't see who calls this" is not "this is unused."
- **Common traps**:
  - Deleting live code that's used at runtime but not at compile time (reflection, plugin loaders, dynamic dispatch, configured strings).
  - Deleting "dead" tests that were the only invariant locking down live behavior.
  - Big-bang cleanup — many small ones is safer; one big PR can't be reviewed for what it removes.
- **Routes to**: `op-prepare` if the inventory spans multiple sessions; otherwise a single-session run.

## When the shape is genuinely ambiguous

Ask one short question. Don't guess. The cost of guessing wrong is high — a refactor mistaken for a build silently smuggles feature work in; an audit mistaken for an investigation chases symptoms instead of mapping the surface.

Common ambiguities and the disambiguating question:

| User said | Could be | Ask |
|---|---|---|
| *"clean up the auth module"* | Refactor or Cleanup | "Are you removing dead code, or restructuring the live code?" |
| *"fix the slow queries"* | Investigation or Refactor | "Do we know which queries are slow yet, or is part of the work finding them?" |
| *"improve the test coverage"* | Build (new tests) or Audit (find gaps first) | "Map the gaps first, or start writing tests against an existing target list?" |
| *"move to the new API"* | Migration or Build | "Is the old API going away (migration), or are both APIs staying (new feature against the new one)?" |

## When the work is hybrid

Sometimes a piece of work has two shapes — *"fix this bug AND refactor the surrounding module while I'm in there"*. Split into two efforts, sequence them, surface the dependency in the plan. **Do not run a hybrid.** The hard rules of the two shapes contradict each other: a refactor demands "no feature/fix work mixed in"; a bugfix demands "fix the root cause." Bundled, the diff becomes unreadable and neither rule survives.

The exception: a strictly *trivial* second shape (e.g., one-line cleanup while in the file) — fold it in, mention it in the commit message, move on.

## Cross-references

- Multi-session planning hierarchy: [05h](05h-multi-session-planning.md).
- Per-section plan file anatomy: [05i](05i-execution-plan-anatomy.md).
- Cold-start protocol every session follows: [05j](05j-cold-start-protocol.md).
- The 7-stage workflow (Build shape's expansion): [05](05-overview.md), [05a–05g](05a-stage-0-decide.md).
- Brownfield discovery (often pre-refactor): [08a](08a-discovery-sequence.md), [08b](08b-safety-patterns.md), [08d](08d-rewrites.md).
- Failure triage + recovery (Investigation shape): [17a](../recovery/17a-failure-triage.md), [17b](../recovery/17b-recovery-moves.md), [17c](../recovery/17c-high-stakes-cases.md).
- Routing skill: [`op-approach`](../../skills/core/op-approach/SKILL.md).

## TL;DR

- Identify shape first. Seven shapes: Build / Audit / Refactor / Migration / Investigation / Research / Cleanup.
- Each shape has a default phase order, a hard rule, and 3 common traps. The hard rule is load-bearing — violating it breaks the work in predictable ways.
- Audit-shape's hard rule: **no apply between audits.** Cross-section coherence is the load-bearing reason. This is the rule the spine was missing before this chapter shipped.
- Ambiguous? Ask one short question. Hybrid? Split.
- After shape is identified, `op-prepare` runs the planning walk informed by the shape.
