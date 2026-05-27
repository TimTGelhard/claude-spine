# Contributing

claude-spine is a single-maintainer, opinionated repo. The discipline encoded here reflects how *one operator* works. That shapes what fits and what doesn't.

## What's welcome

- **Factual corrections** — outdated Claude Code mechanics, wrong API names, broken examples.
- **Broken links** — internal cross-references that don't resolve, or external URLs that 404.
- **Install issues** — `install.sh` failures on Linux distros, macOS versions, or shell setups other than the maintainer's.
- **Typos and dead prose.**
- **New atomic chapters** for genuinely missing concepts — open an issue first to talk through the seam before writing.

## What's unlikely to land

- **Large reframes** of the operating discipline. The chapters reflect lived practice; sweeping rewrites without that grounding rarely land.
- **New top-level folders** or architectural pieces. The 5-layer structure (core skills → bucket → INDEX → atomic chapters → templates → global) is intentional.
- **Stack-specific advice** in core chapters. Use the plugin ecosystem (Vercel, Next.js, Supabase, etc.) for that.
- **Bucket contributions.** The bucket is *personal* by design — see [README — Personalization](README.md#personalization). There's no sharing mechanism baked in.

## How to propose a change

1. Open an issue describing the problem and the proposed fix. For small changes (typos, broken links), a PR direct is fine.
2. Fork, branch from `main`, make the change.
3. **Verify locally** before opening the PR:
   - `./install.sh --dry-run` — installer doesn't break.
   - If you touched a skill: confirm body stays under the 65-line cap (`wc -l skills/core/op-*/SKILL.md`).
   - If you touched a chapter: confirm it stays under the 150-line cap.
   - Run the README verify queries in a fresh Claude Code session.
4. Open the PR with a one-paragraph summary: what changed, why, and what you verified.

## Commit style

Imperative, present tense, lowercase. Phase tag when relevant.

```
fix: broken cross-link in 13a-skill-anatomy.md
chapter: add 15j-mcp-stdio-vs-http to tools/
install: handle Linux musl libc edge case
```

No marketing language. No "successfully" in the past tense — the diff is the proof.

## License

By contributing, you agree your changes ship under the [MIT license](LICENSE).
