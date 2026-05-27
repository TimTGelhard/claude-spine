# 03a — Hard limits: what Claude genuinely can't do reliably

These don't get better with a smarter prompt. They're structural. Plan around them.

## 1. Hold a giant project coherently in one session

Even with 1M context, multi-week projects don't fit in one session — and they shouldn't. Quality degrades regardless of window size when there are too many decisions to keep consistent. Project = many sessions. See [06-feature-sizing.md](../../06-feature-sizing.md).

## 2. Know what's in your installed package versions

Frameworks move fast. Claude's training has a cutoff. Even with recent knowledge updates, version-specific syntax (Next.js 16 specifics, library APIs that changed last month) is *guessed* if Claude doesn't check. Always have it verify against actual installed code when it's uncertain — and call it out when something "feels confident but might be made up."

## 3. See your running app

Claude can't open your browser, click buttons, or interact with your live UI by itself (without specific tools like Playwright MCP). For UI verification: *you* run the dev server and walk it, or you set up an MCP that lets Claude drive a browser. Otherwise Claude is flying blind.

## 4. Know what your users actually do

Claude can guess at user flows. It can't validate them. UX decisions need real users, not Claude's intuition.

## 5. Recall earlier-session decisions perfectly

After compaction or in a new terminal, fine-grained decisions get lost. The only durable memory is files: `CLAUDE.md`, `ARCHITECTURE.md`, `DECISIONS.md`. If a decision isn't written down, assume next session won't know about it.

## 6. Do creative product strategy

Claude is solid at executing a defined product. It's mediocre at deciding what to build, what to charge for, who the user is. Those are your job. Stage 0 in [05-workflow.md](../../05-workflow.md).

## 7. Match your taste without examples

"Make it modern" or "make it clean" gets generic, AI-default aesthetics. To get your taste, show examples (real apps, references, your existing brand) or set very specific design constraints. See [10-visuals.md](../../10-visuals.md).

## Related

- Soft limits — things Claude can do, but unreliably: [03b-soft-limits.md](03b-soft-limits.md)
- Project-type fit and warning signs: [03c-project-fit.md](03c-project-fit.md)
