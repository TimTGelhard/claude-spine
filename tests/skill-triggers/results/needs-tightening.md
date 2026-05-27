# Skills needing description tightening

_Threshold: FP rate > 20% or TP rate < 80%. Tightening is out of scope for L4a — see launch.md._

## `op-anti-patterns`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "I'll wrap this in a generic 'fetcher' helper so future code can reuse the pattern across the project, even though only this one route nee..."
- _expected fire_, fired 0/1: "the migration's been bothering me — let me just `try { applyMigration() } catch (e) {}` and we'll come back to it after the demo"
- _expected fire_, fired 0/1: "shipping the UI now — works on my machine, walked the happy path. We'll catch the empty-state and slow-network edge cases in QA next week"
- _expected fire_, fired 0/1: "let's add nodemailer and a queue library for the email path. We'll need them for the password reset later"
- _expected fire_, fired 0/1: "ok so I was thinking, while we're in this file fixing the auth bug, let me also add a Redis cache layer for sessions — we'll need it late..."

## `op-collaboration-modes`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "we've been in planning for an hour, let's switch — build the user-settings page now, full executor mode"
- _expected fire_, fired 0/1: "you've been in 'just build it' mode, but I think we need to step back and review what's been written before continuing — flip the switch"
- _expected fire_, fired 0/1: "before we touch this Redis logic, just explain to me what it's doing — I haven't read it in 4 months"
- _expected fire_, fired 0/1: "I want you to review the auth refactor PR independently — don't agree with my reasoning, find what I missed"
- _expected fire_, fired 0/1: "give me 2 or 3 ways we could design the team-invite flow with tradeoffs — I don't want you to just build the first thing"

## `op-curate`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "/curate"
- _expected fire_, fired 0/1: "/curate --review-stale"
- _expected fire_, fired 0/1: "let's go through the pending suggestions in my bucket and decide which to apply"
- _expected fire_, fired 0/1: "process the queue of bucket suggestions — I want to review them one by one before anything writes"
- _expected fire_, fired 0/1: "let's curate — what's been captured since last week's session that's worth turning into actual bucket entries"

## `op-foundations`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "explain how Claude Code's tool loop actually works under the hood — what's the LLM doing between my prompt and the file edit?"
- _expected fire_, fired 0/1: "I keep hearing about Claude having a 'context window' — what does that actually mean in practice, and why does my session feel worse arou..."
- _expected fire_, fired 0/1: "I'm on Pro plan and burning through budget fast — what are the controls I have, and when does plan mode or fast mode pay for itself?"
- _expected fire_, fired 0/1: "what can Claude actually NOT do that I might assume it can? I want to know the failure modes before I ship something that depends on it."
- _expected fire_, fired 0/1: "should I use Opus or Sonnet for refactoring a 12-file auth module — what's the actual tradeoff in terms of cost vs quality for this kind ..."

## `op-persistence`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "I want Claude to always run prettier on saved TS files in this project. Should that go in CLAUDE.md, a hook, or a skill?"
- _expected fire_, fired 0/1: "audit my personal skill library — I haven't looked at it in 6 months. Some of these triggers can't be doing anything useful anymore."
- _expected fire_, fired 0/1: "I'm writing a custom skill for 'audit Supabase RLS from two sessions' — help me draft the trigger description so it actually fires when I..."
- _expected fire_, fired 0/1: "I keep telling Claude 'never commit a .env file' in every session — where should that rule actually live so it sticks across all my proje..."
- _expected fire_, fired 0/1: "the project CLAUDE.md has grown to 400 lines — most of it is stale and contradicts itself. How do I clean it up without losing the load-b..."

## `op-prompting`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "I keep getting bad output from this 'rewrite my landing page hero' prompt — Claude takes it in a generic direction. Help me restructure t..."
- _expected fire_, fired 0/1: "this is a non-trivial task — adding multi-tenant teams to my B2B SaaS. Help me structure the prompt with CONTEXT / TASK / CONSTRAINTS / E..."
- _expected fire_, fired 0/1: "first attempt gave me boilerplate React. Iterate on the prompt — what did I leave out that would have pushed it toward production-quality?"
- _expected fire_, fired 0/1: "which high-leverage prompt pattern fits this — I'm about to ask Claude what's broken in a flaky end-to-end test that fails 1 in 10 times"
- _expected fire_, fired 0/1: "what's the right way to phrase 'I want you to audit my migration safety' so I get a real review and not just a checklist?"

