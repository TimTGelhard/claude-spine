# After writing the profile — the handoff

Loaded on-demand from `op-onboard/SKILL.md`'s step 9 (the closing message).

This is the **only place** the user gets a complete picture of what just happened and what's now possible. Don't be terse here. Don't lecture either — this is one focused, well-structured message that lands the experience. Treat it like the "you're all set" screen of a polished app.

Emit a single message in this shape. Substitute the bracketed values from what the user actually picked. Drop any section that doesn't apply (e.g., the deep-mode line if they completed deep).

```
You're set up. Profile saved to ~/.claude/claude-spine-profile.md.

Here's what just happened:
  • I know you're a [Plan] user with [Experience] experience, working mostly
    on [Stack] for [Project context].
  • Across every Claude Code session on this machine, I'll match your
    push-back intensity ([Push-back]), answer length ([Answer length]),
    and reasoning depth ([Reasoning depth]).
  • settings.json: [tuned to {{plan}} defaults | left alone | not present].
  • Opt-in hooks: [auto-typecheck + auto-format on | auto-typecheck on |
    auto-format on | declined both | already configured — left alone |
    not offered (essentials-only)].  `/hooks` lists what fires this session.
  • Deep profile: [completed | skipped — run `/onboard --deep` when you want
    to capture stack details, signal preferences, output format, risk
    tolerance, session shape, plans-dir location, team/org shape, currency,
    plus (for UI apps) deploy target + database default, plus two opt-in
    hooks (auto-typecheck, auto-format) — 18 personal questions + up to
    2 conditional follow-ups + 2 hook prompts, ~5–6 min].
  • Deploy target + database: [{{W1, W2 verbatim}} | not asked — your
    Artifact wasn't a UI app, so Section W was skipped (hand-edit
    `Project context → Deploy target` / `Database` in the profile if
    your project has one you want me to remember) | not asked — deep
    was skipped].
  • VCS host: [GitHub — `gh` already in your Bash allowlist, no extras
    needed | GitLab — `+vcs-gitlab.json` {{merged into ~/.claude/settings.json |
    available but declined the auto-merge — re-run /onboard --deep to revisit}}
    | Bitbucket — same shape with `+vcs-bitbucket.json` | None / Other — no
    host integration suggested].
  • Stack extras: [{{none suggested for your stack | merged: list each
    `+<name>-stack.json` the user accepted | declined: list each fragment
    the user skipped | mixed: name each by state, e.g. "+vercel-stack.json
    merged, +supabase-stack.json skipped"}}]. See
    `~/.claude-spine/global/settings-extras/README.md` to browse what else
    is available or merge by hand later.

What you have available now:
  /spine            see everything that's loaded (skills, commands, chapters)
  /hooks            list every hook configured for this session (event + script)
  /prep             plan a new project or a major feature  (run in a project dir)
  /onboard          re-run essentials  (`--deep` for the full ~28-question pass; +2 conditional follow-ups for UI apps)
  /suggest          capture a high-signal moment to your personal bucket
  /curate           review captured moments and apply approved ones
  /add-skill        add a new skill to your personal bucket
  /done             close the current build session cleanly
  /refresh-bucket   rebuild the bucket index after manual file drops

What to do next:
  • Starting a new project?  cd into the directory and run /prep.
  • In an existing codebase?  Just ask me something — I'll route based on
    what you need. Type /spine if you want to see the full surface.
  • Just exploring?  Ask "what is claude-spine" or open ~/.claude-spine/README.md.

Both your profile (~/.claude/claude-spine-profile.md) and settings
(~/.claude/settings.json) are plain files — open and hand-edit anytime.
Re-run /onboard to walk through the essentials again.

Want to know what each profile field actually changes? Ask me to read
chapters/personalization/19g-field-effects.md — it maps every field to the
chapters / skills / hooks that consume it.
```

## Placeholder substitution at chapter-read time

