> **DEPRECATED** — v2 atomic version: [`chapters/foundations/`](../../chapters/foundations/). Full v1→v2 map: [`V1-CHAPTERS-DEPRECATED.md`](../../V1-CHAPTERS-DEPRECATED.md). Body kept for cross-reference.

# 03 — Limits: what Claude can't do well

Knowing the limits saves you from realizing mid-project that your approach was doomed. This is the most important file to internalize before committing to a serious build.

## Hard limits (Claude genuinely can't do these reliably)

### 1. Hold a giant project coherently in one session
Even with 1M context, multi-week projects don't fit in one session — and they shouldn't. Quality degrades regardless of window size when there are too many decisions to keep consistent. Project = many sessions. See [06-feature-sizing.md](06-feature-sizing.md).

### 2. Know what's in your installed package versions
Frameworks move fast. Claude's training has a cutoff. Even with recent knowledge updates, version-specific syntax (Next.js 16 specifics, library APIs that changed last month) is *guessed* if Claude doesn't check. Always have it verify against actual installed code when it's uncertain — and call it out when something "feels confident but might be made up."

### 3. See your running app
Claude can't open your browser, click buttons, or interact with your live UI by itself (without specific tools like Playwright MCP). For UI verification: *you* run the dev server and walk it, or you set up an MCP that lets Claude drive a browser. Otherwise Claude is flying blind.

### 4. Know what your users actually do
Claude can guess at user flows. It can't validate them. UX decisions need real users, not Claude's intuition.

### 5. Recall earlier-session decisions perfectly
After compaction or in a new terminal, fine-grained decisions get lost. The only durable memory is files: `CLAUDE.md`, `ARCHITECTURE.md`, `DECISIONS.md`. If a decision isn't written down, assume next session won't know about it.

### 6. Do creative product strategy
Claude is solid at executing a defined product. It's mediocre at deciding what to build, what to charge for, who the user is. Those are your job. Stage 0 in [05-workflow.md](05-workflow.md).

### 7. Match your taste without examples
"Make it modern" or "make it clean" gets generic, AI-default aesthetics. To get your taste, show examples (real apps, references, your existing brand) or set very specific design constraints. See [10-visuals.md](10-visuals.md).

## Soft limits (Claude can, but unreliably — use with care)

### 1. Anything time-sensitive or rate-limited
External API quotas, time-of-day-specific behavior, race conditions. Claude can write code for these but can't *experience* them. Test in the real environment.

### 2. Complex multi-step debugging with state
"This worked yesterday, today it doesn't, here's what I changed" — Claude can guess. But state-dependent bugs (race conditions, cache invalidation, intermittent failures) often need you with a debugger, not Claude with a diff.

### 3. Cross-process / cross-machine interactions
Webhook from Stripe arriving at your local dev → ngrok → Next.js → Supabase. Claude can build it. Claude can't always tell you *which hop* is failing.

### 4. Performance optimization without measurement
Claude will happily suggest "optimizations." Most are guesses. Without profiling data, the suggestions are random walks. Get data first, then ask.

### 5. Long-running operations
Claude works in turns. It can't watch a slow migration finish — you have to bring back the result.

## Project types Claude handles well

- **Greenfield MVPs** with a defined stack. Excellent.
- **Static client sites** (landing pages, small-business sites). Excellent.
- **Dashboards with CRUD + auth.** Strong.
- **Single-feature additions** to existing codebases. Strong.
- **Mechanical refactors** (rename, restructure, type tightening). Strong.
- **Migrations between framework versions** when codemods exist. Good with the right skill loaded.

## Project types Claude struggles with

- **Large existing codebases** (>50K lines) where conventions are implicit and undocumented. Claude can't infer everything from reading; without a strong `CLAUDE.md` it'll fight your conventions.
- **Realtime / WebSocket-heavy systems** where ordering and concurrency matter.
- **Native iOS/Android work outside Expo** (Swift, Kotlin) — Claude can write it but iteration cycles are slow without device access.
- **Game development** — Claude has weaker training on game-specific patterns.
- **Heavy data engineering / ML pipelines** that need empirical validation against datasets you can't easily show Claude.
- **Anything regulated** (medical, financial advisory, legal) where correctness must be auditable and lawyer-reviewed. Use Claude as a drafting tool, not source of truth.
- **Big design systems from scratch** — Claude defaults toward generic. You need strong examples and tight constraints.

## Warning signs you've hit a limit mid-project

- Claude keeps proposing fixes that don't address the actual problem.
- Each "fix" introduces a new bug elsewhere.
- You've corrected the same misconception 3+ times.
- Claude is hallucinating file paths, function names, or features.
- The diff for "small fix" is larger than the original code.
- You're losing your own understanding of the codebase.
- You're afraid to touch certain files because "Claude built them and I don't know how they work."

**Any one of these:** pause. Open a fresh terminal. Re-orient.
**Two or more:** the *project* may have outgrown your understanding. Worth a manual review session before continuing.

## The "I don't understand my own code" failure mode

The biggest risk in heavy-AI workflows. Symptoms:
- You ship a feature you couldn't re-implement from scratch.
- A bug appears in code you don't recognize.
- You can't predict what changing one file will break.

Counter-measures:
- **Read the diffs.** Every commit. Don't blind-accept.
- **Walk through complex code with Claude as tutor:** "Explain this file like I'm new. What does each section do? What invariants does it assume?"
- **Refactor when you stop understanding.** Better to spend a session simplifying than to ship code you can't maintain.

## What this means for project planning

Before committing to build:

1. **Does the project fit in 20-40 feature sessions?** If you can't list ~15-30 features, it might be too vague. If you list 100+, it's too big for solo MVP.
2. **Is there a regulated domain?** Add a "legal/compliance review" stage; don't let Claude write the rules.
3. **Is there a piece Claude struggles with?** (Realtime, native, big design system?) That piece is the riskiest — start there, prototype it first, see if it works.
4. **Can you verify what gets built?** If you can't run, click, and test, you can't ship reliably with AI-heavy workflow.

## Honest framing for clients

When pitching client work or MVP builds, the honest version is:
- "I use AI tools to ship faster, but I review every change."
- Not: "AI builds it for me."

Because if a client touches a bug in code "you" shipped, you're the one fixing it — Claude doesn't take support calls.

## TL;DR

- Frameworks move faster than Claude's training — verify version-specific stuff.
- Claude can't see your app run — you have to walk it.
- Decisions decay across sessions — write them in files.
- Generic taste by default — show references for design.
- Project too big = ship in slices, not "have Claude do it all."
- Don't ship code you don't understand. Read the diffs.
