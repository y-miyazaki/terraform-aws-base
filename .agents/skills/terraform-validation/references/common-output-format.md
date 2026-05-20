# Output Format Specification

Use the following report structure for validation output.

```markdown
# Validation Result: <target>

## Summary
- Status: ✅ PASS | ❌ FAIL
- Tools run: <count>
- Tools passed: <count>
- Tools failed: <count>

## Tool Results

| Tool        | Status          | Message                    |
| ----------- | --------------- | -------------------------- |
| <tool-name> | ✅ Pass / ❌ Fail | OK / <brief error summary> |

## Error Details

### <Tool Name>
```
<Full command output>
```
```

## Rules

- Run tools in the execution order: terraform fmt → terraform validate → tflint → trivy config
- Stop execution on the first tool failure (fail-fast).
- In `## Tool Results`, list only tools that were actually run.
- In `## Error Details`, include only failed tools with their full output.
- If all tools pass: write "All validations passed." in Summary; omit `## Error Details`.
- Status is ❌ FAIL if any tool exits with a non-zero exit code.

## Status Symbols

| Symbol | Meaning | When to Use                     |
| ------ | ------- | ------------------------------- |
| ✅      | Pass    | Tool exited 0 (no issues found) |
| ❌      | Fail    | Tool exited non-zero            |
