# 15h — MCP integrations

MCP (Model Context Protocol) servers extend Claude with external capabilities. Some you have loaded; others are worth adding for any serious build setup.

## High-leverage MCPs

Install once globally, benefit on every project. The two browser MCPs below are core for browser-driven work (web apps, marketing sites, anything you'd verify by clicking around); skip them for backend, library, ML, or embedded work and Context7 is the only universal pick.

### Chrome DevTools MCP *(browser-driven projects)*

**Use for:** Claude driving a real Chrome browser — clicking, typing, screenshots, console messages, network requests, performance traces, running JS in page context.

**Killer use case:** Claude testing the frontend himself before declaring done. Walk a flow in a real browser, screenshot the result, read the console — all from inside the conversation.

**Vs Playwright MCP:** overlapping but different emphasis. Chrome DevTools = debugging-first (performance, devtools panels). Playwright = test-automation-first (assertion-friendly, headless). Having both is fine; if picking one for frontend verification, Chrome DevTools wins for solo work where you're driving the browser interactively.

### Context7 *(universal)*

**Use for:** up-to-date library documentation injected on demand. Solves "framework moves faster than Claude's training."

**Killer use case:** before writing code against any third-party library or framework that may have changed since Claude's training cutoff (web frameworks, ORMs, payment SDKs, ML libraries, container tools, anything fast-moving), Claude queries Context7 for the *current* API rather than guessing from training data. Eliminates a class of hallucinations.

**Fit with the "don't invent" rule:** Context7 is the verification mechanism for library APIs.

### Playwright MCP *(browser-driven projects)*

**Use for:** programmatic browser automation, repeated test flows. Complements Chrome DevTools.

## MCPs you may already have

| MCP | Use for |
|---|---|
| `mcp__ide__getDiagnostics` | TS / lint errors from the IDE without a full `tsc` |
| `mcp__claude_ai_Gmail__*` | Drafting emails, search threads |
| `mcp__claude_ai_Google_*` | Calendar, Drive |
| `mcp__plugin_vercel_*` | Vercel auth / deployment flows |

## Cost of leaving MCPs running

Every loaded MCP contributes to session-start tokens. Tool catalogs, descriptions, frontmatter all land in context before you type a prompt. Five MCPs you never use this session still cost tokens.

**Audit periodically** (`claude mcp list` or your client's equivalent). If an MCP hasn't fired in weeks, uninstall — reinstalling takes under a minute when you actually need it.

Heavy MCPs (browser automation with many tools, broad API wrappers) cost more at idle than narrow ones. Stack them only when the unique capability earns the running cost.

## When NOT to install

- Overlaps with an MCP you already have (don't run three browser-automation MCPs).
- It's a wrapper around a single API call you could `fetch` instead.
- Last commit was 6+ months ago.
- You can't articulate the specific use case it unlocks.
- You wouldn't use it weekly. Idle MCPs cost context.

## Installing

- **Official registry:** `github.com/modelcontextprotocol`.
- **Community:** `mcp.so` aggregates third-party MCPs.
- **Verify before installing:** active maintenance, recent commits, non-trivial downloads.
- **Install via `claude mcp add`** for most servers, or edit MCP config directly.

## TL;DR

- Context7 is the universal pick; add Chrome DevTools + Playwright MCPs for any project where you'd verify by clicking around in a browser.
- Idle MCPs cost tokens — audit and uninstall.
- Verify maintenance before installing.
- Don't stack overlapping MCPs.
