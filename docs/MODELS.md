# MODELS — Anthropic model + plan-tier registry

> Single source of truth for the Anthropic model IDs and Claude.ai plan names
> the spine references. Updated when the lineup changes (new models, retired
> versions, renamed tiers); chapters and templates point at this file instead
> of duplicating the names.
>
> **Maintenance:** when Anthropic ships a new model or retires one, edit
> *this* file plus any pinned runtime constants below. Chapter prose links
> here; `op-onboard`'s Q1 mapping reads the plan names listed here. The
> registry is the only place that should ever name a specific model version
> in marketing-prose framing — runtime constants in scripts are scope-limited
> to their script's purpose and can lag the registry by a release.

Last updated: 2026-05-28.

---

## Current model lineup (most-recent first)

| Model | ID | Context | Strengths | Cost class |
|-------|-----|---------|-----------|------------|
| Opus 4.7 | `claude-opus-4-7` | 1M (with `[1m]` flag) / 200K default | Hardest reasoning, best long-context, best multi-file refactors | Highest |
| Sonnet 4.6 | `claude-sonnet-4-6` | 200K | Workhorse — fast, capable, sufficient for most tasks | Mid |
| Haiku 4.5 | `claude-haiku-4-5-20251001` | 200K | Fast and cheap for narrow, well-specified tasks | Low |

**1M-context variant:** Opus 4.7 supports a 1M-token context via the `[1m]`
suffix — `claude-opus-4-7[1m]`. The default 200K variant is what `claude -p`
loads unless asked otherwise.

**Retired / older models:** when a version is retired, move its row to the
"Older releases" section below with a note on when it was retired and what
replaces it. Don't delete — chapters may still reference older models in
historical narrative.

### Older releases (kept for cross-reference)

| Model | ID | Replaced by | Notes |
|-------|----|-------------|-------|
| Opus 4.6 | `claude-opus-4-6` | Opus 4.7 | 1M context introduced; superseded by 4.7 |
| Sonnet 4.5 | `claude-sonnet-4-5` | Sonnet 4.6 | — |
| Haiku 4 | `claude-haiku-4` | Haiku 4.5 | — |

---

## Plan tiers (Claude.ai / Claude Code)

The plan a user is on shifts the line for what's affordable on routine work.
`op-onboard` Q1 asks which plan; `chapters/personalization/19f-subscription-aware.md`
maps the answer to per-lever recommendations.

| Plan | Approximate cost | What it gets you | Notes |
|------|---|---|---|
| **Free** | $0 | claude.ai with daily message + context limits, no Opus | The "I want to try claude-spine on my hobby project" tier |
| **Pro** | ~$20/mo | Mostly Sonnet, occasional Opus, more usage | Most spine users land here |
| **Max (5×)** | ~$100/mo | More usage, real Opus access for non-trivial work | The first tier where defaulting to Opus on hard work isn't reckless |
| **Max (20×)** | ~$200/mo | Heavy usage, Opus most of the time, 1M-context Opus | What the spine's "Max 20×" branches assume |
| **Team** | per-seat | Pro-class usage for a workspace | Default to **Pro** behavior unless `Cost sensitivity` says otherwise |
| **Enterprise** | negotiated | Custom limits, SSO, retention controls | Default to **Max 5×** behavior unless cost-aware |
| **API / pay-as-you-go** | per-token | Direct API spend, no fixed plan | Behavior depends entirely on `Cost sensitivity` — Pro-class budget if "Very careful", Max-class if "Don't worry about it" |
| **Bedrock / Vertex / OpenRouter** | per-token via cloud | Same models, billed via cloud provider | Treat like API for cost purposes |
| **Self-hosted via gateway** | varies | Some proxies / gateways front the API | Behavior matches API |

**Tier-name volatility.** Anthropic ships new plans regularly — "Max 5×" /
"Max 20×" naming may change. When that happens, edit *this* table plus the
mapping in `subscription-tune.md`'s tune table; the rest of the spine
references plans by their canonical name as listed here.

---

## Runtime constants (intentionally pinned, may lag this file)

Scripts and tools that need a default model pin a specific value in source.
These are operationally-bound choices (a benchmark needs to keep its
historical comparison stable; `token-check.py` defaults to a cheap model for
quick estimates) and don't read from this registry. The list below tells a
maintainer where to look when the registry-default changes and the runtime
defaults need to follow:

- `tools/token-check.py` → `DEFAULT_MODEL` (line ~33)
- `benchmarks/tokens/run.sh` → `MODEL=` (line ~31)
- `benchmarks/tokens/README.md` → documented default (line ~58)
- `tests/skill-triggers/README.md` → example command (line ~33)

Mock test data (e.g., `tests/onboard/test-extras-merge.sh`) is allowed to
reference any model ID literally — those are fixtures, not defaults.

---

## How to update this file

1. Edit the **Current model lineup** table when a new model ships.
2. Move retired rows to **Older releases**.
3. Update the **Plan tiers** table when Claude.ai's plan structure changes.
4. Sweep the runtime constants listed above as a follow-up commit — they
   don't have to move in lockstep.
5. Update `chapters/foundations/04a-model-tiers.md` if the table shape there
   diverges from this file (the chapter mirrors this registry; if they
   disagree, the registry wins).
6. Update `chapters/personalization/19f-subscription-aware.md` if a plan
   tier was added/removed.
7. Note the date at the top of this file.

---

## Why a registry instead of inline names

Anthropic ships new models often. Pinning the names in 8+ chapter files
means every model release requires 8+ edits, each of which can be
forgotten. The registry is the one-place edit; chapters and templates read
"see `docs/MODELS.md`" rather than naming a specific ID. The cost is one
indirection; the benefit is no stale model names linger in user-facing
content for months after a release.

This same pattern applies to plan tiers — Anthropic introduces / renames /
retires plan names every few quarters, and a chapter that hard-codes
"Max 20×" date-rots silently when the tier name moves.
