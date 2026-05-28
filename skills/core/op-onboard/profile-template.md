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

## Environment

- **OS:** {{Q7 answer}}
- **VCS host:** {{Q8 answer}}
- **Plans dir:** {{G2, or "(unfilled — run /onboard --deep to capture)"}}
- **Currency:** {{H3, or "(unfilled — run /onboard --deep to capture)"}}

## Project context

- **Typical work:** {{Q6 answer}}
- **Artifact:** {{Q9 answer}}
- **Team size:** {{C1, or unfilled}}
- **User scale:** {{C2, or unfilled}}
- **Org shape:** {{H2, or "(unfilled — run /onboard --deep to capture)"}}

## Working style

- **Push-back intensity:** {{Q4 answer}}
- **Answer length:** {{Q5a answer}}
- **Reasoning depth:** {{Q5b answer}}
- **Active signals:** {{D1 list, or "All four (default)"}}
- **Session shape:** {{G1, or "(unfilled — run /onboard --deep to capture)"}}

## Output format

- **Code presentation:** {{E1, or "Diffs and snippets (default)"}}
- **Comments / emojis:** {{E2, or "Minimal comments, no emojis (default)"}}

## Risk + safety

- **Command tolerance:** {{F1, or "Ask before running anything that writes (default)"}}

## Notes

{{free-text from post-F1 follow-up. Omit this section entirely if the user had nothing to add.}}

## Spine defaults

> Optional thresholds and cue phrases the spine's skills + hooks read at runtime. Comment out (or delete) a line to fall back to the shipped default in parentheses. These survive `git pull` because they live in your profile, not the spine source.

### Bucket loop

- **Bucket loop:** off (default: off — set to `on` to enable `op-suggest`, `op-curate-nudge`, `op-add-skill`, `op-bucket-router`; the profile + spine always load every session, this toggle just controls whether the personal-library capture/curate/nudge layer runs in the background. Off is the audit-recommended default — many users want the spine + profile and nothing else; turn on later from the `/onboard --deep` H1 prompt or by hand-editing this line.)
- **Curate nudge pending threshold:** 5 (default: 5)
- **Curate nudge cooldown days:** 30 (default: 30)
- **Stale review never-fired age days:** 90 (default: 90)
- **Stale review last-fired age months:** 6 (default: 6)
- **Add-skill minimum fire count:** 3 (default: 3)

### Planning

- **Prep clarifying questions cap:** 7 (default: 5-7)
- **Prep section count target range:** 5-12 (default: 5-12)
- **Prep session entry split lines:** 100 (default: 100)

### Writeback (Stop hook)

- **Long-session turn threshold:** 30 (default: 30)
- **Long-session elapsed seconds:** 7200 (default: 7200)
- **Cross-session note cues:** (default — see `spine-writeback.sh` `CUES_RE`)
  - (one regex alternative per bullet — append your phrasing if Claude misses your idiolect; e.g. `note this for tomorrow`, `remember next week`)
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
