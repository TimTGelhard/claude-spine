# 17c — High-stakes recoveries

When the failure touches secrets, money, identity, or user data, the generic recovery moves in [17b-recovery-moves.md](17b-recovery-moves.md) aren't enough. These four cases get their own playbook because the order of operations matters and the cost of doing them wrong is unrecoverable.

## "I committed secrets to a public repo"

1. **Rotate the leaked credentials immediately.** Don't try to "git remove" first — assume the key is compromised the moment it hit GitHub. Public repos are scraped by bots within minutes.
2. Revoke the leaked key at the provider.
3. Issue a new one, update `.env`, redeploy.
4. Then clean the git history (`git filter-repo` or BFG) — but this is hygiene, not security. The rotation is what matters.
5. Audit: which other secrets are in the same `.env` file? Rotate if there's any chance they were exposed.

## "Migration failed and prod DB is in mixed state"

1. **Don't re-run the migration blindly.** Inspect what was applied.
2. Connect to prod DB. Run `\d <table>` (or your DB's equivalent) to check current schema.
3. Manually finish or undo the partial migration.
4. Record exactly what you did in `DECISIONS.md`.
5. Write a follow-up migration that brings other environments in sync.
6. **NEVER edit the original migration file.** Forward-only. Editing an applied migration breaks every environment that already ran it.

## "Auth is broken — users can see other users' data"

1. **Stop.** This is critical. Treat as an active incident.
2. Take the affected feature/route down if possible (revert, feature flag, hardcoded redirect).
3. Identify the scope: how many users could have been affected, what data exposed.
4. Fix the RLS policy or the route check.
5. Verify with the two-session test — log in as user A in one browser, user B in another (or use private windows), and confirm B cannot see A's data.
6. Decide on disclosure. Talk to a human about this — depending on data exposed, GDPR / regional law may require notification.

This is the failure mode you must absolutely never normalize. The two-session check exists for this reason. If you're not running it on every auth-touching change, you're shipping this bug eventually.

## "I'm scared to touch the codebase"

The signal that AI workflows have failed you. Recovery:

1. Stop adding features. Seriously.
2. Identify the scariest file. Open it.
3. Ask Claude to explain it — not modify it.
4. Refactor it for clarity (smaller functions, better names, comments only where the *why* is non-obvious).
5. Move to the next scariest file.
6. Resume features only when you can explain every major file in your project.

The alternative is shipping a codebase you'll need to throw away. Cheaper to fix understanding now.

## Order-of-operations summary

| Crisis | First action | Second action | Never |
|---|---|---|---|
| Leaked secret | Rotate at provider | Clean git history | "git rm" first, rotate later |
| Migration mid-flight | Inspect current schema | Manual fix forward | Re-run the migration blindly |
| Data leak (RLS / auth) | Take feature down | Two-session re-test after fix | Patch silently without checking scope |
| Lost comprehension | Stop feature work | Refactor for clarity | Keep shipping on top of confusion |

The pattern: contain first, fix second, prevent recurrence third. Skipping containment to "save time" is how a recoverable incident becomes an unrecoverable one.
