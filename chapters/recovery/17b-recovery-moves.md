# 17b — Recovery moves

Seven moves. Diagnose with [17a-failure-triage.md](17a-failure-triage.md) first, then pick the matching move. After recovery, update the system so the same failure can't recur.

## Move A — Fresh session, re-orient

**For:** drift, dilution, "Claude is contradicting itself."

How:
1. Close the current terminal (or `/clear` if your client supports it).
2. Open a new terminal.
3. Use the orientation prompt from `SESSION_STARTER.md`.
4. Re-state the critical constraints explicitly: "Before we start, remember: <thing Claude forgot>."
5. Pick up from the last committed state.

Cost: ~5 min lost. Benefit: a focused Claude that won't keep re-suggesting bad ideas.

## Move B — Verify, don't fix

**For:** hallucination — Claude is making confident claims.

How:
1. Stop accepting suggestions.
2. For each claim ("this function exists," "this is the right API for this version"), verify:
   - `grep` for the symbol.
   - Check `package.json` version + the actual package's docs / changelog.
   - Read the actual file Claude is referencing.
3. If a claim was wrong, anything else from that session is suspect — re-verify.

Anti-pattern: "ok let me just trust this one." That's how the hallucination becomes the codebase.

## Move C — Shrink the scope

**For:** "each fix introduces a new bug" / "the feature won't converge."

How:
1. Commit (or stash) what's working.
2. List the failing pieces — write them down explicitly.
3. Pick the ONE smallest piece that can be fixed in isolation.
4. Fresh session, fix just that.
5. Verify. Commit. Repeat for the next piece.

The bug count problem is almost always a scope problem — you're trying to land too many changes at once. See also [chapters/workflow/06-feature-sizing.md](../workflow/06-feature-sizing.md).

## Move D — Read the diff

**For:** "you shipped what you don't understand" / "I'm afraid to touch this."

How:
1. **Start with `/code-review`** — diff-correctness review on the recent changes. Faster than reading by hand, catches what you'd miss. Optionally `/security-review` if auth/payments/PII touched.
2. **For something bigger, run `/ultrareview`** — multi-agent cloud review, heavyweight but thorough. User-triggered (you run it; Claude can't launch it). Pass the PR number or branch.
3. *After* the slash-command pass, read what they flagged. Don't ask Claude anything else yet.
4. `git log --oneline -20` — see what changed recently.
5. `git diff HEAD~5` (or wherever the trouble started).
6. Read it line by line. For each block: "what does this do? what does it depend on?"
7. If you don't understand a block, ask Claude to explain it (not fix it):
   > Explain `app/api/quotes/[id]/route.ts:42-80` like I'm new. What invariants does it assume?
8. Take notes. Possibly rewrite for clarity.

Cost: hours, maybe. Benefit: you actually understand your codebase again.

## Move E — Roll back

**For:** "deploy broke production" / "migration left DB in mixed state."

How:
1. Roll back FIRST. Don't try to fix forward under pressure.
2. Confirm production is back to known-good.
3. Then: investigate in a non-prod environment.
4. After fix: update `DEPLOY.md` with what was missing from the checklist.

Specific high-stakes recoveries (secrets leaked, RLS broken, prod DB mid-migration) live in [17c-high-stakes-cases.md](17c-high-stakes-cases.md). Jump there before applying this generic move.

## Move F — Refactor before adding

**For:** "code is getting tangled" / "I keep breaking things in unrelated files."

How:
1. Stop adding features.
2. Open a session focused only on simplifying.
3. Don't change behavior — make the existing behavior clearer.
4. Add tests for the parts you simplified, even if you usually don't.
5. *Then* resume feature work.

This is uncomfortable because it doesn't feel like progress. It is.

## Move G — Verify in a real browser (UI bugs)

**For:** "Claude says the UI works but it doesn't" / "looks fine in screenshots, broken in real use."

How:
1. Start the dev server.
2. Walk the actual flow in your real browser — desktop AND mobile.
3. Open browser devtools. Check console, network tab.
4. For client/landing pages: also run Lighthouse against the *running* site.
5. Or: use the Playwright MCP tools to have Claude drive a browser and screenshot.

Claude has no eyes. Compiled ≠ working. Tests pass ≠ user-visible behavior correct.

## Step 3 — Update the system

After any recovery, ask: what missing check would have caught this?

- Bug shipped to prod → add the flow to `SMOKE_TESTS.md`.
- Deploy broke → add the missing step to `DEPLOY.md`.
- Claude hallucinated → tighten `CLAUDE.md` so it has the right anchor next time.
- Session went sideways at scope X → update `FEATURES.md` sizing for similar features.

The playbook gets shorter over time if you do this.

## When to walk away

Sometimes recovery isn't worth it.

Signs to consider abandoning the current approach:
- You've restarted 3+ times and the same problems recur.
- The "small fix" has grown into a 500-line diff.
- You can't explain what the feature should do anymore.
- You hate looking at the code.

Options:
- **Revert to a known-good state and rebuild that piece.** Tomorrow's you with fresh eyes is much smarter.
- **Cut the feature.** If you've burned days on something you can't get right, it may not be worth shipping.
- **Sleep.** Genuinely. Most stuck-with-Claude moments dissolve after a real break.
