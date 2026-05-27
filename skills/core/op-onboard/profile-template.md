# Profile file template

Write to `~/.claude/claude-spine-profile.md` using **this exact section structure**. Future tooling parses these headings — don't add sections that aren't here, and don't rename them.

For essentials-only runs (deep deferred), keep the deep section headings but write `(unfilled — run /onboard --deep to capture)` underneath each. The full structure stays so the user can see what's missing.

---

## The file to write

````markdown
# Claude Spine — Personal Profile

> Calibration captured by `op-onboard`. Claude reads this every session — it overrides defaults in the spine's chapters for this user.
> Captured: YYYY-MM-DD
> Last updated: YYYY-MM-DD
> Re-run: `/onboard` (essentials) or `/onboard --deep` (full). Hand-editing is fine — it's plain markdown.

## Subscription

- **Plan:** {{Q1 answer}}
- **Daily usage:** {{0A, or "(unfilled — run /onboard --deep)"}}
- **Cost sensitivity:** {{0B, or "(unfilled — run /onboard --deep)"}}

## Developer profile

- **Experience level:** {{Q2 answer}}
- **Years coding:** {{A1, or "(unfilled — run /onboard --deep)"}}
- **Comfort areas:** {{A2 list, comma-separated, or unfilled}}
- **Lean-in areas:** {{A3 list, comma-separated, or unfilled}}

## Stack preferences

- **Primary:** {{Q3 answer}}
- **Secondary:** {{B1, or unfilled}}
- **Avoid:** {{B2 list, or unfilled}}

## Project context

- **Typical work:** {{Q6 answer}}
- **Team size:** {{C1, or unfilled}}
- **User scale:** {{C2, or unfilled}}

## Working style

- **Push-back intensity:** {{Q4 answer}}
- **Answer length:** {{Q5a answer}}
- **Reasoning depth:** {{Q5b answer}}
- **Active signals:** {{D1 list, or "All four (default)"}}

## Output format

- **Code presentation:** {{E1, or "Diffs and snippets (default)"}}
- **Comments / emojis:** {{E2, or "Minimal comments, no emojis (default)"}}

## Risk + safety

- **Command tolerance:** {{F1, or "Ask before running anything that writes (default)"}}

## Notes

{{free-text from post-F1 follow-up. Omit this section entirely if the user had nothing to add.}}
````

---

## Writing rules

1. Use ATX headings (`#`, `##`) exactly as shown. One blank line between sections.
2. Bold field labels in bullets — exactly as written.
3. **Don't add sections** that aren't in the template. Keeps the file machine-parseable.
4. **No commentary or explanatory prose** in the file. Captured data only.
5. **On re-run:** read the existing file first. Preserve unchanged values. Only update the ones the user re-answered. Always bump `Last updated:`.
6. Dates are absolute ISO format: `2026-05-27`. Today's date is in the session context.
7. If a section is unfilled, write the literal string `(unfilled — run /onboard --deep to capture)` under it — don't leave the bullets blank.
