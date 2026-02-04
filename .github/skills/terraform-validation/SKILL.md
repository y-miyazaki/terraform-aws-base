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

## ⚠️ CRITICAL: Always Use the Validation Script

**DO NOT run individual commands (terraform fmt, terraform validate, tflint, trivy) directly.**

**The validation script handles everything automatically.**

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

- ✅ **All validation checks pass**
- ✅ **Code properly formatted**
- ✅ **No syntax or configuration errors**
- ✅ **No security misconfigurations**
- ✅ **Plan reviewed (if applicable)**

## Validation Workflow

### Before Committing

1. **Make changes** - Edit Terraform files
2. **Run validation** (recommend scoped for faster feedback):
   ```bash
   bash terraform-validation/scripts/validate.sh ./terraform/path/to/module
   ```
3. **Auto-fix formatting** (if needed):
   ```bash
   bash terraform-validation/scripts/validate.sh --fix
   ```
4. **Address other issues** - Fix validation, lint, or security errors
5. **Commit** - Only commit when validation passes

### Before Applying

1. **Run validations** - Ensure all checks pass
2. **Plan changes**:
   ```bash
   terraform plan -out=tfplan
   ```
3. **Review plan** - Verify expected changes
4. **Apply** (if plan looks correct):
   ```bash
   terraform apply tfplan
   ```

## Common Failures & Quick Fixes

### Formatting Errors

```
Error: terraform fmt check failed
```

**Fix**: Auto-format with `--fix` flag

```bash
bash terraform-validation/scripts/validate.sh --fix
```

### terraform validate Errors

```
Error: Missing required argument
```

**Fix**: Read error message, add missing arguments, re-run validation

### tflint Errors

```
Error: Deprecated syntax
```

**Fix**: Update code according to linter suggestions

### trivy config Errors

```
HIGH: S3 bucket has block public access disabled
```

**Fix**: Add security controls as recommended (encryption, access restrictions)

## Security Requirements

Required security measures:

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

## Troubleshooting

### Validation Script Not Found

```bash
# Navigate to project root
cd /workspace

# Verify script exists
ls -la .github/skills/terraform-validation/scripts/validate.sh

# Run with bash explicitly
bash terraform-validation/scripts/validate.sh
```

### Slow Validation

```bash
# Validate only changed directories (much faster)
bash terraform-validation/scripts/validate.sh ./terraform/module/
```

### Need More Details

For detailed information, see the reference documentation:

- **[Individual Commands](reference/individual-commands.md)** - Detailed command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Comprehensive error resolution
- **[Security Best Practices](reference/security.md)** - Infrastructure security guidelines
