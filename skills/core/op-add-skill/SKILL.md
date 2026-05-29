---
name: op-add-skill
description: Use to add a new skill to the user's personal `bucket/skills/` library. Fires when the user says "save this as a skill," "make this a skill," "I want a skill for X," "add this to my bucket," "remember how to do this next time" (a recurring, reusable *procedure* — for a lightweight one-off note to revisit later, that's `/suggest` / op-suggest, not this), or invokes `/add-skill`. Walks the user through naming, the trigger description, and the body; writes the skill file under `~/.claude-spine/bucket/skills/`; appends a row to `~/.claude-spine/bucket/INDEX.md`. Refuses if the pattern isn't reach-for-it-3+-times-worthy — see chapter 13's library thesis.
---

# op-add-skill — write a new bucket skill

Guides the user through adding a personal skill to their bucket. The result is a `bucket/skills/<name>/SKILL.md` (or `<name>.md`) file plus an INDEX row that lets `op-bucket-router` find it later.

## Adjacent files

| File | When |
|---|---|
| `~/.claude-spine/skills/core/op-add-skill/bucket-skill-template.md` | Before writing the new skill file — copy the shape |

## Before writing anything — the gate

Bucket skills are personal-library territory. Chapter 13's anti-pattern is shipping speculative libraries. Refuse to add a skill unless **at least one** of these is true:

- The user has reached for this same pattern **K+ times** already, where **K = `Add-skill minimum fire count`** in `~/.claude/claude-spine-profile.md`'s `## Spine defaults` section, default **3**.
- The user explicitly states: "I do this every project" / "I always X" / "I've corrected Claude on this multiple times."
- There's a concrete repeatable workflow (deploy script, review style, codegen pipeline) the user wants captured.

If none apply, say so plainly: "This sounds like a one-off — not worth a skill yet. Come back when you've reached for it a couple more times." Stop there.

## Steps

1. **Read `~/.claude-spine/bucket/INDEX.md`** — get the existing skill names so you don't collide.
2. **Read `bucket-skill-template.md`** — that's the shape to write.
3. **Gather (one question at a time, free text):**
   - `name` — kebab-case slug, unique vs the INDEX (e.g. `deploy-solvero-site`, `review-rails-migration`).
   - `trigger description` — when should it fire? Specific phrases / situations / file patterns. The clearer this is, the better the skill fires later. If vague, push back.
   - `body` — what Claude should do when it fires. Can be a list of steps, a checklist, links into `~/.claude-spine/chapters/...`, or routing to adjacent files. Keep it under ~55 lines like the core skills.
4. **Decide single-file vs folder:**
   - Single-file (`bucket/skills/<name>.md`) — body is self-contained, no adjacent files needed.
   - Folder (`bucket/skills/<name>/SKILL.md`) — body needs templates, checklists, question banks. Mirrors `op-onboard` / `op-add-skill` itself.
5. **Write the file** with the template's frontmatter + body filled in.
6. **Append a row to the Skills table in `~/.claude-spine/bucket/INDEX.md`** above the `<!-- op-add-skill appends rows above this comment. -->` marker. Format: `| <trigger summary> | <relative path from bucket/> | <YYYY-MM-DD> | — |` (four columns: trigger / file / Added / Last fired; Last fired starts as `—` — it gets stamped by `op-bucket-router` the first time the skill routes here). If the Skills table body holds only the `_(no skills yet — ...)_` empty-marker row, **replace** that row instead of appending — the placeholder exists to make the table render before any real rows land.

## Rules

- **One skill per invocation.** Don't bundle multiple.
- **Never write to `chapters/` or `skills/core/`.** Bucket-only.
- **Never modify the user's existing bucket skills.** Edits are out of scope — the user does those by hand.
- **Trigger description is the make-or-break field.** A vague trigger is a skill that never fires. Push back hard on "uh, when it feels right."

## After writing

Tell the user: (a) the file path, (b) `op-bucket-router` will now find it on matching triggers, (c) re-run with `/add-skill` to add another, (d) hand-edit the file freely — it's plain markdown.
