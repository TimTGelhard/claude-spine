# Essential questions (5)

The minimum profile Claude needs to be useful. Ask one at a time via `AskUserQuestion`. Map answers into the matching section of `profile-template.md`. "Other" is automatically added by the tool — let the user free-text whenever the predefined options don't fit.

---

## Q1 — Experience level

Question: **"How would you describe your software experience?"**
Header: `Experience`

Options (single-select):
- **Beginner** — actively learning to code; first 1–2 years
- **Intermediate** — comfortable shipping features; 2–6 years
- **Senior** — make architectural calls, mentor others; 6+ years
- **Staff+ / principal** — set technical direction across teams; 10+ years

→ Profile: `Developer profile → Experience level`.

---

## Q2 — Primary stack

Question: **"What's the stack you ship in most often?"**
Header: `Stack`

Options (single-select):
- **TypeScript + React / Next.js**
- **Python** (Django / FastAPI / data / ML)
- **Go** (services, CLIs)
- **Native mobile** (Swift / Kotlin / Expo)

(User may pick "Other" for Rails / Rust / Java / Elixir / etc.)

→ Profile: `Stack preferences → Primary`.

---

## Q3 — Push-back intensity

Question: **"How hard should I push back when I think you're wrong?"**
Header: `Push-back`

Options (single-select):
- **Passive** — do what I say, raise issues only if critical
- **Balanced** — flag concerns once, then proceed if you insist
- **Spar with me** — argue your case, surface alternatives, don't fold easily
- **Mentor mode** — challenge me even on small decisions; teach as we go

→ Profile: `Working style → Push-back intensity`.

---

## Q4 — Verbosity

Question: **"How much explanation do you want in my responses?"**
Header: `Verbosity`

Options (single-select):
- **Terse** — code + one line; no preamble, no summary
- **Balanced** — short prose, key context, no padding
- **Explained** — walk through reasoning, name the trade-offs
- **Tutorial** — explain background concepts as we go

→ Profile: `Working style → Verbosity`.

---

## Q5 — Project context

Question: **"What are you mostly building right now?"**
Header: `Projects`

Options (single-select):
- **MVPs / side projects** — speed > polish, real users but small scale
- **Client work** — websites or apps for paying clients
- **Production app at scale** — users in the thousands+, downtime matters
- **Research / exploration** — code is the artifact of figuring something out

→ Profile: `Project context → Typical work`.

---

## After Q5

Save the essentials immediately (write the profile file now, even if deep is coming next — captures the first-run state).

Then ask:

Question: **"Want to keep going into the deep interview? About 10 more questions covering stack details, output format, signal sensitivity, and risk tolerance."**
Header: `Continue?`

Options (single-select):
- **Yes, continue now**
- **Later — I'll run `/onboard --deep`**
- **No, skip permanently**

If "Yes, continue now" → load `questions-deep.md`.
If "Later" or "No, skip permanently" → leave deep sections in the profile as `(unfilled — run /onboard --deep to capture)`. Tell the user the essentials are saved and where to find the file.
