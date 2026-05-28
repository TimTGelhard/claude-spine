#!/usr/bin/env python3
"""
token-check.py — Measure Claude Code token usage for a prompt.

Single-file utility. Stdlib only. Copy anywhere.

Run it inside a directory on a machine where claude-spine is installed at
~/.claude/ to capture spine-on numbers. Copy this file to a different user
(or a fresh machine without ~/.claude/skills/op-*) and run the same prompt
to get the spine-off baseline. The header line in the report tells you
which environment you're in so you don't mix them up.

Requirements: `claude` CLI on PATH, Python 3.8+.

Usage:
  python3 token-check.py "How do I add a skill?"
  python3 token-check.py -n 3 "your prompt"           # repeat 3 times
  python3 token-check.py -f prompts.txt -n 2          # batch from file
  python3 token-check.py --model claude-opus-4-7 "..."
  python3 token-check.py --json "..." > out.json      # machine-readable
"""

from __future__ import annotations

import argparse
import json
import statistics
import subprocess
import sys
import time
from pathlib import Path

DEFAULT_MODEL = "claude-sonnet-4-6"


def detect_env() -> str:
    home = Path.home() / ".claude"
    if not home.exists():
        return "no ~/.claude — fresh environment (spine off)"
    skills = home / "skills"
    op = sorted(skills.glob("op-*")) if skills.exists() else []
    if op:
        return f"claude-spine detected — {len(op)} op-* skills at ~/.claude/skills/ (spine on)"
    if (home / "CLAUDE.md").exists():
        return "~/.claude/CLAUDE.md present, no op-* skills — custom non-spine setup"
    return "~/.claude exists but no CLAUDE.md or op-* skills"


