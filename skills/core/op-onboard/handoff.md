# After writing the profile — the handoff

Loaded on-demand from `op-onboard/SKILL.md`'s step 8 (the closing message).

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
    plus two opt-in hooks (auto-typecheck, auto-format) — 18 personal
    questions + 2 hook prompts, ~5 min].
  • VCS host: [GitHub — `gh` already in your Bash allowlist | GitLab — add
    `Bash(glab:*)` to `~/.claude/settings.json` for full integration |
    Bitbucket — add `Bash(bb:*)` (Atlassian CLI) | None / Other — no host
    integration suggested].

What you have available now:
  /spine            see everything that's loaded (skills, commands, chapters)
  /hooks            list every hook configured for this session (event + script)
  /prep             plan a new project or a major feature  (run in a project dir)
  /onboard          re-run essentials  (`--deep` for the full 28-question pass)
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
```

## Hard rules for the handoff

1. **Always emit this block** on first-run completion and on every re-run, even if the user only re-answered one essential. Re-runs are how the user double-checks their setup landed correctly.
2. **Substitute real values** — do not leave bracketed placeholders. If the user picked "Other" for any field, use their free-text answer verbatim.
3. **Only list commands that exist** — count `~/.claude-spine/global/commands/*.md` if uncertain. Don't invent commands that aren't installed.
4. **No follow-up questions in this block.** It's the closing message. The user knows where to go.
5. **No marketing.** Don't tell the user the spine is "powerful" or "production-grade." State what was captured and what's available.
6. **VCS-host inject is a suggestion, not a mutation.** The line names the CLI that fits the user's Q8 answer; the spine does NOT auto-add `glab` / `bb` to the Bash allowlist. Users edit `~/.claude/settings.json` themselves — the inject just tells them *which line* to add.
