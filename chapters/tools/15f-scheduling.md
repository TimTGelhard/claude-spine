# 15f — Scheduling: cron, loop, ScheduleWakeup

Three mechanisms for "run something later or repeatedly." Different layers.

## ScheduleWakeup

**Use for:** within an autonomous loop or `/loop` skill, deciding when to next check on a long-running task.

Niche. The harness already notifies you when background work completes — don't sleep-poll. Use `ScheduleWakeup` only when:

- Watching external state the harness can't track (CI run, deploy, remote queue).
- A `/loop` skill in dynamic mode self-pacing iterations.

**Picking a delay:** the prompt cache TTL is ~5 minutes. Under 5 min → cache stays warm; over 5 min → pay the cache miss. Don't pick 300s exactly — worst of both. Default to 1200–1800s for idle ticks where there's no specific signal to watch.

## /loop

**Use for:** running a prompt or slash command on a recurring interval in the current session. ("check the deploy every 5 minutes", "keep running `/babysit-prs`")

Don't use for one-off tasks. The interval can be a duration (`5m`) or self-paced (omit interval and Claude decides).

## /schedule + CronCreate

**Use for:** scheduled *remote* agents — running on a cron schedule outside any session.

Cron-style routines that wake up, run a task, return a result. Useful for ongoing maintenance ("check the deploy status every morning"). Rare for solo MVP work — most scheduled work is better done by CI or platform crons.

## Choosing between them

| Need | Use |
|---|---|
| Wait inside an autonomous loop until a condition changes | `ScheduleWakeup` |
| Recurring task during this session | `/loop` |
| Recurring task while you're not in a session | `/schedule` / `CronCreate` |
| One-off scheduled run ("at 3pm tomorrow") | `/schedule` (one-shot) |

## TL;DR

- `ScheduleWakeup`: niche, for autonomous loops watching external state.
- `/loop`: recurring within this session.
- `/schedule` / Cron: recurring across sessions.
- Don't sleep-poll harness-tracked work — you'll be notified.
