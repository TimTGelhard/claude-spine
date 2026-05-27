# 15a — File operations

## Read

**Use for:** any file Claude needs to see. Always preferred over `cat` via Bash.

**Discipline:**

- Big files: pass `offset` and `limit` to read only the relevant range.
- Logs > 1000 lines: don't load whole — `grep` first, then `Read` the relevant section.
- Generated / lockfiles (`package-lock.json`): almost never. Read `package.json` instead.

**Anti-pattern:** "Let me read the file to understand the project" — for one file, fine. For ten files at the start of a session, you've burned a third of your context before doing any work.

## Edit

**Use for:** modifying existing files. The default for code changes.

**Rules:**

- Always `Read` the file first (the tool enforces this).
- Match exact strings including indentation. Failed `Edit`s mean the string isn't unique or doesn't match.
- For multiple changes to the same file, prefer multiple `Edit` calls over one giant rewrite.
- For renaming a symbol everywhere in a file: `replace_all: true`.

**Anti-pattern:** using `Write` to "rewrite the whole file" when only a few lines change. Wastes tokens, harder to review.

## Write

**Use for:** creating new files, or genuine full rewrites (>50% changed).

**Anti-pattern:** writing a "fresh" version of a file you could have edited. Loses git blame, harder to review.

## NotebookEdit

**Use for:** Jupyter notebooks (`.ipynb`). Don't `Edit` notebooks — the JSON structure breaks.

## Choosing between them

| Situation | Tool |
|---|---|
| Reading any file | `Read` |
| Changing one or a few sections of a file | `Edit` |
| Creating a new file | `Write` |
| Replacing >50% of a file | `Write` |
| Modifying `.ipynb` | `NotebookEdit` |
| Anything in Bash like `cat`/`sed`/`echo >>` | Almost never — use the dedicated tool |

## TL;DR

- `Read` first, `Edit` to modify, `Write` only for new files or full rewrites.
- Pass `offset`/`limit` for big files; `replace_all` for symbol renames.
- Never `cat`/`sed`/`echo >` what you can do with `Read`/`Edit`/`Write`.
