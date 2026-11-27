# Impact Map

How to identify which documentation files are affected by code changes.

## Discovery Strategy

The skill's detect script collects changed files and returns all candidate documentation files. The AI agent reads each candidate and the relevant diffs to determine what needs updating.

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
4. **Stale claims** — statements, table rows, examples, or commands that no longer match the source they describe (names, defaults, flags, inputs, outputs, behavior)

If none of the above apply to a candidate document, skip it.

## Symbol Map

Build the map from the diff before searching docs, so a rename or removal is searched by every name it had:

1. For each changed source file, list changed public symbols as `(old → new)` pairs: functions and CLI flags, environment variables, config keys, workflow or action inputs and outputs, file paths, and default values. Removed symbols have no new name.
2. List changed documented behavior too (retry counts, ordering, conditions, outputs) even with no rename. If the diff changes no symbol, path, default, or documented behavior (internal refactor only), the code side has no documentation impact; stop for that file.
3. Search every candidate doc for each old name (and each changed default), not only for the path.
4. After patching, repeat the search for orphans (UV-08 in [common-checklist.md](common-checklist.md)).

## Impact Map Output

Keep a working list of `doc:line → source:line → verdict` (match, stale, unverifiable). The report's `Target` cell carries the doc path and line (`<linked path>` with the line number); the evidence cell names the source location checked.

## Baseline

When no `--since` is given for a change-driven run, resolve the diff baseline in this order:

1. On a feature branch: the merge base with the base branch.
2. On the base branch itself: the last commit that touched documentation (`git log --diff-filter=AMR -1 -- '*.md'`), skipping commits that change no documentation text, such as commits that only append to a run log or other generated file (for example marked `[skip ci]`); use the last five commits when none exists. If the resulting diff is empty, widen to the last five commits before concluding no-op.
3. Otherwise the user's stated range.

Report the resolved baseline in Overview.

## Delegating the Reading

Reading many docs against many sources is heavy. When the impact map has 6 or more docs (always for `all`), delegate the read-and-compare to a subagent per documentation group (at most 20 docs per group and at most 5 groups in parallel; queue the rest), passing the symbol map and the doc list, and have it return the `doc:line → source:line → verdict` rows only. The main run spot-checks at least one `match` verdict per group against the source before trusting it, then applies or reports the verdicts. When no subagent tool exists, process the groups sequentially and say so in Overview.

## Related Docs

- Docs that describe the same files or symbols as an affected doc (same path or name appears in both) are candidates for the same fix; list them in the report as "also touch?" and patch them only when they pass UV-07.
- When a code-graph or code-search tool is available, use it to find which docs reference a changed symbol; otherwise use text search. This is an optimization, not a prerequisite.

## Search Scope

- Root `*.md`
- `docs/**/*.md`
- Nested `**/README.md` (excluding generated or tool-installed directories, as identified by repository conventions)
- `mkdocs.yml` (nav section)

## Match Patterns

| Change type               | What to search for in docs                                                                                                                                                  |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Deleted file              | Path or basename appearing in links, tables, lists                                                                                                                          |
| Renamed file              | Old path/name that needs replacing with new                                                                                                                                 |
| Added file                | Whether it belongs in an existing catalog (table, list, nav)                                                                                                                |
| Added docs/ file          | Site nav entry + documentation index entry when the repository maintains them (UV-05)                                                                                       |
| Config / interface change | Apply canonical-source rule per [category-documentation-maintenance.md](category-documentation-maintenance.md); check consumer maintainer guides under `docs/` when present |

## Skip Conditions

Applies to `staged` and `range` scope only (change-driven runs). Under `all` (Interactive free-form), survey every candidate document regardless of what changed.

Set `skip: true` when:

- Only markdown files changed (no source files) AND no markdown renames/deletions occurred
- Only test files or internal refactoring changed
- Changes are only in generated or tool-installed directories (as identified by repository conventions)
