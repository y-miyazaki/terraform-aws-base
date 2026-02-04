---
name: shell-script-validation
description: Shell script validation covering syntax and static analysis. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

# Shell Script Validation

This skill provides guidance for validating shell scripts using the comprehensive validation script.

## When to Use This Skill

This skill is applicable for:

- Validating shell script before committing
- Running comprehensive script quality checks
- Ensuring syntax correctness
- Verifying best practice compliance

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

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

The validation script performs all checks in the correct order:

1. **`bash -n`** - Syntax check without execution
2. **`shellcheck`** - Comprehensive static analysis and best practice enforcement
3. **Project standards** - Verify script template compliance

## Validation Requirements

Before considering scripts complete:

- [ ] All validation checks pass
- [ ] No syntax errors
- [ ] No shellcheck warnings
- [ ] Follows project script standards
- [ ] Bats tests pass (if applicable)

## Validation Workflow

1. **Make changes** - Edit shell scripts
2. **Run validation**: `bash shell-script-validation/scripts/validate.sh ./script.sh`
3. **Fix issues** - Address any failures
4. **Run tests**: `bats test/*.bats` (if applicable)
5. **Commit** - Only when all checks pass

## Reference Documentation

For detailed information:

- **[Individual Commands](reference/individual-commands.md)** - Command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Error resolution
- **[Script Standards](reference/standards.md)** - Project template and conventions
