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

- Run tools in the execution order of `scripts/validate.sh`: ORD-01 map key order → actionlint → ghalint → zizmor.
- The script stops at the first failing tool (fail-fast). Report the failed tool as ❌ Fail and every later tool as `⊘ Skipped` (reason: earlier tool failed).
- If a required binary (`python3`, `actionlint`, `ghalint`, `zizmor`) is missing, the script stops before any check: set Status ❌ FAIL and name the missing binary in `## Error Details`.
- In `## Tool Results`, list every tool in execution order, including skipped ones.
- In `## Error Details`, include only failed tools with their full output.
- If all tools pass: write "All validations passed." in Summary; omit `## Error Details`.
- Status is ❌ FAIL if any tool exits with a non-zero exit code or the script stops early; ✅ PASS otherwise.

## Status Symbols

| Symbol | Meaning | When to Use                     |
| ------ | ------- | ------------------------------- |
| ✅     | Pass    | Tool exited 0 (no issues found) |
| ❌     | Fail    | Tool exited non-zero            |
| ⊘      | Skipped | Tool did not run; state reason  |
