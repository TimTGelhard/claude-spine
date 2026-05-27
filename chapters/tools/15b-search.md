# 15b — Search: grep, find, and Explore

## Bash with grep / rg / find

**Use for:** quick lookups when you know roughly what you're searching for.

**Patterns:**

```bash
# Find every place that imports from a module
grep -r "from '@/lib/db'" --include="*.ts" --include="*.tsx" app/

# Find files matching a pattern
find . -name "*.test.ts" -not -path "*/node_modules/*"

# Search for a function definition
grep -rn "export function actionCreateQuote" .
```

**Why grep wins for one-shots:** instant, cheap, you see the matches. No latency.

**Don't:** `find /` — scans the whole filesystem. Always anchor with `.` or a specific path.

## Agent (Explore)

**Use for:** open-ended "where is X" / "what files reference Y" when you'd need multiple greps.

**Cost trade:** ~10–30 seconds of latency, but returns a 1–2K summary instead of dumping all matches into your context. Worth it when the search would produce a lot of noise.

**Anti-pattern:** spawning Explore for a single file lookup. Just `find`.

## Choosing between them

| Situation | Use |
|---|---|
| Know the exact symbol or string | `grep` |
| One specific file → look it up | `find` |
| "Where do we call the Stripe API?" — multiple greps needed | `Agent (Explore)` |
| "Where is `foo` defined?" — one grep does it | `grep` |
| "What's the auth pattern in this codebase?" — many files, fuzzy | `Agent (Explore)` |

## Searching big logs

Don't `Read` a 5000-line log. Pattern:

1. `grep` for error keywords to find candidate lines.
2. `Read` with `offset` + `limit` to get the relevant window.
3. If you need more structure, an `Agent (Explore)` or `general-purpose` can summarize the whole log.

## TL;DR

- One-shot search → `grep` via Bash.
- Open-ended / multi-grep search → `Agent (Explore)`.
- Big log: grep first, then targeted `Read` with offset/limit.
