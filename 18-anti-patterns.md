> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/anti-patterns/`](chapters/anti-patterns/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 18 — Anti-patterns: the explicit "never do this" reference

A scannable catalog. When in doubt, check here first. Each entry: the anti-pattern, why it fails, what to do instead.

## Prompting anti-patterns

### "Just figure it out"
**Fails because:** Claude picks a plausible default. You discover it's wrong after the code is written.
**Instead:** state the goal, the constraints, and what "done" looks like. Even one line each.

### Bundling multiple unrelated asks in one prompt
**Fails because:** Claude prioritizes the first or last ask; the middle one gets neglected.
**Instead:** one ask per prompt. Multiple prompts in a session is fine; one prompt with three goals is not.

### "Make it better"
**Fails because:** "better" is undefined. You'll iterate 5 times.
**Instead:** specify what "better" means — tighter spacing, faster query, clearer name, etc.

### Pasting whole files when you could reference paths
**Fails because:** wastes tokens; Claude can `Read` precisely the lines it needs.
**Instead:** "look at `app/quotes/page.tsx`" — Claude reads on demand.

### Restating context Claude already has
**Fails because:** tokens spent rewriting `CLAUDE.md` content waste budget.
**Instead:** trust that CLAUDE.md + ARCHITECTURE.md is loaded. State only the *new* context for this turn.

### Apologizing for being unclear
**Fails because:** padding, not content.
**Instead:** just be clear. Skip the meta-commentary.

### Asking Claude to summarize what it just did
**Fails because:** the diff already shows it. Wastes tokens.
**Instead:** read the diff. (Already in your global CLAUDE.md.)

## Session / scope anti-patterns

### "I'll do auth + a feature using auth in one session"
**Fails because:** you can't tell if a bug is in auth or the feature.
**Instead:** auth first, verify, commit. Feature after.

### Building + writing docs / tests for unrelated code in same session
**Fails because:** divided attention, both halves worse.
**Instead:** one focus per session.

### Bundling a bug fix with a refactor
**Fails because:** if it breaks, you don't know which half caused it.
**Instead:** fix the bug, commit. Refactor in a separate session, commit. (Your global CLAUDE.md: "One bug per change.")

### Trying to do the whole app in one session
**Fails because:** context fills, decisions multiply, drift sets in.
**Instead:** one session = one feature. See [06-feature-sizing.md](06-feature-sizing.md).

### Carrying a long session forward "because I'm in flow"
**Fails because:** flow ≠ quality. Long sessions degrade silently.
**Instead:** commit at natural breakpoints. Fresh terminal after.

### Skipping the orientation prompt to "save time"
**Fails because:** every bad assumption from missing context costs more time than the orientation would.
**Instead:** 5K-30K tokens of orientation, every session.

## Context management anti-patterns

### Dumping the whole codebase to "give Claude full context"
**Fails because:** attention dilution. Claude focuses worse on the relevant 5%.
**Instead:** load the slice for the current task. Trust Claude to read more on demand.

### `cat` via Bash to read files
**Fails because:** plain text dump, no syntax handling, no IDE integration.
**Instead:** `Read` tool.

### Running verbose commands without filtering
**Fails because:** `npm install` output (1000+ lines) lands in context for the session.
**Instead:** pipe to `tail -50`, or filter to errors only.

### Ignoring auto-compaction
**Fails because:** post-compaction, Claude "remembers" decisions imprecisely. Subtle bugs.
**Instead:** treat compaction as a soft restart. Re-state critical constraints.

### Storing project state in conversation
**Fails because:** dies at session end. Next session starts blind.
**Instead:** files (PROGRESS.md, DECISIONS.md, FEATURES.md). Update at session end.

## Tool selection anti-patterns

### Using subagents for trivial work
**Fails because:** overhead > benefit. Slower than just doing it.
**Instead:** subagents for parallel, broad-search, or audit work.

### Using subagents when the *thinking* matters
**Fails because:** you get the conclusion but not the reasoning. Can't course-correct.
**Instead:** do it in main thread when you'll iterate.

### Using `Write` for small edits
**Fails because:** sends whole file content, harder to review the diff.
**Instead:** `Edit` for targeted changes.

### Polling with `sleep` instead of `Monitor`
**Fails because:** wastes tokens on cycles, blocks the conversation.
**Instead:** `Monitor` for events, `run_in_background` for fire-and-forget.

### Asking Claude general knowledge questions in Claude Code
**Fails because:** wastes tokens; Claude Code is for tasks with tools.
**Instead:** claude.ai web for pure Q&A; Claude Code for code work.

## Verification anti-patterns

### "It compiled, ship it"
**Fails because:** type-check ≠ correct behavior.
**Instead:** also run the app and walk the smoke test.

### Trusting Claude's claim that "tests pass" without checking
**Fails because:** Claude might be misreading test output, or running the wrong tests.
**Instead:** read the test output yourself. Especially for security tests.

### Skipping the two-session RLS check
**Fails because:** the failure mode that leaks one user's data to another is the worst possible bug. Compiles fine.
**Instead:** for ANY auth-touching change, two-session check. No exceptions.

### Declaring a UI feature done without running it in a browser
**Fails because:** Claude has no eyes. Compiled UI can be broken UI.
**Instead:** `npm run dev`, walk it manually, on desktop AND mobile.

### Merging diffs you didn't read
**Fails because:** you become a rubber stamp. Bugs slip through. Eventually you can't maintain your own code.
**Instead:** read every diff. If too big to read carefully, the diff is too big.

## Security anti-patterns

(These are already in your global CLAUDE.md. Listed here for cross-reference.)

### `NEXT_PUBLIC_*` on sensitive values
**Fails because:** ships to browser. Anyone with devtools can read.
**Instead:** server-only env vars (no prefix), accessed in route handlers / server actions / `lib/server/`.

### `service_role` in shared `/lib/` files
**Fails because:** can be imported by a client component, bundled to browser.
**Instead:** `lib/server/db-admin.ts` — clearly marked server-only.

### `catch (e) {}` — swallowed exceptions
**Fails because:** hides failures, makes debugging hell.
**Instead:** handle meaningfully, OR rethrow with context, OR don't catch.

### `throw new Error('failed')` with no detail
**Fails because:** unactionable for debugging.
**Instead:** include the operation, relevant IDs, and what failed: `throw new Error(`failed to create quote for profile ${profileId}: ${cause.message}`)`.

### Logging PII or secrets to error trackers
**Fails because:** Sentry/PostHog persist this. GDPR exposure.
**Instead:** log structured events without PII; redact secrets at the logger.

### Editing an applied migration
**Fails because:** other environments will have the old version applied. Inconsistent state.
**Instead:** new migration that supersedes.

## Workflow anti-patterns

### Skipping stage 0 (Decide) — going straight to building
**Fails because:** you build something you didn't actually want.
**Instead:** PROJECT_BRIEF.md filled in before any code.

### Skipping stage 5 (Harden) — calling demoable "done"
**Fails because:** missing-state bugs ship to users.
**Instead:** dedicated hardening sessions for empty/loading/error states, dark mode, i18n, a11y.

### "I'll write the markdown files after the MVP works"
**Fails because:** you won't. And without them every session re-derives the project.
**Instead:** templates filled in during stages 0-2, before feature work starts.

### One big PR at the end
**Fails because:** huge diffs hide bugs.
**Instead:** commit per feature. Per stage at the latest.

## Long-term anti-patterns

### Shipping code you don't understand
**Fails because:** can't maintain, can't fix bugs in it, can't extend.
**Instead:** if you don't understand a Claude-produced block, ask for an explanation (not modification), then refactor for clarity.

### Letting CLAUDE.md drift
**Fails because:** every session starts with stale instructions. Claude makes wrong assumptions.
**Instead:** update CLAUDE.md when conventions change. Make it part of "the convention changed" workflow.

### Treating memory as a kitchen sink
**Fails because:** stale memories pollute future sessions.
**Instead:** prune `~/.claude/.../memory/MEMORY.md` periodically. Delete what's no longer true.

### Adding dependencies casually
**Fails because:** each dep is a supply chain risk, a maintenance cost, and bundle bloat.
**Instead:** justify each new dep in one line. Reject if you can do it in stdlib + 20 lines.

### "Claude built it, so it's tested"
**Fails because:** Claude tests against its own assumptions, not your users' reality.
**Instead:** manual smoke tests against real flows. Real browser. Real devices.

## Communication anti-patterns

### Talking to Claude as if it remembers other sessions
**Fails because:** it doesn't. Each session starts fresh.
**Instead:** state needed context in this session, or load it from files.

### Vague feedback ("this isn't right")
**Fails because:** Claude has to guess what you noticed. Often guesses wrong.
**Instead:** specific feedback. "The badge color logic doesn't handle the `archived` state."

### Correcting the same misunderstanding 3+ times
**Fails because:** if Claude keeps missing it, the framing is unclear or the session is drifting.
**Instead:** after 2 corrections, stop. Restart with the constraint stated explicitly upfront.

## Meta anti-patterns (Claude extending Claude's own setup)

These are the specific failure modes when the user proposes extending the system itself — manual, libraries, custom skills/agents, configs. The trap: when the topic is the manual, Claude exempts itself from following the manual.

### Building speculatively because the user asked
**Fails because:** the user asking for a library doesn't make the library non-speculative. Speculative is about evidence-of-need, not about who proposed it. Chapter 13 calls this out explicitly.
**Instead:** when the user says "build me a library of X," apply the same evidence-of-use test as for any speculative work. Cite chapter 13. Ask: "What's the actual repeated workflow this captures?" Only build after the answer.

### Copying impressive-looking patterns from screenshots
**Fails because:** screenshots show what looks impressive on social media, not what works for your specific token budget and project scale. The orchestrator + 7 specialists pattern looks great in a thread; it costs 900K tokens per feature.
**Instead:** when the user shows a screenshot and says "I want this," run the cost math first. If the cost is 10x what the same outcome would cost via a simpler pattern, surface that *before* building.

### Executor mode when reviewer mode was called for
**Fails because:** when the user is in proposal/planning mode ("should we...", "what about...", showing references), they want evaluation, not execution. Switching to executor without explicit approval skips the thinking partnership the user actually wanted.
**Instead:** stay in reviewer/planner mode by default when the user is exploring. Switch to executor only on explicit "build it" / "yes, do it" / "go ahead."

### Exempting the meta-work from the manual's own rules
**Fails because:** the manual's rules about scope, speculation, and anti-patterns apply to the manual itself. If chapter 13 says "don't write skills speculatively," that rule doesn't pause when the user proposes a skills library.
**Instead:** before extending the system, run the proposal through the manual's most relevant chapters (13, 16, 18). Surface what fires.

### Rewarding output volume over thinking
**Fails because:** writing 7 agent files looks like progress and feels like delivery. But if the right answer was "don't write any of those," the 7 files are negative value — they pollute future context and embed an anti-pattern in the system.
**Instead:** the senior dev's job is to surface "should we be doing this at all?" *before* writing the files. Lines of output ≠ value. Sometimes the highest-value output is the prompt "wait, the manual says don't do this — want to reconsider?"

### Treating "the user asked for it" as sufficient justification
**Fails because:** the user asks for things they later regret. They're testing ideas, sometimes following hype, sometimes proposing without having done the math. The thinking-partner role is to flag the problem. "You asked" is not a defense for skipping the challenge.
**Instead:** when the user proposes something that violates the manual's own rules, the manual wins — even if the user proposed it. Surface the conflict, recommend reconsidering. If after that the user still wants to proceed, fine — but the challenge must be made.

### Building first, evaluating after
**Fails because:** evaluation after the fact means deletion and rework. Evaluation before saves the work entirely.
**Instead:** for any non-trivial extension to the system (new chapter, new template, new skill, new agent), the order is: propose → evaluate against existing rules → user approves → build. Not: build → user notices problem → delete.

## TL;DR

Anti-patterns cluster around:

- **Vague prompts** — be specific.
- **Bundled scope** — split it.
- **Context bloat** — trim it.
- **Skipped verification** — do it anyway.
- **Drifted state** — write it down.
- **Trusting Claude blindly** — read what you ship.
- **Meta failures** — apply the manual's rules to the manual itself.

The cost of avoiding these is small. The cost of doing them is paid in bugs, rework, and lost trust.
