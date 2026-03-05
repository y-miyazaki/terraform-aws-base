# Output Format

Use the following report structure for Diagram as Code validation output.

```markdown
# Diagram as Code Validation Result

## Checks

- <ToolName> <CheckName>: ❌ Fail

## Issues

1. <ToolName>: <CheckName>
   - File: `<path>` L<line> (if applicable)
   - Problem: <specific issue>
   - Impact: <scope and severity>
   - Recommendation: <specific fix with example>
```

## Rules

- Include only failed checks in `## Checks`.
- Use numbered items in `## Issues`.
- Include these fields for each issue: `ToolName`, `File` (if applicable), `Problem`, `Impact`, `Recommendation`.
- If there are no issues, output `No issues found` in the `## Issues` section.
