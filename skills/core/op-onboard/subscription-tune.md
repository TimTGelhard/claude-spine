# Subscription-based settings tuning

Loaded on-demand from `op-onboard/SKILL.md`'s step 5 (after the essentials are saved and the profile written, before offering the deep interview).

After essentials are saved, propose a `settings.json` tune based on Q1 (subscription). The spine ships Pro-safe defaults; Free users burn limits faster than necessary on those defaults, and Max 20× users with 1M-context models leave performance on the table unless these get raised. The tune is symmetric — propose *lowering* for Free and *raising* for Max 20× from the same flow.

## Mapping table (Q1 answer → target settings)

| Q1 answer | `autoCompactWindow` | `effortLevel` |
|---|---|---|
| Free | **120000** | **medium** |
| Pro | 180000 | high |
| Max (5×) | 180000 | high |
| Max (20×) | **800000** | **xhigh** |
| Other (free-text) | leave alone | leave alone |

(Free-tier values lower the context window before auto-compact and use a less-expensive reasoning depth so Free users hit daily limits less often. A user who hand-tuned will see the diff and can decline.)

## Flow

1. Read `~/.claude/settings.json`. If it doesn't exist, skip the tune entirely (no install, no settings to touch).
2. Compute target values from the mapping table using Q1's answer.
3. If target matches current for both keys → no diff, skip silently.
4. If Q1 was "Other" → skip silently. Mention in the post-write summary that settings.json was left alone and point at `global/INSTALL.md`'s "Tuning for Max 20×" section.
5. Otherwise → first print a short **plain-English explanation block** as a normal text message (not inside `AskUserQuestion`), then ask the Apply/Skip question. Template the block like this (substitute the user's subscription name and the current/target numbers):

   ```
   You're on {{plan}}. The defaults ship Pro-safe — let me propose two tweaks
   so you get the most out of your plan:

     • autoCompactWindow:  {{current}} → {{target}} tokens
       (how full the conversation gets before Claude auto-compresses earlier
       messages — raising this lets you stay in one session longer without
       losing context. Safe on plans with bigger context windows.)

     • effortLevel:  {{current}} → {{target}}
       (how much reasoning Claude does per response. "xhigh" is the deepest
       setting and is only worth it when your plan covers the extra cost.)

   Both write to ~/.claude/settings.json. You can hand-edit either value later.
   ```

   Then call `AskUserQuestion` with a tight question:
   - **Question:** "Apply these two settings tweaks?"
   - **Header:** `Settings`
   - **Option A:** **Apply** — "Write both values to settings.json"
   - **Option B:** **Skip** — "Leave settings.json alone (recommended if you've hand-tuned)"

6. On Apply: use `Edit` to replace the two key lines in-place. Do NOT rewrite the whole file — preserve the rest exactly. If the format doesn't match (e.g., user reformatted settings.json), abort the write and tell the user to hand-edit; do not retry with broader matching.
7. On Skip: note it and continue. The profile still reflects the subscription answer — just settings.json is untouched.

The explanation block is always shown, regardless of whether current values match ship defaults. A user who hand-tuned to `400000` and re-runs `/onboard` will see "400000 → 800000" and decline; that's the correct outcome — explicit approval, not silent inference.
