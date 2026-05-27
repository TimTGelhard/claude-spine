# 19d — Curation sessions

The curation half of personalization. Where pending suggestions become real bucket files — with reviewer mode, diff previews, and your explicit approval per change. This is the *only* path a suggestion takes from queue to applied. Capture ([19c](19c-suggestion-loop.md)) never writes anywhere but the queue.

## When to run curation

| Trigger | When |
|---|---|
| `/curate` | Whenever you want — manual entry point |
| Claude proposes "want to curate?" | When 5+ entries are pending (default) |
| End of a long session with lots of capture activity | Optional — flush before context fades |

**Don't** run curation in the middle of feature work. It's its own session. The whole reason this isn't done in-line is that mid-task curation drags you into reviewer mode while you're still in executor mode — and produces worse decisions in both directions. One session per kind of work.

## The flow, step by step

1. **Read `bucket/SUGGESTIONS.md`** — pull only `status: pending` entries.
2. **For each entry, before proposing anything**, Claude must read:
   - `bucket/INDEX.md` — what already exists in the bucket
   - Any existing bucket files (skills or chapters) that overlap with the suggestion's topic
3. **Propose a diff to you** — one entry at a time. Either a unified diff against an existing file or a full new file body.
4. **You approve, reject, or edit** — explicit per-change. No batch approvals.
5. **On approve:**
   - Write the file (or apply the diff).
   - Append a row to `bucket/INDEX.md` (new file) or note the modification.
   - Append an entry to `bucket/CHANGELOG.md` with what changed and why.
   - Update the suggestion's status to `applied` in `SUGGESTIONS.md`.
6. **On reject:**
   - Update status to `rejected`.
   - Entry stays in `SUGGESTIONS.md` for audit. Not re-proposed.
7. **Move to the next pending entry.** Repeat until done.

## Read-before-write is a hard rule

The single most common failure mode for any "Claude helps maintain a library" system is silent duplication — proposing a new skill that overlaps with one written three weeks ago. The mitigation is mechanical: `op-curate`'s body lists the exact reads required before any proposal, and the skill refuses to propose without them.

What "reading the bucket first" means in practice:

- Always read `bucket/INDEX.md`. Always.
- If the suggestion's topic matches any existing bucket entry by name or trigger keyword, read those files too — even if the topic seems different. Surface the overlap to the user in the proposal: "this overlaps with `bucket/skills/X` — extend that instead?"
- Don't trust suggestion titles alone. A pending entry might describe the same thing as an existing skill in different words.

If Claude is ever about to propose a bucket addition without having opened `bucket/INDEX.md` this session, that's a curation bug. The rule has no exceptions.

## Diff preview before write

Every proposal shows the actual change before you approve it:

- **New file** → full file body, in a code block.
- **Modification** → unified diff against the existing file.

You see exactly what lands. Approving means "yes, write this." No "approve in principle" — that's reviewer/executor mode-mixing again. If the diff isn't right, edit it inline or reject and let Claude re-propose.

## What curation can and cannot touch

| File type | Curation can… |
|---|---|
| `bucket/skills/*` | Create new, modify existing, delete on explicit user request |
| `bucket/chapters/*` | Create new, modify existing, delete on explicit user request |
| `bucket/INDEX.md` | Always update on apply (mechanical) |
| `bucket/CHANGELOG.md` | Always append on apply (mechanical) |
| `bucket/SUGGESTIONS.md` | Flip statuses; never delete entries |
| `chapters/` (core spine) | **Hard refusal.** Even with explicit user ask. |
| `skills/core/` (core spine) | **Hard refusal.** Same. |
| `~/.claude/claude-spine-profile.md` | **Hard refusal.** Profile is `/onboard` territory ([19b](19b-profile-and-onboarding.md)). |
| `~/.claude/CLAUDE.md` | **Hard refusal.** Global stub is install-time territory. |

Hard refusal means the curation skill body explicitly says "if asked to write here, decline and explain." Core spine modifications go through upstream PRs to the repo, not through user curation. Profile changes go through onboarding. Curation is for the bucket. Period.

## CHANGELOG entries

Every applied suggestion writes a line to `bucket/CHANGELOG.md`:

```markdown
## 2026-MM-DD

- **Added** `bucket/skills/<name>` — [one-line rationale from suggestion]. Suggested 2026-MM-DD.
- **Modified** `bucket/chapters/<file>` — [what changed and why]. Suggested 2026-MM-DD.
```

Append-only, chronological, dated. Same shape as a real changelog. The point isn't ceremony — it's that six months in, when you wonder why a bucket skill exists, the CHANGELOG plus the original `SUGGESTIONS.md` entry give you the full trail.

## Handling overlap, conflict, and merges

When the suggestion overlaps with existing bucket content, curation has three plausible responses:

1. **Extend the existing file** — most common. Add a section, broaden the trigger, fold the new pattern in.
2. **Split the existing file** — the suggestion exposed a seam that wasn't visible before. Two narrower files where one was.
3. **Reject as duplicate** — the existing file already covers it; the suggestion is noise.

Claude proposes one of these explicitly. Don't write a third bucket skill that does almost the same thing as the second one.

## Stale-entry review

When bucket entries from abandoned project types are still around, `/curate --review-stale` walks them with you for prune-or-keep decisions. Auto-archival is not the default — your bucket doesn't decay on a timer. The rule: stale-detection is opt-in, manual, surfaced by you running the flag. Driven by the `Added` date in `bucket/INDEX.md` (default cutoff 6 months, tunable per session). Full procedure in [19e §Garbage collection](19e-extending-the-bucket.md).

## What a healthy curation session looks like

- ~3–8 pending entries reviewed in one sitting.
- Roughly half end up `applied`, half `rejected` — high rejection rate is healthy. Means capture caught more than survived review, which is the design.
- Most `applied` entries are modifications to existing bucket files, not new files. Two-week-old you was probably going to write a 4th overlapping skill.
- CHANGELOG grows by 2–5 lines.
- Session feels slow and deliberate. If you're rushing through, you're not in curation mode — you're back in executor mode and the decisions are getting worse.

## TL;DR

- Curation is a dedicated session. `/curate` to start, or accept the prompt when 5+ pending.
- Read-before-write is hard-enforced: `bucket/INDEX.md` and any overlapping bucket files, *every time*, before proposing.
- Diff preview, one change at a time, explicit per-change approval. No batch.
- Core spine and profile are hard-refused — curation only touches `bucket/`.
- Rejections stay in `SUGGESTIONS.md` as audit trail. Applied changes also write to `bucket/CHANGELOG.md`.
- Half-rejection is healthy. The point is keeping a high signal-to-noise bucket.
