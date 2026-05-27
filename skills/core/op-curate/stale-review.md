# Stale-review mode — `/curate --review-stale`

Loaded only when `/curate --review-stale` fires. This is the prune-or-keep pass over `bucket/INDEX.md` for entries from abandoned project types or patterns that never fired in practice. Rationale: [19e §Garbage collection](../../../chapters/personalization/19e-extending-the-bucket.md).

## What stale means here

`bucket/INDEX.md` tracks two dates per row: `Added` (when the row was created) and `Last fired` (when `op-bucket-router` last routed to the row, or `—` if never). Stale-review combines both:

- **Never-fired stale candidate (strongest signal):** `Last fired` is `—` (empty / never) AND `Added` is older than **90 days**. The row has lived in the INDEX for at least three months without `op-bucket-router` ever stamping it — the trigger description and the user's actual work didn't match.
- **Date-based stale candidate (fallback):** any row whose `Added` date is older than **6 months** *and* whose `Last fired` is either empty or older than 6 months. Older content that hasn't been touched in a while.
- **Not stale:** anything fired in the last 6 months, OR anything added in the last 90 days with an empty `Last fired` (too new to evaluate yet).

This is intentionally coarse. The user's judgment, not the date, is the actual filter — the dates just narrow the candidate list. The user can override per-session: "show me everything older than 3 months" / "go through anything never-fired regardless of age" / etc.

## Flow — one stale candidate at a time

1. Read `~/.claude-spine/bucket/INDEX.md`. Collect candidate rows from **both** Skills and Chapters tables, using the two thresholds above (never-fired + 90 days, or 6-months stale). Ask the user if they want a different cutoff before running.
2. If zero candidates: tell the user, stop. Don't synthesize work.
3. Walk candidates in this order:
   - **Never-fired rows first** (these are the strongest signal — added but the trigger never matched real work). Within this group, oldest `Added` first.
   - **Then date-based stale rows** (fired but long ago, or no fire and older than 6 months). Within this group, oldest `Last fired` (or `Added` if `Last fired` empty) first.
   For each candidate:
   - Read the file the row points to (the actual `bucket/skills/<name>.md` or `bucket/chapters/<slug>.md`).
   - Surface a one-paragraph summary: name, age, `Last fired` value, trigger/topic, what the file does in one line.
   - Ask the user: **keep**, **archive** (delete the file), or **edit** (modify in place — out of stale-review scope; defer to a normal curation pass).
4. **On keep** — do nothing. Move on. Optionally: stamp `Last fired` to today *only* if the user explicitly says "I still use this, reset the clock." Don't auto-refresh either date.
5. **On archive** — `rm` the file (skill folder or single `.md`), remove the INDEX row, append a line to `bucket/CHANGELOG.md` under today's date: `- **Removed (stale)** \`bucket/<path>\` — added <YYYY-MM-DD>, last fired <Last fired value | never>. <One-line user-supplied reason>.` Always require a one-line reason — the audit trail is the point.
6. **On edit deferred** — note it, move on; tell the user at the end of the pass to run `/curate` (without `--review-stale`) or hand-edit.
7. Close with one line: N kept, N archived, N deferred.

## Rules

- **One candidate at a time.** Never batch-archive.
- **Never touch core spine, profile, or global stub.** Same hard-refusal table as normal mode in [SKILL.md](SKILL.md).
- **Default cutoffs are conservative.** 90 days for never-fired rows, 6 months for fired-long-ago rows. The user can ask for a tighter or looser window per session.
- **`Added` and `Last fired` are proxies, not truth.** If the user says "I added this last week and forgot to update the date" — believe them; skip. Same for "I used this yesterday but the router forgot to stamp it."
- **Stale-review is opt-in only.** Never auto-fire. Never propose a stale-review at the end of a normal curation pass — that's batching modes.
- **Don't touch `SUGGESTIONS.md`.** Stale-review is about applied bucket entries, not pending suggestions.

## What stale-review is NOT for

- Modifying existing bucket files (use `/curate` normal mode or hand-edit).
- Adding new entries (use `op-add-skill`, `op-curate`, or hand-drop + `/refresh-bucket`).
- Re-scoring suggestions (`SUGGESTIONS.md` archive is read-only after resolution).
- Project-shift triggered cleanup — that's a workflow ([19b](../../../chapters/personalization/19b-profile-and-onboarding.md) §When to re-run): run `/onboard --deep` to update the profile first, *then* `/curate --review-stale` once the new context is set.

## Close

End with the one-line summary. If the user kept everything, say so plainly — that's a legitimate outcome and not a failure of stale-review.
