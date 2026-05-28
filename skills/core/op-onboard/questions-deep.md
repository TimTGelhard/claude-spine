# Deep questions (18, grouped by section)

Ask in order. Use `AskUserQuestion` for each. Skip a question if the essentials already implied the answer (e.g., don't re-ask experience level). Each question has up to 4 explicit options; "Other" is added by the tool for free-text. Where the question says `multi-select`, set `multiSelect: true`.

**Writing style for these questions:** plain language, no jargon. Assume the user might be brand new. If a technical term has to appear, gloss it in plain English in parentheses. Options should describe a situation, not just a label.

---

## Section 0 — Subscription

### 0A — How heavily you use Claude in a typical day

Question: **"On a busy day, how much do you use Claude? (This helps me decide when to suggest cheaper / lighter approaches vs heavier ones — like running Opus, Claude's most capable but slowest and most expensive model, or kicking off a multi-agent review, where several Claude sessions check the same code in parallel.)"**
Header: `Daily use`
Options (single-select):
- **Lightly** — a few questions a day; I bump into limits rarely or never
- **Moderately** — back-and-forth for an hour or two; sometimes I notice slower / restricted modes
- **Heavily** — many hours; I've hit usage limits before
- **All day** — Claude is on basically the whole workday; I budget for the top plan

→ Profile: `Subscription → Daily usage`.

### 0B — Cost sensitivity

Question: **"How careful do you want me to be about steering you toward cheaper options? (Cheaper options = using a smaller / faster AI model when the work doesn't need the deepest reasoning, or skipping an expensive multi-agent review when one careful pass is enough.)"**
Header: `Cost`
Options (single-select):
- **Very careful** — always pick the cheapest thing that works; flag when something will burn a lot
- **Balanced** — go with the right tool for the job, but mention if I'm about to do something expensive
- **Don't worry about it** — I'm on a plan that covers it; just pick the best option

→ Profile: `Subscription → Cost sensitivity`.

---

## Section A — Developer profile

### A1 — Years coding

Question: **"Roughly how long have you been coding? (Counting hobby and learning time too, not just paid work.)"**
Header: `Years`
Options (single-select):
- Less than 2 years
- 2 to 6 years
- 6 to 12 years
- More than 12 years

→ Profile: `Developer profile → Years coding`.

### A2 — Comfort areas (multi-select)

Question: **"Which parts of building software do you feel most comfortable with? (Pick any that apply.)"**
Header: `Comfort`
Options (`multiSelect: true`):
- **Backend** — the server side; APIs (how apps talk to each other) and databases (where data is stored)
- **Frontend** — what users see on the screen; buttons, layouts, design
- **Infrastructure** — servers, deployment (getting code online), and automation
- **Data / scripts** — analyzing data, working with spreadsheets/CSVs, machine learning, or small helper scripts

→ Profile: `Developer profile → Comfort areas`.

### A3 — Lean-in areas (multi-select)

Question: **"Which areas would you like me to push you on a bit more — things you're newer to or actively trying to learn? (Pick any that apply.)"**
Header: `Lean-in`
Options (`multiSelect: true`): same four as A2.

→ Profile: `Developer profile → Lean-in areas`.

---

## Section B — Stack

### B1 — Secondary stack

Question: **"Is there a second area of work you sometimes do, besides your main one?"**
Header: `Secondary`
Options (single-select):
- **Web apps + sites** (JS/TS, Python, Ruby, PHP, Java, C#, Go, Elixir for web)
- **Mobile + desktop apps** (Swift, Kotlin, Expo, React Native, Flutter, Electron, Tauri)
- **Backend services, CLIs, systems** (Go, Rust, Java, C/C++, .NET, Node, JVM)
- **Data, scripts, ML** (Python, R, Julia, SQL, shell)

(Other = free-text, e.g. "PHP for an old site", "SQL only", "Unity game dev", "embedded firmware". Same shape as Q3, so the user can name "No, I stick to my main one" via Other.)

→ Profile: `Stack preferences → Secondary` — capture free-text alongside the bucket.

### B2 — Stacks to avoid (free-text only)

Question: **"Anything you'd rather I *not* suggest — tools, languages, frameworks, patterns? Free-text. Skip if you don't have a preference."**
Header: `Avoid`

This question takes **no pre-loaded options**. Present it with `multiSelect: false` and a single option:
- **No, no strong preference** — skip the avoid field

Anything else the user wants flagged goes through the `Other` free-text. Reason: pre-loading a list of "stacks to avoid" frames whichever ecosystems we pre-list as the canonical things to flag away from, and the user's specific dislikes are too varied to enumerate. Free-text captures the actual signal (e.g., "no jQuery", "no microservices for MVPs", "don't suggest MongoDB", "skip Tailwind I prefer vanilla CSS").

→ Profile: `Stack preferences → Avoid` — write the free-text verbatim, or omit the field if the user picked the no-preference option.

---

## Section C — Project context

### C1 — Team size

Question: **"How many people usually work on a project with you?"**
Header: `Team`
Options (single-select):
- **Just me** (solo)
- **A small team** (2 to 5 people)
- **A medium team** (6 to 20 people)
- **A large team or whole company** (more than 20)

→ Profile: `Project context → Team size`.

### C2 — User scale

Question: **"How many real people actually use the things you build?"**
Header: `Users`
Options (single-select):
- **No users yet** — it's not launched, or only I use it
- **A handful** — early testers, friends, or a small closed group
- **Hundreds to a few thousand** — it's live and growing
- **More than 10,000** — a lot of people depend on it working

→ Profile: `Project context → User scale`.

---

## Section D — Signal preferences

### D1 — Active signals (multi-select)

Question: **"When should I stop what I'm doing and warn you about something, even if you didn't ask? (Pick any that apply.)"**
Header: `Signals`
Options (`multiSelect: true`):
- **When my memory is getting full** — long sessions make me less reliable; warn before quality drops
- **When you're asking for more than the original task** — flag if we're going beyond what we set out to do (scope creep)
- **When I'm repeating something we already ruled out** — catch me going in circles
- **When I'm about to say 'done' without actually checking** — make sure I verify the change works

(Default if user picks nothing: all four.)

→ Profile: `Working style → Active signals`.

---

## Section E — Output format

### E1 — Code presentation

Question: **"When I change code, how do you want me to show it?"**
Header: `Code style`
Options (single-select):
- **Just the changed parts** (a "diff" — the lines that are added or removed)
- **The whole file** — easier to copy and paste into your editor
- **Whichever fits best** — let me pick based on how big the change is

→ Profile: `Output format → Code presentation`.

### E2 — Comments + emojis

Question: **"How do you want me to comment code and use emojis in chat?"**
Header: `Comments`
Options (single-select):
- **Few comments, no emojis anywhere**
- **Few comments in code, emojis fine in chat**
- **Lots of comments explaining the code, no emojis**
- **Lots of comments, emojis fine in chat**

→ Profile: `Output format → Comments / emojis`.

---

## Section F — Risk + safety

### F1 — Command execution tolerance

Question: **"How cautious should I be before running commands on your computer? (Commands are things like installing packages, deleting files, or deploying code.)"**
Header: `Commands`
Options (single-select):
- **Ask before doing anything that changes files or installs things** (safest — good if you're newer or working on important stuff)
- **Reading things is fine; ask before changes, installs, or deploying**
- **Just run things — I'll catch problems when I review them**

→ Profile: `Risk + safety → Command tolerance`.

---

## Section G — Session shape + workspace

### G1 — Typical session shape

Question: **"What does most of your time with me actually look like? Pick the most common — the discipline applies to all, but the defaults adapt."**
Header: `Session shape`
Options (single-select):
- **Building new features** — most sessions are 'here's the next thing on the plan, let's ship it' (the `/prep → build → /done` flow is sized for this)
- **Debugging + brownfield work** — diagnosing problems in existing code more often than building new
- **Refactoring + reading** — understanding and reshaping an existing codebase; less feature work
- **Exploring + prototyping + research** — short throwaway experiments, notebook-style; the plan ladder is heavy

→ Profile: `Working style → Session shape`. Affects: how heavily `/prep` gates the build flow, whether ambient cold-start expects a plan file.

### G2 — Plan files location

Question: **"Where do you want me to put planning files (master plan, section plans, PROGRESS) when `/prep` runs?"**
Header: `Plans dir`
Options (single-select):
- **`docs/plans/` + `docs/PROGRESS.md`** — the spine's canonical default (works for most projects)
- **`plans/` + `PROGRESS.md` at repo root** — if your project doesn't already use `docs/`
- **`.claude/plans/` + `.claude/PROGRESS.md`** — tucked under the AI-config dir
- **I'll set this per project** in each project's `CLAUDE.md` (line: `Plan layout: <plans-dir> <progress-file>`)

→ Profile: `Environment → Plans dir`. Affects: ambient `op-spine-active` cold-start, `/prep` scaffold paths, `spine-writeback.sh` heartbeat target.

---

## Section H — Bucket loop + team context + region

### H1 — Bucket loop opt-in

Question: **"Want the bucket loop active? While we work, I can quietly capture high-signal moments (`op-suggest`) so a periodic `/curate` builds your personal skill + chapter library. Default is off — the spine + your profile always load; this just controls whether the personal-library capture/curate/nudge layer also runs in the background."**
Header: `Bucket loop`
Options (single-select):
- **Off (default)** — skip the capture/curate/nudge loop entirely (you can still hand-add bucket skills with `/add-skill`)
- **On** — capture high-signal moments and nudge me to curate when >5 are pending

→ Profile: `Spine defaults → Bucket loop:` (writes `on` or `off`; default if unset is `off` — the audit-recommended default after the round-6 flip). Affects: whether `op-suggest`, `op-curate-nudge`, `op-bucket-router` auto-fire.

### H2 — Team / organization shape

Question: **"What's the work context this profile mostly serves? (Tone, signaling, and chapter framing adapt to whether you're solo on a side project vs. coordinating with reviewers vs. shipping into an enterprise CI/CD.)"**
Header: `Org`
Options (single-select):
- **Solo developer** — side projects, MVPs, contractor work where the only reviewer is me
- **Small team or co-founder pair** — 2–5 people; code-review-by-PR exists; release cadence is informal
- **Mid-size or large org** — 6+ people; multi-environment deploys; formal review; possibly compliance constraints
- **OSS / academic / freelance / agency** — work shared with external contributors or rotating clients; documentation matters more than velocity

→ Profile: `Project context → Org shape`. Affects: how often Claude flags "PR description?" / "did anyone else review?" / "should this go in a CHANGELOG?".

### H3 — Region / currency hint

Question: **"For any cost or pricing examples I give (subscription tiers, deploy provider costs, etc.), which currency feels most natural?"**
Header: `Currency`
Options (single-select):
- **USD** — most Anthropic + Vercel + AWS pricing pages
- **EUR** — Europe-billed services; localized pricing
- **GBP** — UK-billed services
- **JPY / other** — pick "Other" and free-text the ISO 4217 code (e.g. CHF, INR, BRL, AUD)

→ Profile: `Environment → Currency`. Affects: which symbol Claude uses in cost framings; optional context only.

---

## After H3

Update the profile file (rewrite with all deep answers + bump `Last updated:`).

Then offer one free-text follow-up:

Question: **"Anything else you want me to remember about how you like to work? (Totally optional.)"**
Header: `Notes`
Options (single-select):
- No, that's everything
- Yes — I'll add a note (the user types it into the "Other" box)

If the user adds anything, append a `## Notes` section to the profile with their text verbatim. Otherwise omit the section.

## Then — Hook tuning (writes to settings.json, not the profile)

Once the profile is rewritten, run the **Hook tuning** pass defined in
`SKILL.md` (`## Hook tuning (deep mode only)`). It asks two more opt-in
questions — auto-typecheck after edits and auto-format after edits — and
writes the matching hooks to `~/.claude/settings.json` on approval. Those
questions live alongside the writeback logic in SKILL.md, not here, because
the answers affect settings.json rather than the personal profile.

Finish by emitting the handoff message (SKILL.md `## After writing the profile — the handoff`).
