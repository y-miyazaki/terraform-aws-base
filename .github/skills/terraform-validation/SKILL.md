---
name: terraform-validation
description: Terraform configuration validation covering syntax, linting, and security. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

# Terraform Validation

This skill provides guidance for validating Terraform configurations using the comprehensive validation script.

## When to Use This Skill

This skill is applicable for:

- Validating Terraform configuration before committing
- Running comprehensive infrastructure code quality checks
- Ensuring security compliance
- Verifying configuration correctness

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
bash terraform-validation/scripts/validate.sh --verbose --generate-docs
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **`terraform fmt -check`** - Verify code formatting
2. **`terraform validate`** - Validate syntax and internal consistency
3. **`tflint`** - Static analysis and best practice enforcement
4. **`trivy config`** - Security vulnerability scanning

## Validation Requirements

Before considering infrastructure code complete:

- [ ] All validation checks pass
- [ ] Code properly formatted
- [ ] No syntax or configuration errors
- [ ] No security misconfigurations
- [ ] Plan reviewed (if applicable)

## Validation Workflow

1. **Make changes** - Edit Terraform files
2. **Run validation**: `bash terraform-validation/scripts/validate.sh ./path/to/module`
3. **Auto-fix formatting**: `bash terraform-validation/scripts/validate.sh --fix`
4. **Fix other issues** - Address validation, lint, or security errors
5. **Commit** - Only when validation passes

## Reference Documentation

For detailed information:

- **[Individual Commands](reference/individual-commands.md)** - Command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Error resolution
- **[Security Best Practices](reference/security.md)** - Security guidelines