Two literal placeholders the spine carries are substituted at read-time (never stripped from the source): `{{PR_OR_MR}}` in chapter prose, and `{{Q4}}` in stack-template CLAUDE.md stubs.

### `{{PR_OR_MR}}` — Q8-driven (chapter source-prose)

Chapter source-prose under `chapters/workflow/` and `chapters/anti-patterns/` uses the literal placeholder `{{PR_OR_MR}}` where it would otherwise lean GitHub-first ("PR" / "pull request"). When you load one of these chapters, substitute the placeholder at read-time before quoting any line back to the user:

- **Q8 = GitHub** → `pull request` (lowercase prose) or `PR` (acronym contexts — headings, short phrasing)
- **Q8 = GitLab** → `merge request` / `MR`
- **Q8 = Bitbucket** → `pull request` / `PR` (Bitbucket uses the GitHub vocabulary)
- **Q8 = None — local-only** → fall back to `commit` / `branch` in prose; the `{{PR_OR_MR}}` concept doesn't apply, so reframe rather than substitute literally
- **Q8 = Other (free-text)** → use `PR` as the safe default unless the free-text mentions `gitlab` or `merge request`, in which case use `MR`
- **No profile** → `PR` as the safe default (GitHub is the dominant host in this audience)

### `{{Q4}}` — Q4-driven (stack-template push-back bullet)

`global/stacks/<name>/CLAUDE.md.template` carries the literal `{{Q4}}` placeholder in rule 2 of the always-on block. The installed `~/.claude/CLAUDE.md` keeps the placeholder — substitute at read-time based on the user's `Working style → Push-back intensity` value:

- **Q4 = Just do it** → "**Just do it.** Senior dev, not order-taker. Make a reasonable assumption, state it in one line, ship it. Only stop if something is genuinely going to break — security, data loss, hard-to-reverse decisions."
- **Q4 = Mention concerns, then continue** → "**Mention concerns, then continue.** Senior dev, not order-taker. If you see a real issue, flag it once with the action you'll take, then proceed. Don't make me ask for the concerns; don't ask permission to surface them."
- **Q4 = Argue your side** → "**Push back. Spar with me.** Senior dev, not order-taker. Weak ideas get challenged. On non-trivial choices, surface 1–2 alternatives with honest tradeoffs *before* building. Never silently pick the first thing."
- **Q4 = Teach me along the way** → "**Teach me along the way.** Senior dev, not order-taker. Surface what you'd correct or refine — even small things — and name the underlying principle. Tradeoffs explicit, not implicit. The point is for me to learn the why, not just get the diff."
- **No profile / unfilled** → use the "Mention concerns, then continue" variant (matches the shipped chapters' baseline tone).

The same four variants live in `chapters/signaling/11g-push-back-phrasing.md` so the chapter and the substitution table agree. If you edit one, edit both.

### Discipline for both placeholders

Both placeholders are intentional — never strip them from the source. The source is the source of truth; the substitution is a render-time concern that happens whenever the file is read into context.

## Hard rules for the handoff

1. **Always emit this block** on first-run completion and on every re-run, even if the user only re-answered one essential. Re-runs are how the user double-checks their setup landed correctly.
2. **Substitute real values** — do not leave bracketed placeholders. If the user picked "Other" for any field, use their free-text answer verbatim.
3. **Only list commands that exist** — count `~/.claude-spine/global/commands/*.md` if uncertain. Don't invent commands that aren't installed.
4. **No follow-up questions in this block.** It's the closing message. The user knows where to go.
5. **No marketing.** Don't tell the user the spine is "powerful" or "production-grade." State what was captured and what's available.
6. **VCS-host + stack extras reflect what just happened.** In deep mode the `extras-merge` pass may have merged one or more `settings-extras/+*.json` fragments into `~/.claude/settings.json` (with explicit Apply per fragment). The VCS-host and Stack-extras lines must report the *actual* state per fragment — `merged`, `declined`, or `not suggested` — not the generic "we suggested this". Source of truth: the Apply/Skip answers captured during `extras-merge.md`.
