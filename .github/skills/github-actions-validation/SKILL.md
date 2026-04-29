---
name: github-actions-validation
description: >-
  Validates GitHub Actions workflows for syntax, security, and best practices using actionlint,
  ghalint, and zizmor. Use when committing workflow changes, running CI validation, or checking
  workflow files for security issues.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- GitHub Actions workflow YAML file(s) in `.github/workflows/` (required)
- Validation script: `github-actions-validation/scripts/validate.sh` (required)
- Optional: specific directory path

## Output Specification

Structured validation results from three tools: actionlint → ghalint → zizmor.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes all tools in recommended order with proper configuration
- Individual tool commands available for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md))
- **Do not review workflow design decisions** (use github-actions-review for that)

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when validation fails with unexpected errors
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging a specific tool (actionlint/ghalint/zizmor)

**Category Details** (read when investigating specific failures):

- [category-security.md](references/category-security.md) - Read when zizmor or ghalint reports security issues

## Workflow

**Always use the validation script. Do not run individual commands.**

```bash
# Run all validations (recommended before commit)
bash github-actions-validation/scripts/validate.sh

# Validate specific directory
bash github-actions-validation/scripts/validate.sh ./.github/workflows/
```

### What the Script Does

1. **actionlint** - Workflow syntax and best practices validation
2. **ghalint** - Security and configuration validation
3. **zizmor** - GitHub Actions security scanner

## Output Format

```
✓ actionlint: No issues found
✓ ghalint: No issues found
✓ zizmor: No issues found
All validations passed
```

## Best Practices

- Run validation before every workflow commit
- All checks must pass before considering changes complete
