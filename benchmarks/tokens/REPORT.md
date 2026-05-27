# Token-efficiency benchmark — REPORT

_Not run yet. See [`README.md`](README.md) for how to generate this report._

After `./run.sh && python3 aggregate.py`, this file will contain:

- per-prompt comparison table (spine-off vs spine-on input/output token means)
- totals row + delta %
- per-condition variance (stddev across runs)
- cache_creation vs cache_read per prompt
- _What this doesn't measure_ caveats section
