# Output Format

Use the following report structure for shell script code review output.

```markdown
# Shell Script Code Review Result

## Checks

- <ItemID> <ItemName>: ❌ Fail

## Issues

1. <ItemID>: <ItemName>
   - File: `<path>` L<line>
   - Problem: <specific issue>
   - Impact: <scope and severity>
   - Recommendation: <specific fix with code example>
```

## Rules

- Include only failed checks in `## Checks`.
- Use numbered items in `## Issues`.
- Include these fields for each issue: `ItemID`, `File`, `Problem`, `Impact`, `Recommendation`.
- If there are no issues, output `No issues found` in the `## Issues` section.
