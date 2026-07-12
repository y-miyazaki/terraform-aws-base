# docs-creator Report Format

```markdown
# docs-creator Result

## Summary

- Status: <created | updated | blocked>
- Files created: <count>
- Files updated: <count>

## Changes

| File                          | Action      | Detail                                  |
| ----------------------------- | ----------- | --------------------------------------- |
| `docs/explanation/caching.md` | Created     | Architecture overview for caching layer |
| `docs/index.md`               | Regenerated | Added new entry                         |
| `mkdocs.yml`                  | Updated     | Added nav entry under Explanation       |

## Notes

- <any skipped steps or recommendations>
```

## Rules

- If status is `blocked`, explain what information is needed.
- List every file touched in Changes.
- Summarize at file level, not line level.
