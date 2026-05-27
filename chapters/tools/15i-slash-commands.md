# 15i — Slash commands: Anthropic-tested workflows

Anthropic ships first-party commands invoked with `/<name>`. They're maintained, tested, and kept current — for the things they cover, they beat both custom skills and ad-hoc manual approaches.

**The behavioral rule:** when the user says "review this," "audit this," "check that it works," "is this safe to ship," reach for the slash command *first*. Do the work manually only when no slash command fits.

## Tier 1 — High-value, use often

| Command | When | Why it beats manual |
|---|---|---|
| `/ultrareview` | Before merging significant PRs / branches | Multi-agent cloud review. Heavyweight, billed separately. **User-triggered only — Claude cannot launch it.** Pass `<PR#>` for a GitHub PR, or no arg for local branch. |
| `/security-review` | Before any deploy touching auth / payments / PII; after dependency changes | Independent security audit of pending diff |
| `/code-review` | After any non-trivial change | Diff correctness review. `--comment` posts as PR comments. Effort levels low/medium/high/max. |
| `/verify` | "Does this actually work end-to-end?" | Runs the app, walks the flow, checks browser → API → data → response. Replaces manual smoke walks. |

## Tier 2 — Useful operational

| Command | When |
|---|---|
| `/init` | Starting in a codebase without `CLAUDE.md` |
| `/run` | Drive the actual app to see a change working |
| `/skill-creator` | Authoring a new skill — knows current schema |
| `/update-config` | Settings.json edits (hooks, permissions, env vars) |
| `/fewer-permission-prompts` | After a session of approving the same commands |
| `/keybindings-help` | Custom keybindings |

## Tier 3 — Specialized

- `/loop <interval> <prompt>` — Run on recurring interval.
- `/schedule` — Cron-style scheduled remote agents.
- Vercel suite: `/vercel:deploy`, `/vercel:env`, `/vercel:status`, etc.

## Built-in (always available)

- `/help` — Help.
- `/clear` — Clear conversation.
- `/config` — Settings.
- `/fast` — Toggle Opus speed mode.

## When to use slash commands vs alternatives

| Need | Use | Don't use |
|---|---|---|
| Review a diff | `/code-review` | Manual "let me look at the diff" |
| Security audit | `/security-review` | Ad-hoc grep + checklist |
| Verify a feature works | `/verify` | Asking Claude "did it work?" |
| Heavy PR review | `/ultrareview` | Multiple manual passes |
| Generate CLAUDE.md | `/init` | Writing from scratch |
| Settings.json edit | `/update-config` | Hand-editing JSON |
| Skill authoring | `/skill-creator` | Hand-writing frontmatter |

## TL;DR

- Slash commands are the Anthropic-tested version of work you'd otherwise do by hand.
- Defaulting to them saves time, catches more, stays current.
- `/code-review`, `/security-review`, `/verify`, `/ultrareview` — reach for these first.
- `/update-config`, `/skill-creator` — use these instead of hand-editing schemas.
