#!/usr/bin/env python3
"""Aggregate results/results.jsonl from the token-efficiency benchmark into REPORT.md.

Reads:
  - eval-set.json (the prompt list, for ordering / category)
  - results/results.jsonl (one JSON object per call, written by run.sh)

Writes:
  - REPORT.md

Safe to re-run; idempotent. If the JSONL is partial (e.g., a run was Ctrl-C'd),
the report is also partial — that's the point.
"""

from __future__ import annotations

import json
import statistics
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
EVAL_SET = SCRIPT_DIR / "eval-set.json"
SUMMARY = SCRIPT_DIR / "results" / "results.jsonl"
REPORT = SCRIPT_DIR / "REPORT.md"


def load_eval() -> list[dict[str, Any]]:
    return json.loads(EVAL_SET.read_text())["prompts"]


def load_calls() -> dict[tuple[str, str], list[dict[str, Any]]]:
    """Returns {(prompt_id, cond): [call_record, ...]}."""
    by_key: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    if not SUMMARY.exists():
        return by_key
    for line in SUMMARY.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        if row.get("dry_run"):
            continue
        if not row.get("ok"):
            # Still record it so the count is accurate; aggregate skips fields.
            row.setdefault("input_tokens", 0)
            row.setdefault("output_tokens", 0)
            row.setdefault("cache_creation_input_tokens", 0)
            row.setdefault("cache_read_input_tokens", 0)
            row.setdefault("total_cost_usd", 0.0)
        by_key[(row["id"], row["cond"])].append(row)
    return by_key


def mean(xs: list[float]) -> float:
    xs = [x for x in xs if x is not None]
    return statistics.mean(xs) if xs else 0.0


def stdev(xs: list[float]) -> float:
    xs = [x for x in xs if x is not None]
    return statistics.stdev(xs) if len(xs) > 1 else 0.0


def total_input(call: dict[str, Any]) -> float:
    """Total inbound tokens — fresh + cache write + cache read.

    The API charges all three (at different rates). For a 'how much context did
    this prompt actually carry' answer, this is the right summation. The split
    appears separately in the cache table.
    """
    return (
        call.get("input_tokens", 0)
        + call.get("cache_creation_input_tokens", 0)
        + call.get("cache_read_input_tokens", 0)
    )


def fmt_pct(new: float, old: float) -> str:
    if old == 0:
        return "—" if new == 0 else "n/a"
    return f"{(new - old) / old * 100:+.1f}%"


