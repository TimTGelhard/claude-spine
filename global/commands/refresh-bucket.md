---
description: Rescan ~/.claude-spine/bucket/skills/ and ~/.claude-spine/bucket/chapters/, then rebuild both tables in bucket/INDEX.md. Use after dropping a bucket skill or chapter in by hand (without going through op-add-skill or op-curate), or to clean up stale rows that point at missing files.
---

Rebuild the bucket INDEX from what's actually on disk. Two tables are rebuilt: **Skills** and **Chapters**.

## Steps

1. **Scan `~/.claude-spine/bucket/skills/`.** For each entry directly under it:
   - Folder containing a `SKILL.md` → folder-form skill; path is `skills/<name>/SKILL.md`.
   - Single `.md` file → single-file skill; path is `skills/<name>.md`.
   - Anything else (stray non-`.md` file, empty folder, `.gitkeep`) → skip.
2. **Scan `~/.claude-spine/bucket/chapters/`.** For each entry directly under it:
   - Single `.md` file → chapter; path is `chapters/<slug>.md`.
   - Folder, non-`.md` file, `.gitkeep` → skip. (Bucket chapters are flat single files, per [19e](../../chapters/personalization/19e-extending-the-bucket.md).)
3. **For each found skill,** parse the frontmatter `description:` field → that's the trigger summary for the Skills row.
4. **For each found chapter,** read the first H1 (`# ...`) or the first non-empty line if there's no H1 → that's the topic summary for the Chapters row. (No frontmatter convention for bucket chapters; the H1 is the title.)
5. **Read the current `~/.claude-spine/bucket/INDEX.md`** to get existing rows in both tables, so `Added` *and* `Last fired` are preserved for rows whose file still exists.
6. **Rewrite `~/.claude-spine/bucket/INDEX.md`:**
   - Keep the file header, the "How files are organized" section, the section headers, and both `<!-- ... appends rows above this comment. -->` markers — these are static.
   - **Skills table** body: one row per found skill: `| <trigger summary, condensed if >120 chars> | <path from bucket/> | <YYYY-MM-DD added — preserved if the row existed, today if new> | <Last fired — preserved if the row existed, `—` if new> |` (four columns). If no skills exist, restore the empty-marker row.
   - **Chapters table** body: same shape, one row per found chapter, using the H1 topic as the summary. If no chapters exist, restore the empty-marker row.
7. **Show the user a unified diff** of what changed before saving. Bail if they say no.
8. **After save,** tell the user: count of skills indexed, count of chapters indexed, any stale rows removed (rows pointing at missing files), any new rows added.

## Rules

- **Read-only on `chapters/` and `skills/core/`.** This command only touches `bucket/INDEX.md`.
- **Don't invent rows.** If a skill's frontmatter description is missing or malformed, or a chapter has no H1 *and* no usable first line, list the file in the output but don't add a row — tell the user to fix it.
- **Don't delete the user's bucket files.** Stale-row cleanup means removing INDEX entries that point at missing files. The actual files are never touched.
- **Preserve marker order.** Skills table marker stays at the bottom of the Skills section; Chapters table marker at the bottom of the Chapters section. Don't merge or move them.
