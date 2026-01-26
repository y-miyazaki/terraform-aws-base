---
name: terraform-validation
description: Use terraform-validation/scripts/validate.sh for Terraform validation. This skill provides the validation workflow and troubleshooting guidance. Individual commands are for debugging only.
license: MIT
---

# Terraform Validation

This skill provides guidance for validating Terraform configurations to ensure code quality, security, and correctness before applying infrastructure changes.

## When to Use This Skill

This skill is applicable for:

- Validating Terraform configuration syntax
- Running security scans on infrastructure code
- Checking Terraform formatting
- Verifying configuration before `terraform apply`
- Ensuring compliance with Terraform best practices
- Debugging validation failures

## Validation Commands

### ⚠️ Required: Use the Validation Script

**Always use the comprehensive validation script.** This is the primary and recommended method for all validation tasks. Individual commands should only be used for debugging specific failures.

Run the comprehensive validation script before committing Terraform code. This script automatically handles formatting checks, configuration validation, linting, and security scanning.

```bash
# 1. Full workspace validation (scans all Terraform directories)
bash terraform-validation/scripts/validate.sh

# 2. Scope validation to specific directories (faster feedback)
bash terraform-validation/scripts/validate.sh ./terraform/base/ ./terraform/application/

# 3. Automatically fix formatting issues
bash terraform-validation/scripts/validate.sh --verbose --fix

# 4. Generate documentation while validating
bash terraform-validation/scripts/validate.sh --verbose --generate-docs
```

### When to Use Individual Commands

Use individual commands **only** for:

- Debugging specific validation failures reported by the script
- Understanding what the validation script does internally
- Developing or improving the validation script itself

**Do not use individual commands as your primary validation method.**

#### 1. terraform fmt -check

**Purpose**: Verify code formatting compliance

```bash
# Check formatting (returns non-zero if changes needed)
terraform fmt -check

# Auto-format files
terraform fmt

# Format specific directory
terraform fmt -recursive ./terraform/base/
```

**What it checks**:

- Consistent indentation
- Proper spacing
- Canonical formatting

#### 2. terraform validate

**Purpose**: Validate configuration syntax and internal consistency

```bash
# Validate current directory
terraform validate

# Validate after init
terraform init
terraform validate
```

**What it checks**:

- Syntax errors
- Invalid resource configurations
- Missing required arguments
- Type mismatches
- Invalid references

#### 3. tflint

**Purpose**: Static analysis and best practice enforcement

```bash
# Run tflint
tflint

# Run with specific config
tflint --config .tflint.hcl

# Run recursively
tflint --recursive
```

**What it checks**:

- Deprecated syntax
- Provider-specific issues
- Best practice violations
- Potential errors
- Module usage issues

#### 4. trivy config

**Purpose**: Security vulnerability scanning

```bash
# Scan current directory
trivy config .

# Scan specific file
trivy config main.tf

# Scan with severity filter
trivy config --severity HIGH,CRITICAL .
```

**What it checks**:

- Security misconfigurations
- Unencrypted resources
- Overly permissive IAM policies
- Public access issues
- Missing security controls

## Validation Workflow

### Before Committing

1. **Make changes** - Edit Terraform files

2. **Run comprehensive validation**:

   ```bash
   # Run for the entire workspace
   bash terraform-validation/scripts/validate.sh

   # Or run for specific changed directories
   bash terraform-validation/scripts/validate.sh ./terraform/path/to/module
   ```

3. **Auto-fix formatting** (if reported):

   ```bash
   bash terraform-validation/scripts/validate.sh --fix
   ```

4. **Address other issues** - Fix validation, lint, or security errors reported by the script.

5. **Commit** - Only commit when the validation script reports success for all checks.

### Before Applying

1. **Run validations** - Ensure all checks pass (`bash terraform-validation/scripts/validate.sh`)

2. **Plan changes**:

   ```bash
   terraform plan -out=tfplan
   ```

3. **Review plan** - Verify expected changes

