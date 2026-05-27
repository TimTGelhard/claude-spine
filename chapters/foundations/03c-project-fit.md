# 03c — Project-type fit

Knowing where Claude shines vs struggles saves you from realizing mid-project that your approach was doomed.

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
