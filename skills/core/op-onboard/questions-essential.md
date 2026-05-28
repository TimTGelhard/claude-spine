# Essential questions (10)

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

Question: **"What kind of thing are you mostly building? (Pick the closest — these are broad buckets on purpose; 'Other' is fine if none fit, and you can name your exact stack in the free-text.)"**
Header: `Stack`

Options (single-select):
- **Web apps + sites** — anything that runs in a browser: full-stack apps, marketing sites, dashboards. Any language (JS/TS, Python, Ruby, PHP, Java, C#, Go, Elixir).
- **Mobile + desktop apps** — apps that ship to a device: iOS / Android / cross-platform / Electron / Tauri (Swift, Kotlin, Expo, React Native, Flutter, .NET MAUI).
- **Backend services, CLIs, systems** — APIs, microservices, command-line tools, daemons, low-level work (Go, Rust, Java, C/C++, .NET, Node, Elixir, JVM stacks).
- **Data, scripts, ML** — analysis, pipelines, notebooks, training jobs, automation (Python, R, Julia, SQL, shell).

(User may pick "Other" and type a free-text description — e.g. "WordPress sites", "Unity game dev", "embedded C on STM32", "Salesforce/Apex".)

→ Profile: `Stack preferences → Primary`. **Important:** capture the user's free-text in addition to the bucket — the bucket routes generic advice, but the language/framework named in free-text is what should appear in concrete examples.

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

## Q5a — Answer length

Question: **"How short should my answers be? (Just the length — how much I explain my reasoning is the next question.)"**
Header: `Length`

Options (single-select):
- **Terse** — minimum text needed to convey the answer. Code first, prose last.
- **Standard** — a sentence or two of context around the answer
- **Verbose** — full prose around the answer, no compression for its own sake

→ Profile: `Working style → Answer length`.

---

## Q5b — Reasoning depth

Question: **"How much should I explain *why* I'm doing what I'm doing — the reasoning, not the length?"**
Header: `Reasoning`

Options (single-select):
- **Just the answer** — skip the rationale; show the result and move on
- **Show the path** — name the choice I made and one or two trade-offs, then the answer
- **Teach me the why** — walk through the reasoning, the alternatives I considered, and the background concepts as we go

→ Profile: `Working style → Reasoning depth`.

(Q5a controls *length*; Q5b controls *depth of reasoning*. A user can ask for **Terse + Teach me the why** — short prose that still names the trade-offs — or **Verbose + Just the answer** — full prose around the result without back-explaining decisions.)

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

## Q7 — Operating system

Question: **"What computer are you running this on? This decides which file paths and shell commands I default to (most things work everywhere, but some hooks and install steps are OS-specific)."**
Header: `OS`

Options (single-select):
- **macOS** — Apple silicon or Intel Mac
- **Linux** — any distribution (Ubuntu, Fedora, Arch, etc.)
- **Windows (WSL)** — Windows with Linux running underneath (most spine users on Windows are here)
- **Windows (native)** — PowerShell or cmd directly, no WSL

(Other = free-text — e.g. "ChromeOS with crostini", "FreeBSD".)

→ Profile: `Environment → OS`.

---

## Q8 — Version control host

Question: **"Where do you push code? Drives which CLI I'll suggest (`gh`, `glab`, etc.) and which URL patterns I use when I reference issues, PRs, or releases."**
Header: `VCS host`

Options (single-select):
- **GitHub** — github.com or GitHub Enterprise (uses `gh` CLI)
- **GitLab** — gitlab.com or self-hosted GitLab (uses `glab` CLI)
- **Bitbucket** — bitbucket.org or self-hosted (uses `bb` / Atlassian CLI)
- **None / local-only** — no remote, no PR/MR review flow, or one of: SVN, Mercurial, Fossil, Perforce, Azure DevOps Repos, AWS CodeCommit

(Other = free-text — name a self-hosted Gitea / Forgejo / cgit / Phabricator / etc.)

→ Profile: `Environment → VCS host`. Affects: Bash allowlist suggestions, "PR" vs "MR" vs "merge request" wording, public-VCS-scanning chapters in 17c.

---

## Q9 — Project type (artifact shape)

Question: **"What kind of thing are you shipping at the end of the project — the artifact? (This is separate from the language/family you picked in Q3 — it routes templates, deploy patterns, and verify checks.)"**
Header: `Artifact`

Options (single-select):
- **An app users open** — web app, mobile app, desktop app, or anything with a UI a person interacts with
- **A backend service or CLI** — API server, daemon, scheduled job, command-line tool, ETL pipeline
- **A library or framework** — package others install (npm / pip / cargo / maven / nuget / homebrew tap), reusable module, SDK, plugin
- **Data, models, or analyses** — notebooks, ML training jobs, dashboards, one-off analyses, research outputs

(Other = free-text — e.g. "embedded firmware for STM32", "Unity game", "Salesforce/Apex package", "WordPress theme", "infrastructure module".)

→ Profile: `Project context → Artifact`. Drives: which `templates/` variant the spine points you at (`web-saas-next-supabase` for app-shape; library + CLI + data variants are paths-not-yet-shipped — Claude falls back to the agnostic skeleton until they land), which deploy runbook makes sense, which smoke-test shape is right.

---

## After all 10 essentials (the last one is Q9)

1. **Save the essentials immediately** — write the profile file now, even if deep is coming next. Captures the first-run state.

2. **Propose settings.json tune (from Q1).** Run the "Subscription-based settings tuning" flow in `SKILL.md`: read `~/.claude/settings.json`, compute target values from the Q1 mapping table, and — if the target differs from the current values — show a one-line diff and ask for explicit approval. Apply on yes; skip on no. If Q1 was "Other" or settings.json doesn't exist, skip silently.

3. **Then ask about the deep interview:**

   Question: **"Want to answer 18 more questions so I can tailor things further? Plus two optional opt-ins at the end for auto-typecheck and auto-format hooks. You can also do this later."**
   Header: `Continue?`

   Options (single-select):
   - **Yes, keep going now**
   - **Not now — I'll run `/onboard --deep` later**
   - **No, I'm good with the basics**

   If "Yes, keep going now" → load `questions-deep.md`. After the deep questions are saved, also run the **Hook tuning** pass defined in `SKILL.md` (G1 + G2 opt-in prompts for `~/.claude/settings.json` hooks).
   If "Not now" or "No, I'm good with the basics" → leave deep sections in the profile as `(unfilled — run /onboard --deep to capture)`. Tell the user the essentials are saved, where to find the file, and whether settings.json was tuned or skipped.
