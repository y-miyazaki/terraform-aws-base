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

- Run order of `scripts/validate.sh`: for each discovered script, shebang/permission checks → bash -n → shellcheck → function doc and function order checks (only with `--check-function-docs`); then the Bats suites (unless `--skip-tests`).
- The script continues after a failing script or check (no fail-fast). Report every check that ran, then set the overall status from all of them.
- Report a check that did not run as `⊘ Skipped` with the reason (for example function doc checks without `--check-function-docs`, or Bats with `--skip-tests`).
- If a required binary (`shellcheck`, `shfmt`, or `bats`/`bats-core` when Bats runs) is missing, the script stops before any check: set Status ❌ FAIL and name the missing binary in `## Error Details`.
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
