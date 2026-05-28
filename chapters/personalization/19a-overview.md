# 19a — Personalization overview

`claude-spine` ships static. After install it becomes a **personal, evolving** toolkit — calibrated to who you are on first run, then growing one careful addition at a time as you work. This chapter explains the shape; the rest of `chapters/personalization/` covers the mechanics.

## What "personalization" actually means here

Three things, kept deliberately separate:

| Personalization layer | Where it lives | When it changes | Owner |
|---|---|---|---|
| **Profile** — who you are | `~/.claude/claude-spine-profile.md` (outside the repo) | Only via `/onboard` (initial run + opt-in `--deep`, re-run anytime) | You, through onboarding |
| **Bucket** — what you've added | `bucket/` (inside the spine, append-mostly) | Through the suggestion/curation loop, or manual additions | You, with Claude proposing |
| **Core spine** — the universal toolkit | `chapters/`, `skills/core/` | Only via upstream `git pull` | Repo maintainers |

The split matters. Core is **read-only for users** — that's why `git pull` never produces merge conflicts. Profile and bucket are **append-mostly for you**. Maintainers never write to them; Claude doesn't either, except through the well-defined hooks below.

## The three layers, in one paragraph each

**Profile.** A small markdown file with your subscription, experience level, stack preferences, push-back intensity, answer length, reasoning depth, project context, output format, risk tolerance. Loaded every session via the global stub. It's what makes Claude treat a senior backend engineer differently from a CS student. See [19b](19b-profile-and-onboarding.md).

**Bucket.** A folder at the top of the spine holding your personal skills (`bucket/skills/`), personal chapters (`bucket/chapters/`), a queue of pending suggestions (`bucket/SUGGESTIONS.md`), and an audit log of what got added (`bucket/CHANGELOG.md`). The core skill `op-bucket-router` routes Claude to bucket content when no core skill matched the task. See [19e](19e-extending-the-bucket.md).

**Core spine.** Everything in `chapters/` and `skills/core/`. Never modified per-user. Hard-refused by the curation skill if Claude is ever asked to write there. The maintainer's job; not yours, not Claude's.

## The loop in one diagram

```
normal session ──────► high-signal moment ─► op-suggest logs to
   │                   (explicit ask, 2x        bucket/SUGGESTIONS.md
   │                    friction, /suggest)            │
   │                                                   │
   └───── you keep working ──────────────────────────►─┘
                                                       │
                                                       ▼
                                              ┌─ curation session ─┐
                                              │ /curate            │
                                              │   reads pending    │
                                              │   reads bucket     │
                                              │   proposes diff    │
                                              │   you approve      │
                                              │   writes file +    │
                                              │   updates INDEX +  │
                                              │   appends CHANGELOG│
                                              └────────────────────┘
```

Two halves: **capture** during normal work (cheap, high threshold, no interruption) and **curation** in a dedicated session (slow, deliberate, one change at a time). Mixing them is the failure mode this design avoids — see [19c](19c-suggestion-loop.md) and [19d](19d-curation-session.md).

## Why split capture and curation

Capture has to be silent and high-threshold. If `op-suggest` fired on every "huh, that was weird," `SUGGESTIONS.md` becomes a noisy graveyard and Claude becomes the over-eager intern who keeps interrupting. The capture skill's trigger description is intentionally narrow: explicit user ask, repeated friction, end-of-session reflection, or the manual `/suggest` command.

Curation has to be slow and deliberate. If Claude wrote bucket files during normal work, the speculative-library trap from [13d](../persistence/13d-skill-anti-patterns.md) would re-emerge inside the personalization mechanic itself. `/curate` makes each addition its own decision — read the queue, read the existing bucket, propose a diff, get explicit approval, then write.

This is the same shape as the rest of the spine: reviewer mode first, then executor mode. Just applied to the manual itself.

## What this is NOT

- **Not a sharing model.** Your bucket is yours. No companion repo, no community library, no fork-and-share. If you want to share, that's a manual operation outside the spine.
- **Not auto-modification.** Claude never writes to `chapters/` or `skills/core/`. Never edits the profile silently. Never adds bucket entries without `/curate` approval.
- **Not infinite growth.** Bucket files follow the same discipline as core chapters: one concept per file, sized to what the concept needs, no padding. Curation surfaces stale entries; you prune them.
- **Not a feature factory.** Phase 8 ships *this* loop. Future extensions need their own justification — the chapter [13/18 anti-patterns](../persistence/13d-skill-anti-patterns.md) apply to the personalization mechanic, not just to user skills.

## Where to go from here

- Setting up the profile or re-running the interview → [19b](19b-profile-and-onboarding.md).
- Understanding when Claude captures a suggestion → [19c](19c-suggestion-loop.md).
- Running a curation session → [19d](19d-curation-session.md).
- Adding bucket chapters and skills directly → [19e](19e-extending-the-bucket.md).

## TL;DR

- Three layers: profile (who you are), bucket (what you've added), core spine (universal, read-only).
- Capture is cheap and high-threshold; curation is slow and explicit. They're separate sessions on purpose.
- `git pull` never touches your bucket or profile. Upgrades are conflict-free.
- The personalization loop respects the same anti-patterns it documents — no speculation, no silent writes, no scope creep into the core.
