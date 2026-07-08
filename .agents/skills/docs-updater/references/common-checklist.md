# docs-updater Checklist

## Update Validation

### UV-01: Structure Preserved

- [ ] No sections reordered, rewritten, or added
- [ ] No headings changed (level or text)
- [ ] Table column format unchanged
- [ ] List ordering style unchanged (alphabetical, grouped, chronological)
- **PASS** if document structure is identical except for added/removed/updated entries

### UV-02: References Accurate

- [ ] All file paths in updated docs point to files that exist
- [ ] Renamed files have all old-path references replaced with new path
- [ ] Deleted files have all references removed (no dead links remain)
- [ ] Cross-references use relative paths with `.md` extension
- **PASS** if no dead or incorrect references remain

### UV-03: Entries Correctly Placed

- [ ] New table rows follow existing column format
- [ ] New list items placed at position consistent with existing sort order
- [ ] mkdocs.yml nav entries placed in correct Diataxis quadrant
- **PASS** if placement is consistent with surrounding entries

### UV-04: Scope Respected

- [ ] No file has >3 H2 sections modified
- [ ] No single-file diff >500 lines processed
- [ ] No prose rewritten (only paths, names, entries updated)
- [ ] Exceeded-scope files reported with recommendation
- **PASS** if all updates are minimal patches, not rewrites

### UV-05: index.md Consistency

- [ ] If docs/ files were added, deleted, or renamed: `docs/index.md` regenerated
- [ ] If no docs/ file changes: `docs/index.md` untouched
- [ ] index.md lists files alphabetically within each Diataxis section
- [ ] Empty quadrant sections omitted
- **PASS** if index.md accurately reflects current docs/ contents

## docs/index.md Generation Template

When regenerating `docs/index.md`, use this structure:

```markdown
# Documentation Index

Directory layout follows [Diataxis](https://diataxis.fr/).

## Tutorials

_Learning-oriented walkthroughs._

- [filename.md](tutorials/filename.md) - One-line description

## How-To

_Task-oriented guides for specific goals._

- [filename.md](how-to/filename.md) - One-line description

## Reference

_Information-oriented technical descriptions._

- [filename.md](reference/filename.md) - One-line description

## Explanation

_Understanding-oriented discussion of concepts and decisions._

- [filename.md](explanation/filename.md) - One-line description
```

Rules:
- Omit empty quadrant sections (no placeholder text for missing categories)
- List files alphabetically within each section
- Description is the document's H1 title or first sentence of purpose paragraph
- Non-Diataxis directories (e.g., `agents/`, `report/`) get their own H2 section after the four quadrants
