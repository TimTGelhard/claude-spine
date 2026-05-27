#!/usr/bin/env python3
"""Aggregate per-skill eval JSON files into a Markdown report.

Reads tests/skill-triggers/results/op-*.json (produced by run.sh) and writes:
  - REPORT.md       overview table
  - needs-tightening.md   detail for skills failing the FP<20% / TP>80% bar
"""

import argparse
import json
from pathlib import Path


def compute_rates(result: dict) -> dict:
    rs = result["results"]
    pos = [r for r in rs if r["should_trigger"]]
    neg = [r for r in rs if not r["should_trigger"]]
    tp = sum(1 for r in pos if r["pass"])
    tn = sum(1 for r in neg if r["pass"])
    return {
        "tp": tp,
        "fn": len(pos) - tp,
        "tn": tn,
        "fp": len(neg) - tn,
        "n_pos": len(pos),
        "n_neg": len(neg),
        "tp_rate": tp / len(pos) if pos else 0.0,
        "fp_rate": (len(neg) - tn) / len(neg) if neg else 0.0,
    }


def needs_tightening(r: dict) -> bool:
    return r["fp_rate"] > 0.20 or r["tp_rate"] < 0.80


def truncate(s: str, n: int) -> str:
    return s if len(s) <= n else s[: n - 3] + "..."


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", default=None,
                        help="default: tests/skill-triggers/results next to this script")
    parser.add_argument("--report", default=None,
                        help="default: <results-dir>/REPORT.md")
    parser.add_argument("--needs-tightening", default=None,
                        help="default: <results-dir>/needs-tightening.md")
    args = parser.parse_args()

    here = Path(__file__).resolve().parent
    results_dir = Path(args.results_dir) if args.results_dir else here / "results"
    report_path = Path(args.report) if args.report else results_dir / "REPORT.md"
    needs_path = Path(args.needs_tightening) if args.needs_tightening else results_dir / "needs-tightening.md"

    rows = []
    for f in sorted(results_dir.glob("op-*.json")):
        try:
            raw = json.loads(f.read_text())
        except json.JSONDecodeError:
            print(f"warn: skipping malformed {f.name}")
            continue
        rates = compute_rates(raw)
        rows.append((raw["skill_name"], rates, raw))

    if not rows:
        print(f"No results found in {results_dir}. Run run.sh first.")
        return

    rows.sort(key=lambda x: (x[1]["tp_rate"], -x[1]["fp_rate"]))

    out = [
        "# Skill-trigger benchmark report",
        "",
        f"_{len(rows)} skills. Tightening threshold: FP > 20% or TP < 80%._",
        "",
        "| Skill | TP rate | FP rate | TP / FN | TN / FP | Flag |",
        "|---|---|---|---|---|---|",
    ]
    for name, r, _ in rows:
        flag = "**tighten**" if needs_tightening(r) else "ok"
        out.append(
            f"| `{name}` | {r['tp_rate']*100:.0f}% ({r['tp']}/{r['n_pos']}) | "
            f"{r['fp_rate']*100:.0f}% ({r['fp']}/{r['n_neg']}) | "
            f"{r['tp']} / {r['fn']} | {r['tn']} / {r['fp']} | {flag} |"
        )
    report_path.write_text("\n".join(out) + "\n")
    print(f"report:    {report_path}")

    flagged = [(n, r, raw) for n, r, raw in rows if needs_tightening(r)]
    if flagged:
        det = [
            "# Skills needing description tightening",
            "",
            "_Threshold: FP rate > 20% or TP rate < 80%. Tightening is out of scope for L4a — see launch.md._",
            "",
        ]
        for name, r, raw in flagged:
            det.append(f"## `{name}`")
            det.append("")
            det.append(f"- TP rate: {r['tp_rate']*100:.0f}% ({r['tp']}/{r['n_pos']})")
            det.append(f"- FP rate: {r['fp_rate']*100:.0f}% ({r['fp']}/{r['n_neg']})")
            det.append("")
            failures = [q for q in raw["results"] if not q["pass"]]
            if failures:
                det.append("**Failures:**")
                for q in failures:
                    expected = "fire" if q["should_trigger"] else "no-fire"
                    actual = f"{q['triggers']}/{q['runs']}"
                    det.append(f"- _expected {expected}_, fired {actual}: \"{truncate(q['query'], 140)}\"")
                det.append("")
        needs_path.write_text("\n".join(det) + "\n")
        print(f"tighten:   {needs_path}")
    else:
        needs_path.write_text(
            "# Skills needing description tightening\n\n"
            "None — every skill cleared FP < 20% and TP > 80%.\n"
        )
        print("tighten:   none flagged")


if __name__ == "__main__":
    main()
