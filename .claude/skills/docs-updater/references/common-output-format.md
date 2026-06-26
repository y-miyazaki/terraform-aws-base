# docs-updater Report Format

```markdown
# docs-updater Result

## Summary
- Status: <updated | skipped | exceeded-scope>
- Files updated: <count>
- Files skipped: <count>

## Changes

| File | Action | Detail |
|------|--------|--------|
| `path/to/doc.md` | Updated | Replaced old workflow path with new |
| `mkdocs.yml` | Updated | Added nav entry under Tutorials |

## Skipped Items
- <count> files: <shared reason>

## Recommendations
- <actionable suggestion if scope was exceeded>
```

## Rules

- If status is `skipped` (no documentation update required), output only Summary with status and a one-line reason.
- If status is `exceeded-scope`, list affected files and recommend docs-creator skill or manual review.
- In Changes table, list only files that were actually modified.
- In Skipped Items, group files by reason (e.g., "52 files: no references to changed paths") — do not enumerate each one.
- Summarize at section level — do not list individual line changes.
