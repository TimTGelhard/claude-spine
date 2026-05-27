# Essential questions (6)

The minimum profile Claude needs to be useful. Ask one at a time via `AskUserQuestion`. Map answers into the matching section of `profile-template.md`. "Other" is automatically added by the tool — let the user free-text whenever the predefined options don't fit.

**Writing style for these questions:** plain language, no jargon. Assume the user has never written code before. When a term has to appear (a stack name, "deploy", "diff"), add a short plain-English gloss in parentheses. Options should describe a situation, not a label.

---

## Q1 — Claude subscription

Question: **"Which Claude subscription do you use? This helps me match my suggestions to what your plan can actually do (some plans have stricter usage limits or don't include the most expensive models)."**
Header: `Subscription`

Options (single-select):
- **Free** — no paid plan; using claude.ai with daily limits
- **Pro** — the $20/month plan; reasonable usage, mostly Sonnet
- **Max (5×)** — the ~$100/month plan; more usage, occasional Opus
- **Max (20×)** — the ~$200/month plan; heavy usage, Opus most of the time

(Other = free-text — e.g. "Team plan", "Enterprise", "API / pay-as-you-go".)

→ Profile: `Subscription → Plan`.

---

## Q2 — Experience level

Question: **"How much coding have you done so far?"**
Header: `Experience`

Options (single-select):
- **Just starting out** — learning the basics, or this is one of my first coding projects
- **Some experience** — I've built a few small things and can read code, but I still look a lot up
- **Comfortable** — I ship features regularly and know my way around a codebase
- **Very experienced** — I design systems, mentor others, or set the technical direction

→ Profile: `Developer profile → Experience level`.

---

## Q3 — Primary stack

Question: **"What kind of tools or languages do you use most? (If you're not sure, pick the closest — or use 'Other' to type it in plain words.)"**
Header: `Stack`

Options (single-select):
- **Websites and web apps** (JavaScript / TypeScript, React, Next.js)
- **Python** (scripts, data work, web backends like Django or FastAPI)
- **Go** (backend services or command-line tools)
- **Phone apps** (iOS with Swift, Android with Kotlin, or cross-platform with Expo / React Native)

(User may pick "Other" — they can just describe what they use, e.g. "I make WordPress sites" or "I haven't picked one yet".)

→ Profile: `Stack preferences → Primary`.

---

## Q4 — Push-back intensity

Question: **"When you ask me to do something and I think it's a bad idea, how should I respond?"**
Header: `Push-back`

Options (single-select):
- **Just do it** — go ahead with what I asked; only stop me if something is really going to break
- **Mention concerns, then continue** — tell me once what worries you, but do what I asked if I still want it
- **Argue your side** — really make the case for the better option; don't give in just because I push back
- **Teach me along the way** — point out things I could be doing better, even small ones, so I learn

→ Profile: `Working style → Push-back intensity`.

---

## Q5 — Verbosity

Question: **"How much do you want me to explain when I answer?"**
Header: `Verbosity`

Options (single-select):
- **Just the answer** — give me the code or the result, no extra talking
- **Short and clear** — a sentence or two of context, then the answer
- **Walk me through it** — explain what you're doing and why
- **Teach me** — explain the background concepts too, like I'm learning as we go

→ Profile: `Working style → Verbosity`.

---

## Q6 — Project context

Question: **"What kind of projects are you mostly working on right now?"**
Header: `Projects`

Options (single-select):
- **Personal projects / learning** — building things for myself, experimenting, getting better at coding
- **Small projects for real use** — side projects, MVPs (a first version to show people), or apps with a few users
- **Work for clients** — websites or tools I'm being paid to build for someone else
- **A real product with many users** — something live where downtime or bugs affect real people

→ Profile: `Project context → Typical work`.

---

## After Q6

1. **Save the essentials immediately** — write the profile file now, even if deep is coming next. Captures the first-run state.

2. **Propose settings.json tune (from Q1).** Run the "Subscription-based settings tuning" flow in `SKILL.md`: read `~/.claude/settings.json`, compute target values from the Q1 mapping table, and — if the target differs from the current values — show a one-line diff and ask for explicit approval. Apply on yes; skip on no. If Q1 was "Other" or settings.json doesn't exist, skip silently.

3. **Then ask about the deep interview:**

   Question: **"Want to answer about 11 more questions so I can tailor things further? You can also do this later."**
   Header: `Continue?`

   Options (single-select):
   - **Yes, keep going now**
   - **Not now — I'll run `/onboard --deep` later**
   - **No, I'm good with the basics**

   If "Yes, keep going now" → load `questions-deep.md`.
   If "Not now" or "No, I'm good with the basics" → leave deep sections in the profile as `(unfilled — run /onboard --deep to capture)`. Tell the user the essentials are saved, where to find the file, and whether settings.json was tuned or skipped.
