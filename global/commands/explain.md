---
argument-hint: "simple | standard | detailed"
description: Set how simply Claude explains its work — /explain simple|standard|detailed. Writes the Explanation style field in your profile and applies it immediately. Like /effort, but for output clarity instead of reasoning effort.
---

# /explain — set explanation simplicity

A dial for how plainly Claude explains what it changed and why. Three levels:

| Level | What you get |
|---|---|
| `simple` | Plain language, minimal jargon. After a change: *what* changed and *why* in a line or two. Technical detail only when you ask. |
| `standard` | Balanced — clear explanations, neither stripped down nor exhaustive. The shipped default. |
| `detailed` | Full technical depth — trade-offs, rationale, and alternatives spelled out. |

This is the user-facing front door to the **Explanation style** profile field. It is a different axis from **Answer length** (how much text) and **Reasoning depth** (how much of the reasoning is shown) — this one controls *register and plainness*.

## What to do

### 1. Parse the argument

The user invoked `/explain $ARGUMENTS`. Trim and lowercase `$ARGUMENTS`.

- **Empty `$ARGUMENTS`** → status check. Read the current **Explanation style** from `~/.claude/claude-spine-profile.md`, print it plus the three options in one short block, and stop. Write nothing.
- **`simple` | `standard` | `detailed`** → go to step 2.
- **Anything else** → print `Unknown level "$ARGUMENTS". Use: simple | standard | detailed.` and stop. Write nothing.

### 2. Write the profile field

Open `~/.claude/claude-spine-profile.md`. Under the `## Output format` heading, find the line beginning `- **Explanation style:**`.

- **If it exists** → replace that whole line with the canonical line for the chosen level (below).
- **If it is missing** (older profile created before this field) → insert the canonical line as the first bullet directly under `## Output format`.
- **If the profile file does not exist at all** → tell the user to run `/onboard` first; do not create a partial file.

Then bump the `> Last updated:` line to today's date (from session context).

Canonical lines:

- simple → `- **Explanation style:** Simple — plain language, minimal jargon; say what changed and why in a line or two. Technical detail only when asked.`
- standard → `- **Explanation style:** Standard — balanced explanations; clear but not exhaustive.`
- detailed → `- **Explanation style:** Detailed — full technical depth; trade-offs and rationale spelled out.`

### 3. Apply it now

Do not wait for the next session. Adopt the chosen style for the rest of *this* conversation immediately. Profile fields are normally read only at session start, so the write alone would not take effect until next launch — applying it in-session is what makes this feel like `/effort`.

### 4. Confirm in one line

E.g. `Explanation style → Simple. Saved to your profile; applies from here.` No preamble, no recap.

## Hard rules

1. **Profile-only write.** This command touches exactly one file: `~/.claude/claude-spine-profile.md`. Never `chapters/`, `skills/core/`, or any spine source.
2. **One field.** Only the **Explanation style** line (plus the `Last updated:` stamp). Leave Answer length, Reasoning depth, and everything else alone — they are separate dials.
3. **Persist + apply by default.** Always do both: write the profile (sticks across sessions) and adopt immediately (this session). If the user explicitly asks for a one-off ("just this session"), apply without writing.
