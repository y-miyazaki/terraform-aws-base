---
name: github-actions-validation
description: GitHub Actions workflow validation covering syntax, security, and best practices using actionlint, ghalint, and zizmor. Always use validate.sh script for comprehensive validation. For troubleshooting, see reference/.
license: MIT
---

## Purpose

Validates GitHub Actions workflows for syntax errors, security issues, and best practice violations using actionlint, ghalint, and zizmor.

This skill provides guidance for validating GitHub Actions workflows to ensure correctness, security, and best practices.

## When to Use This Skill

Recommended usage:

- Before committing workflow changes
- During pull request validation in CI/CD
- After editing any workflow file
- When debugging workflow syntax errors
- For security compliance verification

## Input Specification

This skill expects:

- GitHub Actions workflow YAML file(s) (required) - Files in `.github/workflows/` directory
- Validation script (required) - `github-actions-validation/scripts/validate.sh`
- Optional directory path (optional) - Specific directory to validate

Format:

- Workflow files: Valid YAML files with `.yml` or `.yaml` extension
- Directory path: Relative or absolute path to workflow directory
- Default: Validates all files in `.github/workflows/` if no path specified

## Output Specification

Structured validation results from three tools:

- actionlint output: Syntax errors, best practice violations with file paths and line numbers
- ghalint output: Security and configuration issues with severity levels
- zizmor output: Security vulnerabilities with risk assessments

Success output format:

```
✓ actionlint: No issues found
✓ ghalint: No issues found
✓ zizmor: No issues found
All validations passed
```

Error output format:

```
✗ actionlint: [file]:[line]:[col]: [error message]
✗ ghalint: [severity] [rule]: [description]
✗ zizmor: [risk level] [finding]: [details]
Exit code: 1
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes actionlint, ghalint, and zizmor in recommended order with proper configuration
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Validate workflow YAML syntax using actionlint
- Check security settings and configurations using ghalint
- Scan for security vulnerabilities using zizmor
- Verify timeout configurations
- Check permissions settings
- Validate best practices compliance

What this skill does NOT do (Out of Scope):

- Modify workflow files automatically
- Execute workflows for testing
- Fix validation errors automatically
- Review workflow design decisions (use github-actions-review for that)
- Validate non-workflow YAML files
- Check workflow execution logs
- Approve or merge pull requests

## Constraints

Prerequisites:

- actionlint installed and available in PATH
- ghalint installed and available in PATH
- zizmor installed and available in PATH
- Workflow files must be in `.github/workflows/` directory or specified path
- Validation script must be executable

Limitations:

- Only validates syntax and static analysis, not runtime behavior
- Cannot detect logic errors in workflow execution
- Security scanning limited to known patterns
- Requires all three tools to be installed for complete validation

## Failure Behavior

Error handling:

- Tool not found: Output error message indicating which tool is missing, exit with code 1
- Syntax error: actionlint outputs specific error with file, line, and column, exit with code 1
- Security issue: ghalint/zizmor output severity and description, exit with code 1
- Invalid file path: Output error message about inaccessible path, exit with code 1
- Multiple errors: Report all errors from all tools before exiting

Error reporting format:

- Each tool outputs errors to standard error
- Exit code: 0=success, 1=validation failed
- Error messages include file paths, line numbers, and specific issues
- Detailed troubleshooting available in reference/troubleshooting.md

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Overall validation workflow checklist
- **common-output-format.md** - Validation result output format definition
- **common-troubleshooting.md** - Common errors and solutions
- **common-individual-commands.md** - Detailed individual command usage

**Category Details**:

- **category-security.md** - Security best practices and guidelines

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

```bash
# Run all validations (recommended before commit)
bash github-actions-validation/scripts/validate.sh

# Validate specific directory
bash github-actions-validation/scripts/validate.sh ./.github/workflows/
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **actionlint** - Workflow syntax and best practices validation
2. **ghalint** - Security and configuration validation
3. **zizmor** - GitHub Actions security scanner

## Validation Requirements

Before committing workflow changes:

- [ ] Validation script passes
- [ ] All syntax errors resolved
- [ ] Security warnings addressed
- [ ] Timeout settings configured
- [ ] Permissions minimized

## Workflow

1. **Make changes** - Edit workflow files
2. **Run validation**: `bash github-actions-validation/scripts/validate.sh`
3. **Fix issues** - Address any failures
4. **Re-run validation** - Ensure all checks pass
5. **Commit** - Only when validation succeeds
