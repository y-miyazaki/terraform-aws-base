---
name: terraform-validation
description: >-
  Validates Terraform configurations for syntax, linting, and security using terraform fmt,
  terraform validate, tflint, and trivy. Use when committing Terraform changes, running CI
  validation, or checking infrastructure code for security vulnerabilities.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Terraform files (`.tf`) in current directory or specified path (required)
- Validation script: `terraform-validation/scripts/validate.sh` (required)
- Optional: directory path(s), `--fix` for auto-formatting, `--verbose` for detailed output

## Output Specification

Structured validation results from four tools in execution order: terraform fmt → terraform validate → tflint → trivy config.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes all tools in recommended order with proper configuration
- Individual tool commands available for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md))
- **Do not review code design decisions** (use terraform-review for that)

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when validation fails with unexpected errors
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging a specific tool (terraform fmt/validate/tflint/trivy)

**Category Details** (read when investigating specific failures):

- [category-security.md](references/category-security.md) - Read when trivy reports security vulnerabilities

## Workflow

**Always use the validation script. Do not run individual commands.**

```bash
# Full workspace validation (scans all Terraform directories)
bash terraform-validation/scripts/validate.sh

# Scope validation to specific directories (faster feedback)
bash terraform-validation/scripts/validate.sh ./terraform/base/ ./terraform/application/

# Automatically fix formatting issues
bash terraform-validation/scripts/validate.sh --fix

# With verbose output
bash terraform-validation/scripts/validate.sh --verbose
```

### What the Script Does

1. **`terraform fmt -check`** - Verify code formatting
2. **`terraform validate`** - Validate syntax and internal consistency
3. **`tflint`** - Static analysis and best practice enforcement
4. **`trivy config`** - Security vulnerability scanning

## Output Format

```
✓ terraform fmt: All files formatted
✓ terraform validate: Configuration valid
✓ tflint: No issues found
✓ trivy config: No vulnerabilities found
All validations passed
```

## Best Practices

- Run full validation before every commit
- Use `--fix` to auto-correct formatting issues
- Scope to specific directories for faster feedback during development
- All checks must pass before considering changes complete
