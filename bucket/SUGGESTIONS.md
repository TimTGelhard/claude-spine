# Bucket SUGGESTIONS — pending capture queue

**Purpose:** queue of high-signal moments captured during normal work by `op-suggest`. Curation (`/curate`) reads `status: pending` entries here, proposes bucket changes one at a time, and flips status to `applied` or `rejected`.

**Status:** empty by design. Entries land here as you work — only when triggers fire (see [chapters/personalization/19c](../chapters/personalization/19c-suggestion-loop.md)).

**Maintenance:**

- `op-suggest` appends new entries (append-only, chronological).
- `op-curate` flips `Status:` fields. Doesn't delete — rejected entries stay for audit.
- Hand-edits are fine — plain markdown.

---

## Entry format

Every entry uses this shape. `op-suggest` writes it; `op-curate` reads it.

```markdown
## [YYYY-MM-DD] short title

- **Type:** new-skill | new-chapter | profile-update | observation
- **Trigger:** [quote the user, or describe the repeated friction, or name the closing reflection]
- **Proposed change:** [concrete; sketch where it would live in the bucket]
- **Status:** pending
```

After curation, `Status:` becomes `applied` or `rejected`. Optional `- **Resolved:** YYYY-MM-DD` line added on resolution.

---

## Pending

_(no pending suggestions yet)_

<!-- op-suggest appends new entries above this comment. Don't move this marker. -->

---

## Applied / rejected (archive)

Resolved entries move below this line on curation, preserving order.

_(empty)_
