---
name: shell-script-validation
description: >-
  Validates shell scripts for syntax correctness and static analysis issues using bash -n and
  shellcheck. Use when committing shell script changes, running CI validation, or debugging
  shellcheck warnings in bash scripts.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Shell script files (`.sh`) in current directory or specified path (required)
- Validation script: `shell-script-validation/scripts/validate.sh` (required)
- Optional: directory path, `-v` for verbose output, `-f` for auto-fix

## Output Specification

Structured validation results from three checks: bash -n → shellcheck → project standards.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes all tools in recommended order with proper configuration
- Individual tool commands available for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md))
- **Do not review code design decisions** (use shell-script-review for that)

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when validation fails with unexpected errors
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging a specific tool (bash -n/shellcheck)

**Category Details** (read when investigating specific failures):

- [category-standards.md](references/category-standards.md) - Read when project template or coding convention violations are reported

## Workflow

**Always use the validation script. Do not run individual commands.**

```bash
# Run all validations in the workspace
bash shell-script-validation/scripts/validate.sh

# Validate a specific directory
bash shell-script-validation/scripts/validate.sh ./scripts/new_feature/

# Validate a specific script
bash shell-script-validation/scripts/validate.sh ./scripts/deploy.sh

# With verbose output and auto-fix
bash shell-script-validation/scripts/validate.sh -v -f
```

### What the Script Does

1. **`bash -n`** - Syntax check without execution
2. **`shellcheck`** - Comprehensive static analysis and best practice enforcement
3. **Project standards** - Verify script template compliance

## Output Format

```
✓ bash -n: Syntax valid
✓ shellcheck: No issues found
✓ Project standards: Compliant
All validations passed
```

## Best Practices

- Run validation before every commit
- Use `-f` to auto-fix formatting issues
- Run bats tests separately if applicable: `bats test/*.bats`
- All checks must pass before considering scripts complete