## `op-recovery`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "you said the opposite earlier in this session — go back, the auth helper IS supposed to throw on null, not return null. Are you sure?"
- _expected fire_, fired 0/1: "the deploy to prod broke — homepage is 500ing, and the migration we ran 20 minutes ago might be the cause. What do we do right now?"
- _expected fire_, fired 0/1: "we're going in circles on this Stripe webhook — every fix introduces a new bug. Step back and tell me what's actually happening here."
- _expected fire_, fired 0/1: "I don't recognize this code anymore — when did we add the 'queue' folder and what's in it? I think you might have hallucinated a path"
- _expected fire_, fired 0/1: "I just realized our service_role key was in NEXT_PUBLIC_SUPABASE_KEY in the .env for two days. It's on Vercel. What's the recovery proced..."

## `op-signaling`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "calibrate how often you interrupt me with proactive signals — I feel like you're flagging too aggressively in code reviews and not aggres..."
- _expected fire_, fired 0/1: "why didn't you flag earlier that I was burning context on those big file reads? You should have signaled before we hit hour 2"
- _expected fire_, fired 0/1: "I want to add a custom subagent for code review and an MCP for Linear and a hook that runs after every commit — and another skill for cap..."
- _expected fire_, fired 0/1: "we started this session to fix one auth bug and now we've also rewritten the routing layer and added a feature flag system — is that fine..."
- _expected fire_, fired 0/1: "before you do anything else: I'm proposing we extend the spine itself by adding a 19th chapter on prompt engineering. Walk through this w..."

## `op-subagents`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "I want to write a custom subagent in ~/.claude/agents/ for 'review my migration for safety' — walk me through the SKILL-like file"
- _expected fire_, fired 0/1: "I'm thinking 'orchestrator + specialists' for the codebase rewrite — one agent plans, several execute. Does that pattern fit here or am I..."
- _expected fire_, fired 0/1: "spawn three parallel agents to refactor the auth helper, write the test suite, and update the README in one go"
- _expected fire_, fired 0/1: "is this a job for the Explore agent or the general-purpose one — I'm looking for every file in the repo that imports 'supabase-js'"
- _expected fire_, fired 0/1: "I need to audit 40 route handlers for missing zod validation — should I just grep, or is this where a subagent earns its keep?"

## `op-suggest`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "/suggest"
- _expected fire_, fired 0/1: "we should add 'never run a migration on Friday afternoon without a rollback plan' to the manual — remember this"
- _expected fire_, fired 0/1: "this 'always check both light and dark mode before saying UI is done' came up three times today. Let's not forget it."
- _expected fire_, fired 0/1: "ok end-of-session reflection — what did we actually learn from the Stripe webhook debugging today, anything worth capturing for next time?"
- _expected fire_, fired 0/1: "next time we hit this Supabase RLS recursive policy bug, let's not spend an hour on it — capture the pattern somewhere I'll see it"

## `op-tools`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "should this be a Bash call or one of the dedicated tools? I want to count lines in 5 files and write the result to a report"
- _expected fire_, fired 0/1: "should I use the Edit tool or the Write tool to update this 60-line file — only changing 4 lines but they're not contiguous?"
- _expected fire_, fired 0/1: "this `npm run build` is going to take 8 minutes — should I background it with run_in_background, or is there a smarter pattern?"
- _expected fire_, fired 0/1: "I want to search the whole codebase for every place that calls 'createServerClient' — is grep the right move or should I spawn an Explore..."
- _expected fire_, fired 0/1: "I've got 11 MCPs loaded and my context bar is full before I even start — which ones are pulling their weight and which should I unload?"

## `op-workflow`

