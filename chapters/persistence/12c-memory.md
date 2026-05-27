# 12c — Memory: what Claude learns about you

Memory is the layer for things Claude figures out over time. Unlike CLAUDE.md (you write it) and skills (you write them), memory is mostly written *by Claude* based on what happens in conversations.

## The four types

| Type | What it is | Example |
|---|---|---|
| **user** | Facts about you, your role, your preferences | "Senior dev, ten years Go, new to React" |
| **feedback** | Corrections and confirmations about how you want work done | "Don't mock the DB in tests — got burned last quarter" |
| **project** | Current state of ongoing initiatives | "Auth rewrite driven by compliance, not tech debt" |
| **reference** | Pointers to external resources | "Pipeline bugs tracked in Linear project INGEST" |

## How memory is loaded

- `MEMORY.md` is always loaded (it's the index, capped at ~200 lines).
- Individual memory files are loaded on-demand when relevant.

## Your job vs Claude's job

- **Claude writes memory** when you teach it something durable ("don't mock the DB in tests"), correct it, or share something durable about how you work.
- **You can ask it to remember explicitly** ("remember that I prefer the comma decimal format for prices") — it'll save it.
- **You should review memory occasionally** — `~/.claude/projects/<dir>/memory/MEMORY.md` is a normal file. Open it. Prune stale stuff. Memories silently age out of accuracy.

## When to save (and what)

Save when something is:

- **Durable** — true across multiple sessions, not just this conversation.
- **Non-obvious** — can't be derived from code, git log, or `CLAUDE.md`.
- **Load-bearing** — future-you (or future-Claude) will make a worse decision without it.

Skip when it's:

- Derivable from `package.json`, file structure, or `git log`.
- Ephemeral task state — that's `TaskCreate` within the session.
- Current project state — that's `PROGRESS.md` / `DECISIONS.md` in the project, not memory.

## Memory anti-patterns

- **Don't memorize project structure** — `tree` gives that.
- **Don't memorize specific functions or code** — that decays in days.
- **Don't memorize "current state" stuff** that should be in `PROGRESS.md`.
- **Don't memorize what was already documented** in CLAUDE.md.

## Verifying memory before acting

Memory records can become stale. Before recommending something based on memory:

- If the memory names a file path → check the file exists.
- If the memory names a function or flag → grep for it.
- If the user is about to act on the recommendation → verify the current state first.

"The memory says X exists" is not the same as "X exists now."

## TL;DR

- Four types: user, feedback, project, reference.
- `MEMORY.md` index always loaded; individual files on-demand.
- Claude writes; you review and prune.
- Project state goes in project docs, not memory.
- Verify before acting on a memory — they age.
