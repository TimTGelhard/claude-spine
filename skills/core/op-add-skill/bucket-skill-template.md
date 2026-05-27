# Bucket skill template

Copy this shape when writing a new entry under `~/.claude-spine/bucket/skills/`. Fill the `{{placeholders}}`. Strip lines that don't apply.

---

## Single-file form (`bucket/skills/<name>.md`)

```markdown
---
name: {{name}}
description: {{trigger description — when this skill should fire. Be specific: phrases, file patterns, situations. The clearer, the better. See ~/.claude-spine/chapters/persistence/13b-trigger-descriptions.md for trigger-writing rules.}}
---

# {{name}} — {{one-line purpose}}

{{One short paragraph: what this skill does and why it exists. Mention the recurring pattern that earned its place in the bucket.}}

## When this fires

- {{Specific situation 1}}
- {{Specific situation 2}}
- {{Explicit user phrase that should trigger it}}

## Steps (or checklist, or routing — pick what fits)

1. {{First action — be concrete}}
2. {{Second action}}
3. {{Third action}}

## Rules

- {{Hard rule the skill must follow}}
- {{Another rule}}

## Sibling skills / cross-refs

- {{Related bucket skill or core skill, if any}}
- {{Pointer to an atomic chapter that backs this up, e.g. ~/.claude-spine/chapters/<topic>/<file>.md}}
```

---

## Folder form (`bucket/skills/<name>/SKILL.md` + adjacent files)

Use this when the body needs templates, question banks, checklists, or anything else that should be loaded on-demand. Same frontmatter rules as single-file. SKILL.md stays ≤55 lines and routes to the adjacent files:

```markdown
## Adjacent files

| File | When |
|---|---|
| `~/.claude-spine/bucket/skills/<name>/<file-1>.md` | {{when to load it}} |
| `~/.claude-spine/bucket/skills/<name>/<file-2>.md` | {{when to load it}} |
```

Adjacent files are plain markdown — checklists, templates, question lists, longer prose. No frontmatter on those.

---

## Frontmatter rules (the only hard ones)

- `name:` matches the file/folder name. Kebab-case. Unique in the bucket.
- `description:` is *the* trigger field. Write it as: "Use when {situation}. Fires when {phrase | pattern | condition}. Routes to {target}." Concrete phrases beat vague concepts. See `~/.claude-spine/chapters/persistence/13b-trigger-descriptions.md` if unsure.

## Body rules (the only hard ones)

- **Skill bodies route — they don't hold content.** If the body crosses ~55 lines, the extra material is content; extract it to an adjacent file and link to it from the SKILL.md.
- **Reference paths use `~/.claude-spine/...`**, not absolute machine paths. They resolve via the `~/.claude-spine` symlink that `install.sh` sets up.
- **Cross-references** between bucket skills are fine. Pointing into `chapters/` is fine. Don't duplicate chapter content — link to it.