- TP rate: 0% (0/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "I'm about to start a new MVP — an invoicing tool for Dutch freelancers, ~3 weeks budget. What's the prep → architecture → build → harden ..."
- _expected fire_, fired 0/1: "this 'add Stripe Billing portal' task feels too big for one session — how do I cut it into the right slices without making 6 PRs?"
- _expected fire_, fired 0/1: "before I open Claude Code, walk me through scoping this feature: multi-tenant team invites with role-based permissions. Is this one sessi..."
- _expected fire_, fired 0/1: "I've got the schema and 3 API routes done. Where am I in the 7-stage workflow — should I be hardening already or still in build?"
- _expected fire_, fired 0/1: "I want to add SSO + multi-region replication + a redesigned dashboard. Is that one feature or three?"

## `op-bucket-router`

- TP rate: 20% (1/5)
- FP rate: 20% (1/5)

**Failures:**
- _expected fire_, fired 0/1: "I think I have a personal note somewhere on how I handle Solvero client handoffs — load it if you find it"
- _expected fire_, fired 0/1: "before we write this Vercel deploy script, check my bucket for an existing recipe"
- _expected fire_, fired 0/1: "use my 'lighthouse-90-checklist' skill on this page"
- _expected fire_, fired 0/1: "do this the way I usually do it — like the pattern we agreed on for Dutch postcode validation in the contact form a while back"
- _expected no-fire_, fired 1/1: "run /curate on my pending suggestions"

## `op-add-skill`

- TP rate: 20% (1/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "/add-skill"
- _expected fire_, fired 0/1: "actually that audit output was great. Let's make this a skill — 'audit Supabase RLS policies from two sessions, owner + non-owner, report..."
- _expected fire_, fired 0/1: "this whole conversion-from-postgres-types-to-zod-schemas thing — third time we've done it this month. Save it as a skill"
- _expected fire_, fired 0/1: "ok I just realized I keep redoing this exact 'find the latest supabase migration version, bump it by one, write the new file' dance every..."

## `op-brownfield`

- TP rate: 20% (1/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "old Rails app, version 4.2, nobody's touched it in 3 years. Client wants a Stripe integration added. I literally couldn't tell you what `..."
- _expected fire_, fired 0/1: "I'm picking up the MVP I shipped 7 months ago. I genuinely don't remember why I built the queue worker the way I did. Walk me back into i..."
- _expected fire_, fired 0/1: "this auth module — I built it but it's been 5 months and I'm scared to change it. Before I add SSO, walk me through reverse-engineering w..."
- _expected fire_, fired 0/1: "inheriting a Solidity contract from another dev. I can't read it cold — what's the right way to teach Claude this codebase before I ask i..."

## `op-hooks`

- TP rate: 20% (1/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "from now on, when I'm about to commit, block the commit if any test fails. Set that up."
- _expected fire_, fired 0/1: "I want Claude to auto-run `npm run typecheck` after every file edit in this Next.js repo — wire it up in settings.json"
- _expected fire_, fired 0/1: "I added a PostToolUse hook to my settings.json but it's not firing — help me debug why"
- _expected fire_, fired 0/1: "should this 'always run prettier on saved files' rule be a hook, a CLAUDE.md instruction, or a skill? What's the right home?"

## `op-onboard`

- TP rate: 20% (1/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "/onboard"
- _expected fire_, fired 0/1: "/onboard --deep"
- _expected fire_, fired 0/1: "redo onboarding for me — I want to refresh the essentials interview, not the deep one"
- _expected fire_, fired 0/1: "update my profile — I'm doing more client work now and less personal MVPs, that should change how you collaborate with me"

## `op-visuals`

- TP rate: 20% (1/5)
- FP rate: 0% (0/5)

**Failures:**
- _expected fire_, fired 0/1: "the architecture doc needs a diagram of how auth flows from client → middleware → Supabase. Mermaid or ASCII?"
- _expected fire_, fired 0/1: "let me share this Figma design as a screenshot — Claude, build the navbar to match it pixel-by-pixel"
- _expected fire_, fired 0/1: "I need to compare iOS vs Android rendering of this transaction list — both look 'right' but feel wrong on Android. How do I share that wi..."
- _expected fire_, fired 0/1: "before we build the dashboard, I want to sketch out the layout — give me an ASCII mockup of the three-column variant vs the sidebar-and-c..."