def run_once(prompt: str, model: str, timeout: int) -> dict:
    t0 = time.time()
    try:
        proc = subprocess.run(
            ["claude", "-p", "--output-format", "json", "--model", model, prompt],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except FileNotFoundError:
        return {"ok": False, "error": "`claude` CLI not on PATH — install Claude Code first"}
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": f"timeout after {timeout}s"}

    elapsed = round(time.time() - t0, 2)
    if proc.returncode != 0:
        blob = (proc.stderr or proc.stdout).strip()
        tail = blob.splitlines()[-1][:200] if blob else "(no output)"
        return {"ok": False, "elapsed_s": elapsed, "error": f"exit {proc.returncode}: {tail}"}

    try:
        data = json.loads(proc.stdout)
    except json.JSONDecodeError as e:
        return {"ok": False, "elapsed_s": elapsed, "error": f"bad JSON from claude -p: {e}"}

    # `claude -p --output-format json` puts usage in one of these places
    # depending on CLI version — try each.
    usage = (
        data.get("usage")
        or data.get("message", {}).get("usage")
        or data.get("result", {}).get("usage")
        or {}
    )

    inp = int(usage.get("input_tokens", 0) or 0)
    out = int(usage.get("output_tokens", 0) or 0)
    cw = int(usage.get("cache_creation_input_tokens", 0) or 0)
    cr = int(usage.get("cache_read_input_tokens", 0) or 0)

    return {
        "ok": True,
        "elapsed_s": elapsed,
        "input_tokens": inp,
        "cache_write": cw,
        "cache_read": cr,
        "output_tokens": out,
        "total_input": inp + cw + cr,
    }


def fmt_agg(vals: list[int]) -> str:
    if not vals:
        return "-"
    if len(vals) == 1:
        return f"{vals[0]:,}"
    m = statistics.mean(vals)
    sd = statistics.stdev(vals) if len(vals) > 1 else 0
    return f"{int(round(m)):,} ±{int(round(sd)):,}"


def print_block(prompt: str, runs: list[dict]) -> None:
    label = prompt if len(prompt) <= 70 else prompt[:67] + "..."
    ok = [r for r in runs if r.get("ok")]
    print(f"\n> {label}   ({len(ok)}/{len(runs)} ok)")
    for r in runs:
        if not r.get("ok"):
            print(f"  ! {r.get('error')}")
    if not ok:
        return

    rows = [
        ("input (fresh)", "input_tokens"),
        ("cache write",   "cache_write"),
        ("cache read",    "cache_read"),
        ("output",        "output_tokens"),
        ("total input",   "total_input"),
        ("elapsed",       "elapsed_s"),
    ]
    width = max(len(name) for name, _ in rows)
    for name, key in rows:
        vals = [r[key] for r in ok]
        if key == "elapsed_s":
            avg = statistics.mean(vals)
            spread = f"  ({', '.join(f'{v:.1f}' for v in vals)})" if len(vals) > 1 else ""
            print(f"  {name:<{width}}  {avg:6.2f}s{spread}")
        else:
            print(f"  {name:<{width}}  {fmt_agg(vals)}")


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(
        prog="token-check",
        description="Measure Claude Code token usage for one or more prompts.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python3 token-check.py 'How do I add a skill?'\n"
            "  python3 token-check.py -n 3 'list the active skills'\n"
            "  python3 token-check.py -f prompts.txt -n 2\n"
            "  python3 token-check.py --json 'one-shot' > result.json\n"
        ),
    )
    ap.add_argument("prompt", nargs="?", help="prompt text (or use -f)")
    ap.add_argument("-f", "--file", help="text file with one prompt per line (# starts a comment)")
    ap.add_argument("-n", "--runs", type=int, default=1, help="runs per prompt (default 1)")
    ap.add_argument("-m", "--model", default=DEFAULT_MODEL, help=f"model id (default {DEFAULT_MODEL})")
    ap.add_argument("-t", "--timeout", type=int, default=120, help="per-call timeout in seconds (default 120)")
    ap.add_argument("--json", action="store_true", dest="emit_json", help="emit raw JSON to stdout instead of a table")
    args = ap.parse_args(argv)

    if args.file:
        path = Path(args.file)
        if not path.is_file():
            print(f"file not found: {path}", file=sys.stderr)
            return 2
        prompts = [
            ln.strip()
            for ln in path.read_text().splitlines()
            if ln.strip() and not ln.lstrip().startswith("#")
        ]
        if not prompts:
            print(f"no non-comment lines in {path}", file=sys.stderr)
            return 2
    elif args.prompt:
        prompts = [args.prompt]
    else:
        ap.error("provide a prompt argument or use -f FILE")

    env = detect_env()
    if not args.emit_json:
        print(f"# token-check  model={args.model}  runs={args.runs}  cwd={Path.cwd()}")
        print(f"# env: {env}")

    results: dict[str, list[dict]] = {}
    for prompt in prompts:
        runs = [run_once(prompt, args.model, args.timeout) for _ in range(args.runs)]
        results[prompt] = runs
        if not args.emit_json:
            print_block(prompt, runs)

    # Roll-up totals across all prompts (only when batching)
    if not args.emit_json and len(prompts) > 1:
        ok = [r for runs in results.values() for r in runs if r.get("ok")]
        if ok:
            print("\n# roll-up across all prompts × runs")
            print(f"  prompts        {len(prompts)}")
            print(f"  runs           {len(ok)} ok / {sum(len(r) for r in results.values())} total")
            print(f"  total input    {sum(r['total_input'] for r in ok):,} tokens")
            print(f"  total output   {sum(r['output_tokens'] for r in ok):,} tokens")
            print(f"  total elapsed  {sum(r['elapsed_s'] for r in ok):.1f}s")

    if args.emit_json:
        print(json.dumps(
            {
                "model": args.model,
                "runs_per_prompt": args.runs,
                "cwd": str(Path.cwd()),
                "env": env,
                "results": results,
            },
            indent=2,
        ))

    any_err = any(not r.get("ok") for runs in results.values() for r in runs)
    return 1 if any_err else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
