# Subscription-based settings tuning

Loaded on-demand from `op-onboard/SKILL.md`'s step 5 (after the essentials are saved and the profile written, before offering the deep interview).

After essentials are saved, propose a `settings.json` tune based on Q1 (subscription). The spine ships Free-class defaults (`medium` / `120000`) so a brand-new Free user doesn't burn the daily limit on day one. Every paid tier should raise from there — this pass proposes the right target per plan and writes both keys in one shot if the user accepts.

## Mapping table (Q1 answer → target settings)

| Q1 answer | `autoCompactWindow` | `effortLevel` |
|---|---|---|
| Free | **120000** | **medium** |
| Pro | 180000 | high |
| Max (5×) | 180000 | high |
| Max (20×) | **800000** | **xhigh** |
| Other → Team (free-text matches `team`) | 180000 | high |
| Other → Enterprise (matches `enterprise`) | **400000** | high |
| Other → API / Bedrock / Vertex / OpenRouter / self-hosted (matches `api`, `bedrock`, `vertex`, `openrouter`, `pay-as-you-go`) | **400000** | high |
| Other → anything else | leave alone | leave alone |

(The shipped defaults are Free-class — `medium` + `120000`. The Free row in the table matches that exactly, so a Free user gets "no diff, skip silently" and pays no Pro tax. Every other row raises one or both keys. Team treats like Pro per seat. Enterprise and API/cloud-passthrough users get the same mid-class bump as Max 5× because their usage cap is per-organization or per-token rather than per-user-day — `effortLevel: high` is safe; `autoCompactWindow: 400000` is a middle-ground between Pro's 180K and Max 20×'s 800K. A user who hand-tuned will see the diff and can decline.)

The plan-tier names mirror [`docs/MODELS.md`](../../docs/MODELS.md)'s plan registry — see that file for the full list of named tiers Anthropic ships.

## Flow

1. Read `~/.claude/settings.json`. If it doesn't exist, skip the tune entirely (no install, no settings to touch).
2. Compute target values from the mapping table using Q1's answer.
   - For canonical answers (Free / Pro / Max 5× / Max 20×) read the matching row directly.
   - For Q1 = **Other (free-text)**, case-insensitive substring-match the free-text against the Other-row triggers in the table: `team` → Team row, `enterprise` → Enterprise row, any of (`api`, `bedrock`, `vertex`, `openrouter`, `pay-as-you-go`) → API row. Multiple matches resolve to the *first* match in that list (Team beats API, etc.). No match → the "Other → anything else" row (leave alone, skip silently with a one-line summary note).
3. If target matches current for both keys → no diff, skip silently.
4. If the Q1 free-text matched no Other-row trigger → skip silently and note in the post-write summary that settings.json was left alone (point at `docs/MODELS.md`'s plan registry + `global/INSTALL.md`'s "Tuning for Max 20×" section as the hand-tune references).
5. Otherwise → first print a short **plain-English explanation block** as a normal text message (not inside `AskUserQuestion`), then ask the Apply/Skip question. Template the block like this (substitute the user's subscription name and the current/target numbers):

   ```
   You're on {{plan}}. The defaults ship Free-class so a Free user doesn't
   burn the daily limit on day one — let me propose two tweaks so you get
   the most out of your plan:

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