4. **Apply** (if plan looks correct):
   ```bash
   terraform apply tfplan
   ```

## Common Validation Failures

### terraform fmt failures

**Issue**: Code not properly formatted

**Fix**:

```bash
# Auto-format all files
terraform fmt -recursive
```

### terraform validate failures

**Common issues**:

- Missing required arguments
- Invalid resource references
- Type mismatches
- Circular dependencies

**Fix**: Read error message and correct the configuration

### tflint failures

**Common issues**:

- Deprecated syntax
- Provider version issues
- Best practice violations

**Fix**: Update code according to linter suggestions

### trivy config failures

**Common security issues**:

- Unencrypted S3 buckets
- Overly permissive IAM policies
- Missing KMS encryption
- Public access enabled

**Fix**: Add security controls as recommended

## Best Practices

### Validation Frequency

- Run `terraform fmt` before every commit
- Run `terraform validate` after configuration changes
- Run `tflint` regularly during development
- Run `trivy config` before applying to production

## Security Validation

### Required Security Checks

Ensure these security measures are in place:

- ✅ KMS encryption for S3, SNS, Logs, State Machines
- ✅ IAM policies follow least privilege
- ✅ Resource policies include `Condition` clauses
- ✅ No plaintext secrets
- ✅ Logging enabled (CloudTrail, CloudWatch Logs)
- ✅ No default VPC usage
- ✅ No open security groups
- ✅ No public S3 buckets

### trivy Severity Levels

- **CRITICAL**: Immediate fix required
- **HIGH**: Fix before production deployment
- **MEDIUM**: Fix in next iteration
- **LOW**: Consider fixing

## Quick Reference

### Essential Commands

```bash
# Run comprehensive validation (Recursive)
bash terraform-validation/scripts/validate.sh

# Validate with auto-formatting
bash terraform-validation/scripts/validate.sh --fix

# Validate scoped directory
bash terraform-validation/scripts/validate.sh ./terraform/module/
```

### Validation Checklist

Before committing:

- [ ] Validation script passes (`bash terraform-validation/scripts/validate.sh`)
- [ ] Plan reviewed (if applicable, `terraform plan`)

## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use the validation script.

### terraform fmt -check

**Purpose**: Verify code formatting compliance

```bash
# Check formatting (returns non-zero if changes needed)
terraform fmt -check

# Auto-format files
terraform fmt

# Format specific directory
terraform fmt -recursive ./terraform/base/
```

**What it checks**:

- Consistent indentation
- Proper spacing
- Canonical formatting

### terraform validate

**Purpose**: Validate configuration syntax and internal consistency

```bash
# Validate current directory
terraform validate

# Validate after init
terraform init
terraform validate
```

**What it checks**:

- Syntax errors
- Invalid resource configurations
- Missing required arguments
- Type mismatches
- Invalid references

### tflint

**Purpose**: Static analysis and best practice enforcement

```bash
# Run tflint
tflint

# Run with specific config
tflint --config .tflint.hcl

# Run recursively
tflint --recursive
```

**What it checks**:

- Deprecated syntax
- Provider-specific issues
- Best practice violations
- Potential errors
- Module usage issues

### trivy config

**Purpose**: Security vulnerability scanning

```bash
# Scan current directory
trivy config .

# Scan specific file
trivy config main.tf

# Scan with severity filter
trivy config --severity HIGH,CRITICAL .
```

**What it checks**:

- Security misconfigurations
- Unencrypted resources
- Overly permissive IAM policies
- Public access issues
- Missing security controls

## Summary

Terraform validation ensures infrastructure code quality and security:

1. **Automate validation** - Use `terraform-validation/scripts/validate.sh` for comprehensive checks
2. **Validate frequently** - Run checks during development, not just before commit
3. **Fix issues promptly** - Address validation failures as they occur
4. **Enforce security** - Scan for misconfigurations with `trivy`
5. **Validate before committing** - Never commit code that fails validation
