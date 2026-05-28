---
description: Run or re-run the claude-spine personal profile interview. Pass --deep for the full ~28-question pass (+ up to 2 conditional follow-ups when your artifact is a UI app — deploy target + database default) plus two opt-in `settings.json` tweaks (auto-typecheck + auto-format hooks); otherwise runs the 10-question essentials. The essentials path also proposes a one-time `settings.json` tune sized to your Claude plan.
argument-hint: [--deep]
---

Invoke the `op-onboard` skill.

Arguments: `$ARGUMENTS`

- If `$ARGUMENTS` contains `--deep`, run the deep interview path (essentials first if no profile exists yet, then deep). Read `~/.claude-spine/skills/core/op-onboard/questions-deep.md` after the essentials.
- Otherwise, run only the essentials path (read `~/.claude-spine/skills/core/op-onboard/questions-essential.md`). After saving, offer the deep path.

Write the result to `~/.claude/claude-spine-profile.md` following the layout in `~/.claude-spine/skills/core/op-onboard/profile-template.md`.
