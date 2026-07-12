---
name: terraform-validation
description: >-
  Validate Terraform syntax, linting, and security with terraform fmt/validate, tflint, and trivy.
  Use when committing Terraform changes, running CI validation, or checking IaC security issues.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Terraform path or directory (required)
- Validation script: `scripts/validate.sh` (required, run from the terraform-validation skill directory)
- Optional flags: `--fix`, `--verbose`

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured results in fixed order: terraform fmt, terraform validate, tflint, trivy config.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script runs all checks in deterministic order.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- **Do not review code design decisions** (use terraform-review for that)

### USE FOR:

- run Terraform syntax/lint/security checks before commit
- reproduce CI validation failures locally
- validate a scoped Terraform directory during iterative changes

### DO NOT USE FOR:

- perform design and architecture review (use terraform-review)
- implement Terraform resource changes as a primary task
- validate non-Terraform files

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when checks fail unexpectedly.
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging one tool directly.
- [category-security.md](references/category-security.md) - Read when trivy reports security findings.

## Workflow

1. Run `bash scripts/validate.sh`.
2. For scoped runs, pass a target directory: `bash scripts/validate.sh ./terraform/<target>/`.
3. Use `--fix` for formatting corrections and `--verbose` for diagnostics.
4. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Examples

```bash
bash scripts/validate.sh
bash scripts/validate.sh ./terraform/base/
bash scripts/validate.sh --fix --verbose
```
