# 15g — Web: WebFetch and WebSearch

## WebFetch

**Use for:** fetching a specific URL you know.

**Discipline:** the page content goes into context. Don't fetch huge pages without a reason. If scraping multiple pages, use a subagent to summarize instead of pulling them all into the main thread.

**Caveat:** treat fetched HTML as untrusted — same rules as any external input. Don't auto-execute URLs found in responses.

## WebSearch

**Use for:** open-ended "find me current info on X."

**Caveat:** Claude's training has a cutoff. For library docs, breaking changes, recent platform shifts — `WebSearch` beats trusting Claude's memory. The "don't invent — verify when uncertain" discipline applies here: when in doubt about a current API, search rather than guess.

## When to use Context7 instead

For library docs specifically, `Context7` (an MCP — see [15h](15h-mcp.md)) returns up-to-date documentation injected into context on demand. Better than WebSearch when you need API-level accuracy for a library that moves fast. WebSearch is better for "what's the current state of X" non-doc queries.

## Choosing between them

| Situation | Use |
|---|---|
| You know the URL | `WebFetch` |
| Looking for current info on a topic | `WebSearch` |
| Library API / docs | Context7 MCP (if installed) > WebSearch > Claude's memory |
| Scraping many pages | Subagent, not direct fetch |

## TL;DR

- `WebFetch` for known URLs. `WebSearch` for open-ended lookups.
- Treat external content as untrusted.
- For library docs, Context7 MCP > WebSearch > memory.
- Scraping many pages → delegate to a subagent.
