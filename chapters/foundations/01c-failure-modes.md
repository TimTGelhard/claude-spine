# 01c — Three failure modes

When output quality drops, it's almost always one of these three. Knowing *which* is happening tells you what to fix.

## Drift

Claude forgets earlier decisions and contradicts them.

**Cause:** long session, context filled with noise, compaction has fired.

**Fix:** fresh terminal, explicit re-state of constraints, write decisions to `DECISIONS.md` so they survive sessions.

## Dilution

Claude has the relevant info in context but can't focus on it through the noise.

**Cause:** loaded too much, attention spread thin. Often after dumping multiple big files.

**Fix:** don't load the whole project. Load the slice. Use subagents for exploration.

## Hallucination

Claude confidently invents file paths, function names, library APIs, version-specific syntax.

**Cause:** trained-knowledge cutoff + confident generation. Worst on recent framework changes.

**Fix:** verify before accepting. Have Claude check that a function exists. Cross-reference with `package.json` versions. Catch confident wrong answers before they become commits.

## Diagnose, then fix

| Symptom | Failure mode | Fix |
|---|---|---|
| Re-suggesting something we ruled out earlier | Drift | Restart, re-state constraint upfront |
| Same misunderstanding twice in one session | Drift | Restart |
| Right info loaded, wrong answer | Dilution | Trim context, re-focus |
| Confident reference to a file you haven't loaded | Hallucination | Verify the specific claim |
| Version-specific syntax you can't confirm | Hallucination | Check `package.json` and source |

## Recognize failure early

Two corrections of the same misunderstanding = restart. Hallucinated file path = verify everything else from this session. Diff is bigger than the change should be = stop and read it line by line.

The cost of a fresh terminal is small. The cost of letting drift compound is hours of bad code.

## Where this connects

- Recovery moves and the full triage table: [recovery playbook](../recovery/17a-failure-triage.md).
- Context-filling signals (the proxy for "you're heading into drift territory"): [context signals](../signaling/11a-context-signals.md).
