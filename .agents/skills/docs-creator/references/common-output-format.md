# docs-creator Report Format

```markdown
# docs-creator Result

## Summary

- Status: <created | updated | blocked>
- Files created: <count>
- Files updated: <count>

## Changes

| File                          | Action  | Detail                                  |
| ----------------------------- | ------- | --------------------------------------- |
| `docs/explanation/caching.md` | Created | Architecture overview for caching layer |
| `docs/index.md`               | Updated | Added new entry                         |
| `mkdocs.yml`                  | Updated | Added nav entry under Explanation       |

## Notes

- <any skipped steps or recommendations>
```

## Rules

- If status is `blocked`, explain in `## Notes` what information is needed, or why the request is out of scope (it matches `DO NOT USE FOR` in SKILL.md).
- List every file touched in Changes.
- Summarize at file level, not line level.
