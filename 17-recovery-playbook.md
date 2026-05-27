> **DEPRECATED — v1 single-file chapter.**
> v2 atomic version: see [`chapters/recovery/`](chapters/recovery/) — split into smaller, independently-loadable files.
> Content here is preserved for cross-reference until v2 launch.

# 17 — Recovery playbook: when things go wrong

The chapter you re-read at 2am when nothing is working. Triage, then act.

## Step 1 — Recognize the failure mode

Most stuck-with-Claude situations are one of these. Diagnose before fixing.

| Symptom | Likely failure | First move |
|---------|---------------|------------|
| Same bug returns after "fix" | Drift — Claude forgot earlier constraint | Restart session, re-state |
| Claude proposes obviously wrong file paths | Hallucination | Verify each path; consider restart |
| Output gets generic / shallow | Dilution — context too full | Trim context or restart |
| Each fix introduces a new bug | Scope too big OR you don't understand the code | Pause; read what's there |
| "Tests pass" but feature broken | Wrong tests / no real verification | Manual smoke test now |
| Migration fails halfway | DB in mixed state | DON'T re-run blindly; inspect |
| Deploy succeeded, site broken | Env vars / DNS / runtime mismatch | Roll back first, investigate after |
| Claude won't stop "fixing" | You're letting it run unsupervised | Take back the wheel |
| You don't recognize the code | You shipped what you didn't understand | Stop. Read. Refactor or revert |

## Step 2 — Apply the right move

### Move A — Fresh session, re-orient
**For:** drift, dilution, "Claude is contradicting itself."

How:
1. Close the current terminal (or `/clear` if your client supports it).
2. Open new terminal.
3. Use Prompt A or E from `SESSION_STARTER.md`.
4. Re-state the critical constraints explicitly: "Before we start, remember: <thing Claude forgot>."
5. Pick up from the last committed state.

Cost: ~5 min lost. Benefit: a focused Claude that won't keep re-suggesting bad ideas.

### Move B — Verify, don't fix
**For:** hallucination — Claude is making confident claims.

How:
1. Stop accepting suggestions.
2. For each claim ("this function exists," "this is the Next.js 16 way"), verify:
   - `grep` for the symbol.
   - Check `package.json` version + the actual package's docs / changelog.
   - Read the actual file Claude is referencing.
3. If a claim was wrong, anything else from that session is suspect — re-verify.

Anti-pattern: "ok let me just trust this one." That's how the hallucination becomes the codebase.

### Move C — Shrink the scope
**For:** "each fix introduces a new bug" / "the feature won't converge."

How:
1. Commit (or stash) what's working.
2. List the failing pieces — write them down explicitly.
3. Pick the ONE smallest piece that can be fixed in isolation.
4. Fresh session, fix just that.
5. Verify. Commit. Repeat for the next piece.

The bug count problem is almost always a scope problem — you're trying to land too many changes at once.

### Move D — Read the diff
**For:** "you shipped what you don't understand" / "I'm afraid to touch this."

