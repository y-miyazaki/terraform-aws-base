# Output Format

Use the following report structure for Terraform validation output.

```markdown
# Terraform Validation Result

## Checks

- <ToolName> <CheckName>: ❌ Fail

## Issues

1. <ToolName>: <CheckName>
   - File: `<path>` L<line>
   - Problem: <specific issue>
   - Impact: <scope and severity>
   - Recommendation: <specific fix>
```

## Rules

- Include only failed checks in `## Checks`.
- Use numbered items in `## Issues`.
- Include these fields for each issue: `ToolName`, `File`, `Problem`, `Impact`, `Recommendation`.
- If there are no issues, output `No issues found` in the `## Issues` section.
