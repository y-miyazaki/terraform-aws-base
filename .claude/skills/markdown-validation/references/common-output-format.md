# Output Format Specification

Use the following report structure for validation output.

````markdown
# Validation Result: <target>

## Summary

- Status: ✅ PASS | ❌ FAIL
- Tools run: <count>
- Tools passed: <count>
- Tools failed: <count>

## Tool Results

| Tool        | Status                        | Message                                    |
| ----------- | ----------------------------- | ------------------------------------------ |
| <tool-name> | ✅ Pass / ❌ Fail / ⊘ Skipped | OK / <brief error summary> / <skip reason> |

## Error Details

### <Tool Name>

```
<Full command output>
```
````

## Rules

- Report tools in the execution order: markdownlint-cli2 → markdown-link-check. Both run even when the first fails.
- In `## Tool Results`, list both tools; mark a tool that was not installed or had no `.md` files as `⊘ Skipped` with the reason.
- In `## Error Details`, include only failed tools with their full output from the SKILL.md Workflow step 2 re-runs (the script hides markdownlint-cli2 output). Prefix each finding line with its checklist ItemID (for example `MDL-05 docs/guide.md:12 MD022/blanks-around-headings`); when no ItemID maps to the rule, keep the line with its rule ID only.
- If all tools pass: write "All validations passed." in Summary; omit `## Error Details`.
- Status is ❌ FAIL if any tool exits with a non-zero exit code.

## Status Symbols

| Symbol | Meaning | When to Use                                |
| ------ | ------- | ------------------------------------------ |
| ✅     | Pass    | Tool exited 0 (no issues found)            |
| ❌     | Fail    | Tool exited non-zero                       |
| ⊘      | Skipped | Tool not installed or no `.md` files found |