How:
1. **Start with `/code-review`** — Anthropic's diff-correctness review on the recent changes. Faster than reading by hand, catches what you'd miss. Optionally `/security-review` if auth/payments/PII touched.
2. **For something bigger, run `/ultrareview`** — multi-agent cloud review, heavyweight but thorough. User-triggered (you run it; Claude can't launch it). Pass the PR number or branch.
3. *After* the slash-command pass, read what they flagged. Don't ask Claude anything else yet.
4. `git log --oneline -20` — see what changed recently.
5. `git diff HEAD~5` (or wherever the trouble started).
6. Read it line by line. For each block: "what does this do? what does it depend on?"
7. If you don't understand a block, ask Claude to explain it (not fix it):
   > Explain `app/api/quotes/[id]/route.ts:42-80` like I'm new. What invariants does it assume?
8. Take notes. Possibly rewrite for clarity.

Cost: hours, maybe. Benefit: you actually understand your codebase again.

### Move E — Roll back
**For:** "deploy broke production" / "migration left DB in mixed state."

How:
1. Roll back FIRST. Don't try to fix forward under pressure.
2. Confirm production is back to known-good.
3. Then: investigate in a non-prod environment.
4. After fix: update `DEPLOY.md` with what was missing from the checklist.

### Move F — Refactor before adding
**For:** "code is getting tangled" / "I keep breaking things in unrelated files."

How:
1. Stop adding features.
2. Open a session focused only on simplifying.
3. Don't change behavior — make the existing behavior clearer.
4. Add tests for the parts you simplified, even if you usually don't.
5. *Then* resume feature work.

This is uncomfortable because it doesn't feel like progress. It is.

### Move G — Verify in a real browser (UI bugs)
**For:** "Claude says the UI works but it doesn't" / "looks fine in screenshots, broken in real use."

How:
1. Start dev server (`npm run dev`).
2. Walk the actual flow in your real browser — desktop AND mobile.
3. Open browser devtools. Check console, network tab.
4. For client/landing pages: also Lighthouse against the *running* site.
5. Or: use `mcp__plugin_playwright_*` tools to have Claude drive a browser and screenshot.

Claude has no eyes. Compiled ≠ working. Tests pass ≠ user-visible behavior correct.

## Step 3 — Update the system so it doesn't happen again

After recovery, ask: what missing check would have caught this?

- Bug shipped to prod → add the flow to `SMOKE_TESTS.md`.
- Deploy broke → add the missing step to `DEPLOY.md`.
- Claude hallucinated → tighten `CLAUDE.md` so it has the right anchor next time.
- Session went sideways at scope X → update `FEATURES.md` sizing for similar features.

The playbook gets shorter over time if you do this.

## Specific high-stakes recoveries

### "I committed secrets to a public repo"

1. Rotate the leaked credentials immediately (don't try to "git remove" first — assume the key is compromised the moment it hit GitHub).
2. Revoke the leaked key at the provider.
3. Issue a new one, update `.env`, redeploy.
4. Then clean the git history (`git filter-repo` or BFG) — but this is hygiene, not security. The rotation is what matters.
5. Audit: which other secrets are in the same `.env` file? Rotate if there's any chance they were exposed.

### "Migration failed and prod DB is in mixed state"

1. **Don't re-run the migration blindly.** Inspect what was applied.
2. Connect to prod DB. Run `\d <table>` to check current schema.
3. Manually finish or undo the partial migration.
4. Record exactly what you did in `DECISIONS.md`.
5. Write a follow-up migration that brings other environments in sync.
6. NEVER edit the original migration file. Forward-only.

### "Auth is broken — users can see other users' data"

1. Stop. This is critical.
2. Take the affected feature/route down if possible (revert, feature flag, hardcoded redirect).
3. Identify the scope: how many users could have been affected, what data exposed.
4. Fix the RLS policy or the route check.
5. Verify with the two-session test in `SMOKE_TESTS.md`.
6. Decide on disclosure. Talk to a human about this — depending on data exposed, GDPR may require notification.

This is the failure mode you must absolutely never normalize. The two-session RLS check exists for this reason.

### "I'm scared to touch the codebase"

The signal that AI workflows have failed you. Recovery:

1. Stop adding features. Seriously.
2. Identify the scariest file. Open it.
3. Ask Claude to explain it — not modify it.
4. Refactor it for clarity (smaller functions, better names, comments only where the *why* is non-obvious).
5. Move to the next scariest file.
6. Resume features only when you can explain every major file in your project.

The alternative is shipping a codebase you'll need to throw away. Cheaper to fix understanding now.

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

## TL;DR

- Diagnose the failure mode before applying a fix.
- Restart > re-prompt for drift/dilution.
- Verify > trust for hallucination.
- Shrink scope > push harder.
- Read the diff before asking Claude to do anything.
- Roll back first, investigate second, for production issues.
- Update the system after recovery so it doesn't recur.
- Walk away if you've been stuck for too long.
