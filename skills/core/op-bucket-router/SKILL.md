---
name: op-bucket-router
description: Use as the fallback router when the user's task isn't covered by any other core `op-*` skill — checks the user's personal bucket library (`~/.claude-spine/bucket/INDEX.md`, which has both a Skills table and a Chapters table) for a matching entry and loads only the matched file. Fires when another router would normally handle the task but no core chapter covers it (project-specific recipe, stack-specific pattern, user's personal convention, reference for their own architecture), or the user says "do this the way I usually do" / "use my X skill" / "check my bucket" / "is there anything in my chapters about this?". Never invents bucket entries — only routes to existing ones.
---

# op-bucket-router — personal library fallback

The bucket holds the user's *personal* library — both **skills** (procedures fired on a trigger) and **chapters** (references loaded for context). This skill is the router into both tables. Core skills always win — this fires only when none of them matched.

## Bucket-loop gate

Read `~/.claude/claude-spine-profile.md` `## Spine defaults` → `Bucket loop:`. If `off`:

- Implicit fallback fires (no core skill matched) → silent skip; treat as "no bucket support" and answer from the spine + chapters alone.
- Explicit user request ("use my bucket", "do this the way I usually do") → still route. The user knows the bucket exists; honor the ask one-shot. The profile setting changes the *automatic fallback* behavior, not explicit invocation.

Default if the field is absent: `off` (the audit-recommended default after the round-6 flip — a user who never ran `/onboard` shouldn't have implicit bucket fallback firing on every uncaught task; explicit invocation still works).

## When this fires

- No core `op-*` skill matched the user's task **and** the task looks like it could be a learned pattern or a personal reference (project recipe, stack-specific deploy, user's personal review style, "how does my X work").
- The user explicitly says: "use my bucket," "do this the way I usually do," "check my X skill," "is there a skill for this?," "anything in my chapters about Y?"
- Before recommending a new skill or chapter to a user, check whether one already exists in their bucket.

## When NOT to fire

- A core router fits — let it fire instead. The bucket is the *fallback*, not the front door.
- The task is one-off / experimental — don't reach for the bucket for things that won't recur.
- Both tables in `bucket/INDEX.md` show empty markers — say so and move on; don't invent an entry.

## How to route

1. Read `~/.claude-spine/bucket/INDEX.md`.
2. **Skills table first.** Scan for a row whose "Trigger / question" matches a *procedural* task (do these steps, deploy this, review this). If matched, read the listed file (e.g. `~/.claude-spine/bucket/skills/<name>/SKILL.md`) and follow it as a skill. Load adjacent files only if the SKILL.md routes to them.
3. **Chapters table second.** If nothing in Skills, scan Chapters for a row whose topic matches a *reference* question (how does X work, when do I use Y, what's the convention for Z). If matched, read the listed file (e.g. `~/.claude-spine/bucket/chapters/<slug>.md`) as content — don't "fire" it, just incorporate it into your answer.
4. **Both tables can match.** A task that's "deploy + here's how the deploy is structured" might fire a skill *and* pull a chapter. Load both only when they obviously go together.
5. **If no match in either:** tell the user there's no bucket entry for this. Offer `op-add-skill` if it feels like a recurring procedure. Otherwise proceed without bucket support.

## Skills vs chapters — when each fits

| The task is… | Pull from |
|---|---|
| "Do the steps for X" / "deploy / build / review this thing" | **Skill** — procedure on a trigger |
| "How does X work?" / "what's our convention for Y?" / "remind me about Z" | **Chapter** — reference loaded as content |
| "Do X — and explain how it works" | Both, if the skill routes to the chapter; otherwise prefer the skill |

If you're unsure which the user wants, prefer the skill (it produces action; the user can still ask follow-up reference questions).

## Rules

- **Never invent a bucket entry.** If the tables are empty or don't match, the answer is "no bucket match" — not a freshly-imagined skill or chapter.
- **One row at a time.** Don't load multiple skills or multiple chapters unless the user's task is genuinely cross-cutting and the rows obviously belong together.
- **Don't modify the bucket — with one exception.** Writing or editing bucket files is `op-add-skill` (skills) or `op-curate` (chapters and modifications) territory. The one exception: **stamp `Last fired` on the matched row.** See "Stamping Last fired" below.
- **Stale rows happen.** If the listed file is missing, tell the user; suggest `/refresh-bucket` to rescan and rebuild the INDEX.

## Stamping `Last fired`

When you route to a row (Skills *or* Chapters) and actually use its file, update that row's `Last fired` cell to today's date (`YYYY-MM-DD`) using `Edit`. This is the single allowed write into the bucket from this skill.

- **One row per turn.** Only the row whose file you loaded gets stamped. Don't update sibling rows.
- **Single-column edit.** Replace only the trailing cell. Do not rewrite the trigger, file path, or `Added` date.
- **No stamp if you didn't use the file.** Reading INDEX.md and finding no match → no write. Match-but-decline (e.g., the user changed their mind) → no write. Stamping is the "I loaded this and acted on it" signal that `/curate --review-stale` reads later.
- **No stamp on missing-file rows.** If the row's `Skill file` / `Chapter file` path doesn't exist, surface that to the user and recommend `/refresh-bucket` — do not stamp.

## Sibling skills

- Writing a new bucket skill → `op-add-skill`.
- Turning a pending suggestion into a bucket skill or chapter → `op-curate` (via `/curate`).
- Auditing or rebuilding the bucket INDEX → `/refresh-bucket`.
- "Where should this go — bucket / core / project doc?" → `op-persistence` (13a + 13d) and `chapters/personalization/19e`.
