# 05a — Stage 0: Decide

**Before you open Claude Code.** This is the stage everyone skips and pays for later.

Time: 15–60 minutes. No code, no terminal.

## What you answer in writing

- **Who is this for?** A specific user, not "people."
- **What's the one user-visible outcome?** The thing they can do after this exists that they can't do now.
- **What's the smallest version that still delivers that outcome?**
- **What are you NOT building?** The explicit non-goals.
- **Kill criteria.** When would you abandon this?

If you can't answer these clearly, Claude won't save you. You'll churn in build sessions on questions you should have settled cold.

## Output

`PROJECT_BRIEF.md` filled in. Template is in `templates/PROJECT_BRIEF.md`.

This file is the source of truth for every later session. Stage 2 (architecture) and Stage 3 (build) read it first. If it's wrong, everything downstream is wrong.

## Why this is the highest-leverage 30 minutes of the project

The cost of a misaligned brief compounds. Every later session that builds in the wrong direction costs hours. Every architectural decision made against a fuzzy goal locks in the fuzziness. The brief is cheap; the rework is not.

## Common failure modes

- **Skipping straight to Stage 1** because "I'll figure it out as I go." You won't — you'll just discover the answer after building the wrong thing.
- **A brief written for the wrong user.** "Small businesses" is not a user. A specific person doing a specific job is.
- **No non-goals.** Without explicit "not building X," scope creep is inevitable in Stage 3.
- **No kill criteria.** You'll grind on a doomed project past the point it should have been abandoned.

## TL;DR

- 15–60 minutes, written, before any code.
- Five questions: user, outcome, smallest version, non-goals, kill criteria.
- Output: `PROJECT_BRIEF.md`. Every later session reads it.
