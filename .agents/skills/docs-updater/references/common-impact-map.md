# Impact Map

How to identify which documentation files are affected by code changes.

## Discovery Strategy

The `detect_changes.sh` script collects changed files and returns all candidate documentation files. The AI agent reads each candidate and the relevant diffs to determine what needs updating.

## Script Output

- `changed_files`: modified/added source files
- `deleted_files`: removed files
- `renamed_files`: old→new path pairs
- `affected_docs`: all markdown files in scope (candidates for review)
- `skip`: true when no documentation update is warranted

## Agent Decision Process

For each candidate document, determine whether it contains:

1. **Dead references** — paths or links to files that were deleted or renamed
2. **Missing entries** — new files that belong in a documented list, table, or nav
3. **Stale paths** — old paths that should reflect renames

If none of the above apply to a candidate document, skip it.

## Search Scope

- Root `*.md`
- `docs/**/*.md`
- Nested `**/README.md` (excluding `.agents/`, `.cursor/`, `.claude/`, `.kiro/`, `.vscode/`, `apm_modules/`)
- `mkdocs.yml` (nav section)

## Match Patterns

| Change type      | What to search for in docs                                   |
| ---------------- | ------------------------------------------------------------ |
| Deleted file     | Path or basename appearing in links, tables, lists           |
| Renamed file     | Old path/name that needs replacing with new                  |
| Added file       | Whether it belongs in an existing catalog (table, list, nav) |
| Added docs/ file | mkdocs.yml nav entry + docs/index.md regeneration            |

## Skip Conditions

Set `skip: true` when:

- Only markdown files changed (no source files) AND no markdown renames/deletions occurred
- Only test files or internal refactoring changed
- Changes are in generated directories (`.agents/`, `.cursor/`, etc.)
