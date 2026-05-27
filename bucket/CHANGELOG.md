# Bucket CHANGELOG — applied changes audit log

**Purpose:** append-only record of what `op-curate` added or modified in the bucket, with dates. Read this when you wonder "why is this skill here?" or "when did I add this chapter?"

**Status:** empty by design. Entries land here as `op-curate` applies suggestions (see [chapters/personalization/19d](../chapters/personalization/19d-curation-session.md)).

**Maintenance:**

- `op-curate` appends a line on every `applied` suggestion.
- Newest entries at the bottom, grouped under date headings.
- Hand-edits are fine — plain markdown. Don't delete entries; this is audit, not state.

---

## Entry format

```markdown
## YYYY-MM-DD

- **Added** `bucket/skills/<name>` — [one-line rationale]. Suggested YYYY-MM-DD.
- **Modified** `bucket/chapters/<file>` — [what changed and why]. Suggested YYYY-MM-DD.
- **Deleted** `bucket/skills/<name>` — [why pruned]. (Stale-review or explicit user delete.)
```

---

_(no entries yet)_

<!-- op-curate appends new entries above this comment. Don't move this marker. -->
