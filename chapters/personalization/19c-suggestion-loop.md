# 19c — The suggestion loop

The capture half of personalization. While you work, Claude watches for moments worth saving and logs them to a queue. Curation is separate ([19d](19d-curation-session.md)) — capture's job is to keep the signal flowing without interrupting.

The whole design assumes: **most "we should save this" moments are wrong**. The trigger conditions are intentionally narrow.

## What gets captured

| Trigger | Why this is high-signal |
|---|---|
| **Explicit user signal** — "we should add this to the manual," "remember this," "next time we hit this, let's…" | You named it. No inference needed. |
| **Repeated friction** — Claude was corrected on the *same* pattern 2+ times in this session | Pattern has earned itself. Past one occurrence, it's noise. |
| **End-of-session reflection** — you close with "what did we learn here?" or a natural stopping point + a learning frame | You've invited the question. |
| **Manual `/suggest` command** | You're using the explicit entry point. |

Notice what's NOT on the list:

- **Speculation.** "It'd be cool if Claude…" never triggers `op-suggest`. The fix is to wait until the pattern actually fires a second time.
- **One-off friction.** A correction that happens once is just a correction. Two times is a pattern.
- **Mid-task ideation.** "Hey, that reminds me…" mid-build is exactly when *not* to fork into capture. Note it; let it surface naturally if it matters.
- **Claude's own hunches.** If Claude noticed something interesting but you didn't react to it, that's not signal. Capture requires user confirmation.

The trigger description in `op-suggest` codifies this. The point is to keep `SUGGESTIONS.md` short — a noisy queue defeats curation. See [13d](../persistence/13d-skill-anti-patterns.md) for the same principle applied to the core spine.

## What gets logged

A single markdown entry appended to `bucket/SUGGESTIONS.md`:

```markdown
## [2026-MM-DD] short title

- **Type:** new-skill | new-chapter | profile-update | observation
- **Trigger:** [what made me propose this — quote the user, or describe the repeated friction]
- **Proposed change:** [concrete description; if a skill or chapter, sketch where it would live in the bucket]
- **Status:** pending
```

Fields explained:

- **Type** — coarse routing for curation. `new-skill` and `new-chapter` write into the bucket. `profile-update` is logged but never auto-applied (profile changes go through `/onboard`; see [19b](19b-profile-and-onboarding.md)). `observation` is the catch-all for "interesting but I'm not sure what to do with it yet."
- **Trigger** — required. Quote the user if explicit; describe the repetition if friction; name the closing reflection if end-of-session. This field is the audit trail — if you're scanning the queue six weeks later and can't tell *why* a suggestion exists, the entry was malformed.
- **Proposed change** — concrete. "Add a skill that handles X" beats "do something about X." If the suggestion is too vague to write a one-line concrete change, it's not ready to log.
- **Status** — always `pending` at capture time. Curation updates to `applied` or `rejected`.

## Append-only, chronological

New entries always go at the bottom. No grouping by type at capture time — that's curation's job. Append-only keeps the file boring to maintain and audit-friendly: every entry has a date, the queue tells the story of when patterns emerged.

## What `op-suggest` does NOT do

- **Doesn't write into `chapters/` or `skills/core/`.** The core is read-only per-user. Suggestions land in the bucket queue only.
- **Doesn't modify existing bucket files.** Capture only appends to `SUGGESTIONS.md`. Existing skills and chapters are touched at curation, with your approval.
- **Doesn't deduplicate at capture time.** If a similar suggestion is already pending, that's information — let it land. Curation merges them.
- **Doesn't interrupt the current task.** Capture is one append. No discussion, no "want me to also…", no scope creep into the work-in-progress.

## The friction-counter problem

"Same friction 2+ times in this session" is the trickiest trigger. The intended shape:

- The *same* mistake, in the *same* direction, corrected by you the *same* way. A genuine pattern.
- Not: "Claude messed up twice this session" (different errors, different corrections).
- Not: "you reminded me of the same thing in two unrelated tasks" (orthogonal contexts).

When Claude is unsure whether the second correction counts as a pattern, the rule is **prefer silence over capture**. A missed signal is a $0 cost — it'll fire again next time. A noisy queue is a $X cost — you'll prune it during curation. Bias toward signal.

## The `/suggest` escape hatch

The slash command is your manual entry point. Use it when:

- You want to capture something Claude didn't notice as high-signal (a pattern you saw, even if you only corrected once).
- The natural triggers didn't fire but you want this in the queue anyway.
- You're closing a session and want to flush a few things at once.

It's also the simplest way to override the high threshold when you're sure.

## End-of-session reflection

When you wrap up with "what did we learn" / "anything to capture?" / similar — Claude reviews the session for moments that *almost* triggered capture and proposes them now, with you confirming each. Different from in-the-moment capture: a small batch, sanity-checked together.

This is the place where one-off frictions can still make it into the queue, *if* you decide they're worth keeping. The end-of-session frame turns Claude's hesitancy into the user's explicit "yes, log that."

## When the queue gets long

You can `/curate` whenever. Past ~5 pending, schedule a session soon; past ~10 it should be this session — past that the queue stops being a queue and becomes a graveyard, which defeats the loop.

**`op-curate-nudge` closes the loop.** This auto-firing skill emits *one* quiet line at the start of any conversation where (a) `bucket/SUGGESTIONS.md` has 5+ pending entries AND (b) the latest `bucket/CHANGELOG.md` date is >30 days ago (or absent). Once per conversation, never per turn. Phrasing:

> Your suggestion queue has N pending entries; last `/curate` was on YYYY-MM-DD (X days ago). Consider running `/curate` when you have ~10 minutes.

The threshold rule prevents the graveyard outcome without becoming nagware. The v1 design deliberately omitted the nudge to avoid noise on every capture above threshold; the v2 design brings it back as a *one-time* conversation-start signal, gated tight enough that a low-velocity user never sees it and a daily-capture user sees it at most once every 30 days. The "rejected during Phase 8e" alternative was the per-capture variant — fire on every append past the threshold. That one is still rejected. This one is the bounded conversation-start variant; it doesn't violate [13d](../persistence/13d-skill-anti-patterns.md) because it fires at most monthly even at full velocity.

If you want to suppress the nudge entirely (e.g., you read SUGGESTIONS.md by hand), unlink `~/.claude/skills/op-curate-nudge` — the file-existence check is what arms it.

## TL;DR

- Capture triggers on four narrow conditions: explicit ask, 2+ same-friction, end-of-session reflection, or `/suggest`.
- Bias toward silence — missed signals cost nothing; queue noise wrecks curation.
- Entries are append-only chronological in `bucket/SUGGESTIONS.md`, with type / trigger / proposed change / status.
- Capture never writes outside the queue. Curation ([19d](19d-curation-session.md)) is where bucket files actually change.
- Profile updates are never auto-applied — they're logged for awareness; the user runs `/onboard` if they want a change.
