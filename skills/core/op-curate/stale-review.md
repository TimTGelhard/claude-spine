# Stale-review mode — `/curate --review-stale`

Loaded only when `/curate --review-stale` fires. This is the prune-or-keep pass over `bucket/INDEX.md` for entries from abandoned project types or patterns that never fired in practice. Rationale: [19e §Garbage collection](../../../chapters/personalization/19e-extending-the-bucket.md).

## What stale means here

The bucket doesn't track per-file fire counts or last-used timestamps — that's complexity the spine deliberately doesn't ship. The proxy used here is the `Added` date in `bucket/INDEX.md`:

- **Stale candidate:** any row whose `Added` date is older than 6 months (default; the user can override per-session — "show me everything older than 3 months" / "go through anything older than a year").
- **Not stale:** anything added in the last 6 months. Skip these — too new to evaluate.

This is intentionally coarse. The user's judgment, not the date, is the actual filter — the date just narrows the candidate list.

## Flow — one stale candidate at a time

1. Read `~/.claude-spine/bucket/INDEX.md`. Collect all rows from **both** Skills and Chapters tables whose `Added` date is older than the threshold (default 6 months; ask the user if they want a different cutoff).
2. If zero candidates: tell the user, stop. Don't synthesize work.
3. For each candidate, in order from oldest to newest:
   - Read the file the row points to (the actual `bucket/skills/<name>.md` or `bucket/chapters/<slug>.md`).
   - Surface a one-paragraph summary: name, age, trigger/topic, what the file does in one line.
   - Ask the user: **keep**, **archive** (delete the file), or **edit** (modify in place — out of stale-review scope; defer to a normal curation pass).
4. **On keep** — do nothing. Move on. Optionally: refresh the `Added` date to today *only* if the user explicitly says "I still use this, reset the clock." Don't auto-refresh.
5. **On archive** — `rm` the file (skill folder or single `.md`), remove the INDEX row, append a line to `bucket/CHANGELOG.md` under today's date: `- **Removed (stale)** \`bucket/<path>\` — last used unknown, added <YYYY-MM-DD>. <One-line user-supplied reason>.` Always require a one-line reason — the audit trail is the point.
6. **On edit deferred** — note it, move on; tell the user at the end of the pass to run `/curate` (without `--review-stale`) or hand-edit.
7. Close with one line: N kept, N archived, N deferred.

## Rules

- **One candidate at a time.** Never batch-archive.
- **Never touch core spine, profile, or global stub.** Same hard-refusal table as normal mode in [SKILL.md](SKILL.md).
- **Default cutoff is conservative.** 6 months is the floor; the user can ask for a tighter or looser window per session.
- **`Added` date is a proxy, not truth.** If the user says "I added this last week and forgot to update the date" — believe them; skip.
- **Stale-review is opt-in only.** Never auto-fire. Never propose a stale-review at the end of a normal curation pass — that's batching modes.
- **Don't touch `SUGGESTIONS.md`.** Stale-review is about applied bucket entries, not pending suggestions.

## What stale-review is NOT for

- Modifying existing bucket files (use `/curate` normal mode or hand-edit).
- Adding new entries (use `op-add-skill`, `op-curate`, or hand-drop + `/refresh-bucket`).
- Re-scoring suggestions (`SUGGESTIONS.md` archive is read-only after resolution).
- Project-shift triggered cleanup — that's a workflow ([19b](../../../chapters/personalization/19b-profile-and-onboarding.md) §When to re-run): run `/onboard --deep` to update the profile first, *then* `/curate --review-stale` once the new context is set.

## Close

End with the one-line summary. If the user kept everything, say so plainly — that's a legitimate outcome and not a failure of stale-review.
