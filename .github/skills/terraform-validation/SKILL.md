---
name: terraform-validation
description: Terraform configuration validation covering syntax, linting, and security. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

## Purpose

Validates Terraform configurations for syntax errors, linting violations, and security issues using terraform fmt, terraform validate, tflint, and trivy.

Comprehensive validation for Terraform configurations using automated tools for syntax checking, linting, and security scanning.

## When to Use This Skill

Recommended usage:

- Before committing Terraform changes
- During pull request validation
- Before applying infrastructure changes
- On every terraform file modification
- In pre-commit hooks and CI/CD pipelines

## Input Specification

This skill expects:

- Terraform files (required) - `.tf` files in current directory or specified path
- Validation script (required) - `terraform-validation/scripts/validate.sh`
- Optional directory path (optional) - Specific Terraform directories to validate
- Optional flags (optional) - `--fix` for auto-formatting, `--verbose` for detailed output

Format:

- Terraform files: Valid HCL syntax with `.tf` extension
- Directory path: Relative or absolute path to Terraform directory
- Flags: `--fix` or `--verbose` as command-line arguments
- Default: Validates all Terraform files in current directory if no path specified

## Output Specification

Structured validation results from four tools in execution order:

- terraform fmt output: Formatting issues or confirmation
- terraform validate output: Syntax and internal consistency check results
- tflint output: Linting issues with file paths and line numbers
- trivy config output: Security vulnerabilities with severity levels

Success output format:

```
✓ terraform fmt: All files formatted
✓ terraform validate: Configuration valid
✓ tflint: No issues found
✓ trivy config: No vulnerabilities found
All validations passed
```

Error output format:

```
✗ terraform fmt: [file]: formatting required
✗ terraform validate: [error description]
✗ tflint: [file]:[line]: [issue]
✗ trivy config: [file]: [vulnerability]
Exit code: 1
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes terraform fmt, terraform validate, tflint, and trivy config in recommended order
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Verify Terraform code formatting using terraform fmt
- Validate syntax and configuration consistency using terraform validate
- Run static analysis and best practice checks using tflint
- Scan for security vulnerabilities using trivy config
- Auto-fix formatting issues when `--fix` flag is provided
- Display verbose output with detailed check information on request

What this skill does NOT do (Out of Scope):

- Review code design decisions (use terraform-review for that)
- Execute terraform plan or apply
- Fix non-formatting issues automatically
- Validate AWS resource configurations beyond Terraform syntax
- Approve or merge pull requests
- Validate non-Terraform files
- Deploy infrastructure

## Constraints

Prerequisites:

- Terraform CLI installed and available in PATH
- tflint installed and available in PATH
- trivy installed and available in PATH
- Terraform files must have valid HCL syntax
- AWS-based Terraform (other providers may require tool adjustments)

Limitations:

- Validation focuses on syntax, linting, and security scanning
- Cannot validate actual AWS resource creation or state
- Formatting auto-fix only applies to terraform fmt issues
- Large workspaces (>100 modules) may have longer validation times

## Failure Behavior

Error handling:

- Formatting errors: terraform fmt reports issues, use `--fix` to auto-correct
- Syntax errors: terraform validate outputs error message with file path and line number
- Linting failures: tflint reports violations with severity level, exit without auto-fix
- Security issues: trivy config outputs vulnerabilities with CVE/recommendation details
- Script execution error: Output error details and exit code 1

Error reporting format:

- Standard error output with specific error messages
- Exit code: 0=success, 1=error
- File paths and line numbers included for all issues
- Error details available in reference/troubleshooting.md

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Terraform validation checklist
- **common-output-format.md** - Validation result report format specification
- **common-troubleshooting.md** - Troubleshooting guide
- **common-individual-commands.md** - Individual command execution (terraform fmt/validate/tflint/trivy)

**Category Details**:

- **category-security.md** - Security validation guide

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

```bash
# Full workspace validation (scans all Terraform directories)
bash terraform-validation/scripts/validate.sh

# Scope validation to specific directories (faster feedback)
bash terraform-validation/scripts/validate.sh ./terraform/base/ ./terraform/application/

# Automatically fix formatting issues
bash terraform-validation/scripts/validate.sh --fix

# Generate documentation while validating
bash terraform-validation/scripts/validate.sh --verbose
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **`terraform fmt -check`** - Verify code formatting
2. **`terraform validate`** - Validate syntax and internal consistency
3. **`tflint`** - Static analysis and best practice enforcement
4. **`trivy config`** - Security vulnerability scanning

## Validation Requirements

Before committing Terraform changes:

- [ ] All formatting issues resolved (terraform fmt passes)
- [ ] Syntax and configuration valid (terraform validate passes)
- [ ] No linting violations (tflint passes)
- [ ] No security vulnerabilities (trivy config passes)
- [ ] Module variables documented
- [ ] State files excluded from version control

## Workflow

1. **Make changes** - Edit Terraform files
2. **Run validation**: `bash terraform-validation/scripts/validate.sh ./path/to/module`
3. **Auto-fix formatting**: `bash terraform-validation/scripts/validate.sh --fix`
4. **Fix other issues** - Address validation, lint, or security errors
5. **Commit** - Only when validation passes
