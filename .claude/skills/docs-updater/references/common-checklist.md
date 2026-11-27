# docs-updater Checklist

General documentation maintenance checks. Automation-path report shape and edit gates live in [category-automation-envelope.md](category-automation-envelope.md) — load only when the prompt includes `## Constraints`.

## Update Validation

### UV-01: Structure Preserved

- [ ] No sections reordered or added; a section is rewritten or removed only under UV-07 (factual fix) or UV-09 (deleted feature)
- [ ] No headings changed (level or text)
- [ ] Table column format unchanged
- [ ] List ordering style unchanged (alphabetical, grouped, chronological)
- **PASS** if document structure is identical except for added/removed/updated entries and the UV-07/UV-09 edits

### UV-02: References Accurate

- [ ] All file paths in updated docs point to files that exist
- [ ] Renamed files have all old-path references replaced with new path
- [ ] Deleted files have all references removed (no dead links remain)
- [ ] Cross-references use relative paths with `.md` extension
- **PASS** if no dead or incorrect references remain

### UV-03: Entries Correctly Placed

- [ ] New table rows follow existing column format
- [ ] New list items placed at position consistent with existing sort order
- [ ] Site nav entries placed in the correct documentation section when the repo uses structured nav (for example Diataxis quadrants in `mkdocs.yml`)
- **PASS** if placement is consistent with surrounding entries

### UV-04: Scope Respected

- [ ] No file has >3 H2 sections modified
- [ ] No single-file diff >500 lines processed
- [ ] No prose rewritten beyond the wrong statement: a factual fix (UV-07) changes one sentence or table row, plus the adjacent sentence only when it names or depends on the changed fact
- [ ] Exceeded-scope files, and docs that need a new section or an explanation of new behavior, reported as handed off to a documentation authoring workflow (for example docs-creator)
- **PASS** if all updates are minimal patches, not rewrites

### UV-05: index.md Consistency

Only when the repository already maintains a generated documentation index (for example `docs/index.md`); skip this gate otherwise:

- [ ] If documentation files were added, deleted, or renamed: the index entry added, removed, or updated in the existing structure
- [ ] If no documentation file changes: the index untouched
- [ ] Index ordering, section layout, and description style follow the existing index (do not introduce a new structure)
- [ ] Empty section headings omitted
- **PASS** if the index accurately reflects current documentation contents

### UV-06: Canonical Source and Deduplication

When updating docs that describe architecture, APIs, or cross-cutting behavior:

- [ ] Read [category-documentation-maintenance.md](category-documentation-maintenance.md) — link to canonical docs; do not duplicate content in secondary files
- [ ] One topic → one canonical doc; no duplicate diagrams or tables for the same topic
- [ ] Consumer maintainer guides under `docs/` consulted when present
- [ ] Site nav updated when adding or renaming documented pages
- **PASS** if docs link to a single canonical source per topic and contain no contradictory duplicates

### UV-07: Claims Verified Against Source

Documentation that is wrong is worse than documentation that is missing. For every doc in the impact map (see [common-impact-map.md](common-impact-map.md)):

- [ ] Each statement, table row, example, and command the change touches was re-read against the current source (code, config, script, or the file it names) — not only its path
- [ ] A fix states the source location it was checked against (file and line) in the report evidence
- [ ] A statement that cannot be checked (no source, ambiguous source) is reported under Watch, not patched
- **PASS** if every patched or kept statement in the impact map matches the source it describes

### UV-08: No Orphaned References

- [ ] After patching, every old name, path, flag, environment variable, and input name in the symbol map was searched across all candidate docs
- [ ] No remaining occurrence is left unless it is deliberately historical (for example a changelog entry or a dated plan) and is listed in the report
- **PASS** if the search finds no unlisted occurrence

### UV-09: Deletions and Renames Handled by Intent

- [ ] A deleted feature's section is removed, replaced with the successor's description, or marked deprecated — chosen by what the surrounding text needs, not by blanket removal of the matching line
- [ ] A renamed symbol's explanatory sentence still reads correctly after the name changes
- **PASS** if no dangling sentence or empty section remains

## Rationalizations to Reject

| Rationalization                                      | Why it is wrong                                                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| "The change is small, so docs probably need no edit" | One changed signature or default changes the contract for every reader; map it regardless of diff size |
| "I fixed the main reference, the rest can wait"      | Orphaned mentions mislead readers and agents; UV-08 requires the full search                           |
| "I will write what I think the code does"            | UV-07 requires reading the source; an unverified statement goes to Watch                               |
| "The doc style is inconsistent, I will tidy it too"  | This skill restores accuracy only; style changes belong to a separate authoring change                 |
| "Verifying every doc is too costly"                  | Cost is not a reason to skip; delegate the reading (see [common-impact-map.md](common-impact-map.md))  |
