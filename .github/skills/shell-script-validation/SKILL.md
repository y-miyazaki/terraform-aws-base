---
name: shell-script-validation
description: Shell script validation covering syntax and static analysis. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

## Purpose

Validates shell scripts for syntax correctness and static analysis issues using bash syntax checking and shellcheck.

Comprehensive validation for shell scripts using automated tools for syntax checking and static analysis.

## When to Use This Skill

Recommended usage:

- Before committing shell script changes
- During pull request validation
- Before deploying scripts to production
- On every shell script modification
- In pre-commit hooks and CI/CD pipelines

## Input Specification

This skill expects:

- Shell script files (required) - `.sh` files in current directory or specified path
- Validation script (required) - `shell-script-validation/scripts/validate.sh`
- Optional directory path (optional) - Specific shell script directories to validate
- Optional flags (optional) - `-v` for verbose output, `-f` for auto-fix

Format:

- Shell files: Valid bash syntax with `.sh` extension
- Directory path: Relative or absolute path to script directory
- Flags: `-v` or `-f` as command-line arguments
- Default: Validates all shell scripts in current directory if no path specified

## Output Specification

Structured validation results from three checks in execution order:

- bash -n output: Syntax check results
- shellcheck output: Static analysis issues with file paths and line numbers
- Project standards output: Script template compliance check results

Success output format:

```
✓ bash -n: Syntax valid
✓ shellcheck: No issues found
✓ Project standards: Compliant
All validations passed
```

Error output format:

```
✗ bash -n: [file]: syntax error at line X
✗ shellcheck: [file]:[line]: [code]: [issue]
✗ Project standards: [issue description]
Exit code: 1
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes bash -n and shellcheck in recommended order with proper configuration
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Verify shell script syntax using bash -n
- Perform static analysis using shellcheck
- Verify script template compliance with project standards
- Auto-fix formatting issues when `-f` flag is provided
- Display verbose output with detailed check information on request

What this skill does NOT do (Out of Scope):

- Review code design decisions (use shell-script-review for that)
- Execute shell scripts or validate runtime behavior
- Fix issues automatically (except formatting with -f flag)
- Approve or merge pull requests
- Validate non-shell script files
- Deploy or run production scripts

## Constraints

Prerequisites:

- bash installed and available in PATH
- shellcheck installed and available in PATH
- Shell scripts must have valid bash syntax
- bats installed (for test execution, optional)

Limitations:

- Validation focuses on syntax and static analysis
- Cannot validate actual script execution or runtime behavior
- Formatting auto-fix only applies to bash syntax issues
- Large script collections (>100 files) may have longer validation times

## Failure Behavior

Error handling:

- Syntax errors: bash -n reports issues with line numbers
- Shellcheck violations: shellcheck outputs issues with severity levels
- Standards violations: Project standards checker outputs specific violations
- Script execution error: Output error details and exit code 1
- Format issues: shellcheck may auto-fix with `-f` flag, otherwise reports

Error reporting format:

- Standard error output with specific error messages
- Exit code: 0=success, 1=error
- File paths and line numbers included for all issues
- Error details available in reference/troubleshooting.md

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Overall validation workflow checklist
- **common-output-format.md** - Validation result output format definition
- **common-troubleshooting.md** - Common errors and solutions
- **common-individual-commands.md** - Detailed individual command usage

**Category Details**:

- **category-standards.md** - Project templates and coding conventions

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

## Workflow

1. **Make changes** - Edit shell scripts
2. **Run validation**: `bash shell-script-validation/scripts/validate.sh ./script.sh`
3. **Fix issues** - Address any failures
4. **Run tests**: `bats test/*.bats` (if applicable)
5. **Commit** - Only when all checks pass
