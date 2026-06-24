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
| `path/to/doc.md` | Updated | Added new-feature entry to table |
| `path/to/other.md` | Skipped | Changes exceed diff-sync scope |

## Skipped Items
- <file>: <reason>

## Recommendations
- <actionable suggestion if scope was exceeded>
```

## Rules

- If status is `skipped` (no documentation update required), output only Summary with status and a one-line reason.
- If status is `exceeded-scope`, list affected files and the recommendation.
- List every file examined in Changes, even if skipped.
- Do not list individual line changes — summarize at section level.