def render() -> None:
    prompts = load_eval()
    calls = load_calls()

    rows: list[dict[str, Any]] = []
    totals: dict[str, dict[str, float]] = {"off": defaultdict(float), "on": defaultdict(float)}
    counts: dict[str, int] = {"off": 0, "on": 0}

    for p in prompts:
        pid = p["id"]
        cat = p["category"]
        off = [c for c in calls.get((pid, "off"), []) if c.get("ok")]
        on = [c for c in calls.get((pid, "on"), []) if c.get("ok")]

        if not off and not on:
            rows.append({"id": pid, "category": cat, "skipped": True})
            continue

        off_in = [total_input(c) for c in off]
        on_in = [total_input(c) for c in on]
        off_out = [c["output_tokens"] for c in off]
        on_out = [c["output_tokens"] for c in on]
        off_cost = [c["total_cost_usd"] for c in off]
        on_cost = [c["total_cost_usd"] for c in on]

        rows.append({
            "id": pid,
            "category": cat,
            "skipped": False,
            "off_in_mean": mean(off_in),
            "on_in_mean": mean(on_in),
            "delta_in": mean(on_in) - mean(off_in),
            "delta_pct": fmt_pct(mean(on_in), mean(off_in)),
            "off_out_mean": mean(off_out),
            "on_out_mean": mean(on_out),
            "off_cost_mean": mean(off_cost),
            "on_cost_mean": mean(on_cost),
            "delta_cost": mean(on_cost) - mean(off_cost),
            "off_n": len(off),
            "on_n": len(on),
            "off_std_in": stdev(off_in),
            "on_std_in": stdev(on_in),
            "off_cc": mean([c["cache_creation_input_tokens"] for c in off]),
            "on_cc": mean([c["cache_creation_input_tokens"] for c in on]),
            "off_cr": mean([c["cache_read_input_tokens"] for c in off]),
            "on_cr": mean([c["cache_read_input_tokens"] for c in on]),
        })

        for c in off:
            totals["off"]["input"] += total_input(c)
            totals["off"]["output"] += c["output_tokens"]
            totals["off"]["cost"] += c["total_cost_usd"]
            counts["off"] += 1
        for c in on:
            totals["on"]["input"] += total_input(c)
            totals["on"]["output"] += c["output_tokens"]
            totals["on"]["cost"] += c["total_cost_usd"]
            counts["on"] += 1

    lines: list[str] = []
    lines.append("# Token-efficiency benchmark — REPORT")
    lines.append("")
    if counts["off"] == 0 and counts["on"] == 0:
        lines.append("_Not run yet. See [`README.md`](README.md) for how to generate this report._")
        lines.append("")
        lines.append("After `./run.sh && python3 aggregate.py`, this file will contain:")
        lines.append("")
        lines.append("- per-prompt comparison table (spine-off vs spine-on input/output token means)")
        lines.append("- totals row + delta %")
        lines.append("- per-condition variance (stddev across runs)")
        lines.append("- cache_creation vs cache_read per prompt")
        lines.append("- _What this doesn't measure_ caveats section")
        REPORT.write_text("\n".join(lines) + "\n")
        print(f"Wrote {REPORT} (empty — no results yet).")
        return

    models_used = sorted({c["model"] for cs in calls.values() for c in cs if c.get("model")})
    lines.append(
        f"_{counts['off']} spine-off + {counts['on']} spine-on calls. "
        f"Model(s): {', '.join(models_used) if models_used else 'unknown'}._"
    )
    lines.append("")

    # Per-prompt comparison.
    lines.append("## Per-prompt comparison")
    lines.append("")
    lines.append("| id | category | spine-off in | spine-on in | Δ in | Δ % | Δ cost (USD) |")
    lines.append("|---|---|---:|---:|---:|---:|---:|")
    for r in rows:
        if r.get("skipped"):
            lines.append(f"| `{r['id']}` | {r['category']} | — | — | — | — | — |")
            continue
        lines.append(
            f"| `{r['id']}` | {r['category']} "
            f"| {r['off_in_mean']:.0f} | {r['on_in_mean']:.0f} "
            f"| {r['delta_in']:+.0f} | {r['delta_pct']} "
            f"| {r['delta_cost']:+.4f} |"
        )

    # Totals.
    lines.append("")
    lines.append("## Totals")
    lines.append("")
    lines.append("| | spine-off | spine-on | Δ | Δ % |")
    lines.append("|---|---:|---:|---:|---:|")
    off_in_tot = totals["off"]["input"]
    on_in_tot = totals["on"]["input"]
    lines.append(
        f"| input tokens (sum) | {off_in_tot:.0f} | {on_in_tot:.0f} "
        f"| {on_in_tot - off_in_tot:+.0f} | {fmt_pct(on_in_tot, off_in_tot)} |"
    )
    off_out_tot = totals["off"]["output"]
    on_out_tot = totals["on"]["output"]
    lines.append(
        f"| output tokens (sum) | {off_out_tot:.0f} | {on_out_tot:.0f} "
        f"| {on_out_tot - off_out_tot:+.0f} | {fmt_pct(on_out_tot, off_out_tot)} |"
    )
    off_cost_tot = totals["off"]["cost"]
    on_cost_tot = totals["on"]["cost"]
    lines.append(
        f"| cost USD (sum) | {off_cost_tot:.4f} | {on_cost_tot:.4f} "
        f"| {on_cost_tot - off_cost_tot:+.4f} | {fmt_pct(on_cost_tot, off_cost_tot)} |"
    )

    # Variance.
    lines.append("")
    lines.append("## Per-condition variance")
    lines.append("")
    lines.append(
        "Standard deviation of total input tokens across runs. Large σ relative "
        "to the mean signals noisy measurement (e.g., cache_creation only firing "
        "on the first run of a batch). Quote means with this context."
    )
    lines.append("")
    lines.append("| id | spine-off n | spine-off σ in | spine-on n | spine-on σ in |")
    lines.append("|---|---:|---:|---:|---:|")
    for r in rows:
        if r.get("skipped"):
            continue
        lines.append(
            f"| `{r['id']}` | {r['off_n']} | {r['off_std_in']:.0f} "
            f"| {r['on_n']} | {r['on_std_in']:.0f} |"
        )

    # Cache hit detail.
    lines.append("")
    lines.append("## Cache creation vs read (per condition, per prompt)")
    lines.append("")
    lines.append(
        "`cc` = `cache_creation_input_tokens` (cold write to cache). "
        "`cr` = `cache_read_input_tokens` (warm hit, ~10% of fresh-input price). "
        "Compare 'spine-on cr' (steady state) against 'spine-off cc + cr' to see "
        "the realistic per-call delta after the cache is warm."
    )
    lines.append("")
    lines.append("| id | spine-off cc | spine-off cr | spine-on cc | spine-on cr |")
    lines.append("|---|---:|---:|---:|---:|")
    for r in rows:
        if r.get("skipped"):
            continue
        lines.append(
            f"| `{r['id']}` | {r['off_cc']:.0f} | {r['off_cr']:.0f} "
            f"| {r['on_cc']:.0f} | {r['on_cr']:.0f} |"
        )

    # Honesty section.
    lines.append("")
    lines.append("## What this doesn't measure")
    lines.append("")
    lines.append(
        "- **Single-shot `claude -p` undercounts routing-skill triggering.** "
        "The harness measures input-context cost — how much the spine adds to "
        "every fresh `claude -p` call. It does **not** capture whether skills "
        "fire on the right queries; for that, see "
        "[`tests/skill-triggers/README.md`](../../tests/skill-triggers/README.md). "
        "A spine that loads cheaply *and* routes accurately is doing its job; "
        "this benchmark only confirms the per-call input footprint is sane."
    )
    lines.append("")
    lines.append(
        "- **Multi-turn compounding value is not captured.** "
        "In an interactive Claude Code session, the spine's per-turn cost is "
        "amortized across many turns of context. A single `claude -p` invocation "
        "loads the same context fresh every time. Real-world per-turn cost is "
        "lower than these single-shot numbers suggest."
    )
    lines.append("")
    lines.append(
        "- **Cache hit rates differ between conditions.** "
        "Spine-on prompts share a large prefix (CLAUDE.md + skill manifest), so "
        "after the first call in a batch the cache reads dominate (`cr` high, "
        "`cc` near 0). Spine-off has no such prefix. The 'Cache creation vs "
        "read' table above is the per-prompt evidence for this; the first "
        "spine-on call in each batch carries the cold-cache cost."
    )
    lines.append("")
    lines.append(
        "- **Cost is the proxy, tokens are the truth.** "
        "Sonnet 4.6 / Opus 4.7 / Haiku 4.5 weight input vs output vs cache "
        "tokens differently. Use the Δ tokens and Δ cost columns together — if "
        "cost diverges from token movement, the model assumption changed."
    )
    lines.append("")

    REPORT.write_text("\n".join(lines) + "\n")
    print(f"Wrote {REPORT}")


if __name__ == "__main__":
    try:
        render()
    except FileNotFoundError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
