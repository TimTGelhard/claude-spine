# Deep questions (~10, grouped by section)

Ask in order. Use `AskUserQuestion` for each. Skip a question if the essentials already implied the answer (e.g., don't re-ask experience level). Each question has up to 4 explicit options; "Other" is added by the tool for free-text. Where the question says `multi-select`, set `multiSelect: true`.

---

## Section A — Developer profile

### A1 — Years coding professionally

Question: **"Roughly how many years have you been coding professionally?"**
Header: `Years`
Options (single-select):
- 0–2 years
- 2–6 years
- 6–12 years
- 12+ years

→ Profile: `Developer profile → Years coding`.

### A2 — Comfort areas (multi-select)

Question: **"Which areas do you feel most comfortable in?"**
Header: `Comfort`
Options (`multiSelect: true`):
- Backend services / APIs / databases
- Frontend / UI / design systems
- DevOps / infra / CI/CD
- Data / ML / scripting

→ Profile: `Developer profile → Comfort areas`.

### A3 — Lean-in areas (multi-select)

Question: **"Where do you want me to lean in harder — the areas you're weaker in or actively learning?"**
Header: `Lean-in`
Options (`multiSelect: true`): same four as A2.

→ Profile: `Developer profile → Lean-in areas`.

---

## Section B — Stack

### B1 — Secondary stack

Question: **"What's the second stack you reach for, if any?"**
Header: `Secondary`
Options (single-select):
- TypeScript + React / Next.js
- Python
- Go
- None — I stick to my primary

(Other = free-text for Rails, Rust, etc.)

→ Profile: `Stack preferences → Secondary`.

### B2 — Stacks to avoid (multi-select)

Question: **"Any stacks I should *avoid* suggesting?"**
Header: `Avoid`
Options (`multiSelect: true`):
- PHP / Laravel
- Java / Spring
- Ruby on Rails
- C# / .NET

(Other = free-text.)

→ Profile: `Stack preferences → Avoid`.

---

## Section C — Project context

### C1 — Team size

Question: **"How many people typically work on a project you own?"**
Header: `Team`
Options (single-select):
- Solo
- 2–5 (small team)
- 6–20 (mid team)
- 20+ (large team / company-scale)

→ Profile: `Project context → Team size`.

### C2 — User scale

Question: **"How many real users does your typical project serve?"**
Header: `Users`
Options (single-select):
- None yet (pre-launch)
- Handful (early users / closed beta)
- 100s–1000s (live, growing)
- 10K+ (scale matters)

→ Profile: `Project context → User scale`.

---

## Section D — Signal preferences

### D1 — Active signals (multi-select)

Question: **"When should I interrupt my work to flag a problem unprompted?"**
Header: `Signals`
Options (`multiSelect: true`):
- Context filling — warn before quality degrades
- Scope creep — flag when I'm beyond the original ask
- Drift — re-suggesting something we ruled out
- Verification gaps — about to claim "done" without verifying

(Default if user picks nothing: all four.)

→ Profile: `Working style → Active signals`.

---

## Section E — Output format

### E1 — Code presentation

Question: **"Do you prefer diffs / snippets, or full file rewrites?"**
Header: `Code style`
Options (single-select):
- **Diffs and snippets** — show me the change
- **Full files** — easier to copy-paste
- **Mix** — let Claude pick based on change size

→ Profile: `Output format → Code presentation`.

### E2 — Comments + emojis

Question: **"How should I comment code and use emojis?"**
Header: `Comments`
Options (single-select):
- Minimal comments, no emojis in code or chat
- Minimal comments, emojis OK in chat
- Document everything, no emojis
- Document everything, emojis OK in chat

→ Profile: `Output format → Comments / emojis`.

---

## Section F — Risk + safety

### F1 — Command execution tolerance

Question: **"How careful should I be before running shell commands?"**
Header: `Commands`
Options (single-select):
- **Ask before running anything that writes** (recommended for production work)
- **Read-only runs anytime; ask before writes / deploys**
- **Run freely; you'll catch issues in review**

→ Profile: `Risk + safety → Command tolerance`.

---

## After F1

Update the profile file (rewrite with all deep answers + bump `Last updated:`).

Then offer one free-text follow-up:

Question: **"Anything else you want me to capture that the structured questions missed?"**
Header: `Notes`
Options (single-select):
- No, that's it
- Yes — I'll add a note (user types in the "Other" box)

If the user adds anything, append a `## Notes` section to the profile with their text verbatim. Otherwise omit the section.

Finish by telling the user: file path, that Claude reads it every session, and that they can hand-edit anytime.
