---
description: Capture a high-signal moment to your personal queue at ~/.claude-spine/bucket/SUGGESTIONS.md. Manual entry point for op-suggest — use when you want something logged that didn't trip a natural trigger.
---

Invoke the `op-suggest` skill.

Read `~/.claude-spine/skills/core/op-suggest/SKILL.md` and follow it. This is the explicit-entry-point path — the user used the slash command, so the high-threshold gate is already satisfied. Skip straight to gathering the entry:

1. Ask for a one-line title.
2. Ask for the type (`new-skill` / `new-chapter` / `profile-update` / `observation`).
3. Ask for the proposed change (one concrete line).
4. Use the slash-command invocation itself as the `Trigger` field (e.g., "User invoked `/suggest` — '<title>'").
5. Append the entry to `~/.claude-spine/bucket/SUGGESTIONS.md` per the schema in the SKILL.

After writing, acknowledge in one line and stop. No follow-up "want me to also…".
