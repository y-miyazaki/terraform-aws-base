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

- Run tools in the execution order of `scripts/validate.sh`: tflint → terraform validate → terraform fmt → argument order (ORD-01, only with `--check-order`) → trivy (`trivy fs <target> --format table`).
- The script continues after a failing tool (no fail-fast). Report every tool that ran, then set the overall status from all of them.
- Report a check that did not run as `⊘ Skipped` with the reason (for example argument order without `--check-order`, or `--check-order` failing with `can't open file` because the `terraform_attr_order.py` helper is not bundled — that is not an ORD-01 violation).
- The trivy step exits 0 even when it prints findings. List its findings in the trivy row's Message (and `## Error Details` when HIGH/CRITICAL) without changing Status for that reason.
- If a required binary (`terraform`, `tflint`, `trivy`; `python3` with `--check-order`; `terraform-docs` with `--generate-docs`) is missing, the script stops before any check: set Status ❌ FAIL and name the missing binary in `## Error Details`.
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
