# Impact Map

Defines the strategy for identifying documentation files affected by code changes.

## Discovery Strategy

The detection script collects changed files and candidate documentation files. The AI agent reads the diff context and determines which documents contain stale references, missing entries, or dead links.

### Script Responsibility

The `detect_changes.sh` script provides:
- `changed_files`: all modified/added source files
- `deleted_files`: removed files
- `renamed_files`: old→new path pairs
- `affected_docs`: candidate documentation files (all markdown in scope)

### Agent Responsibility

The agent reads each candidate document and the relevant diffs to determine:
- Stale references (paths or names that no longer exist)
- Missing entries (new items not yet documented)
- Dead references (links to deleted/renamed files)

### Search Scope

- Root `*.md`
- `README.md`
- `docs/**/*.md`
- `mkdocs.yml` (nav section)

### Match Rules

- Deleted files: search for the deleted path or basename in candidate docs.
- Renamed files: search for old name references that need updating.
- Added files: check if the addition belongs to a documented list/table.
- If no documentation update is warranted, set `skip: true`.
