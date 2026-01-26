---
name: github-actions-validation
description: Use github-actions-validation/scripts/validate.sh for GitHub Actions validation. This skill provides the validation workflow and troubleshooting guidance. Individual commands are for debugging only.
license: MIT
---

# GitHub Actions Validation

This skill provides guidance for validating GitHub Actions workflows to ensure correctness, security, and best practices.

## When to Use This Skill

This skill is applicable for:

- Validating GitHub Actions workflow syntax
- Checking workflow security settings
- Verifying timeout configurations
- Ensuring best practices compliance
- Debugging workflow validation failures

## Validation Commands

### ⚠️ Required: Use the Validation Script

**Always use the comprehensive validation script.** This is the primary and recommended method for all validation tasks. Individual commands should only be used for debugging specific failures.

Run the centralized validation script before committing workflow files:

```bash
# Run all validations
bash github-actions-validation/scripts/validate.sh

# Validate specific directory
bash github-actions-validation/scripts/validate.sh ./.github/workflows/
```

This script runs three mandatory checks:

1. **actionlint**: Workflow syntax and best practices
2. **ghalint**: Security and configuration validation
3. **zizmor**: GitHub Actions security scanner

### When to Use Individual Commands

Use individual commands **only** for:

- Debugging specific validation failures reported by the script
- Understanding what the validation script does internally
- Developing or improving the validation script itself

**Do not use individual commands as your primary validation method.**

#### 1. actionlint

**Purpose**: Validate workflow syntax and detect common issues

```bash
# Check all workflows
actionlint .github/workflows/*.{yml,yaml}

# Check specific workflow
actionlint .github/workflows/ci.yml

# Check with shellcheck integration
actionlint -shellcheck= .github/workflows/*.yml
```

**What it checks**:

- YAML syntax errors
- Invalid workflow structure
- Deprecated actions
- Invalid action inputs
- Expression syntax errors
- Shell command issues
- Best practice violations

#### 2. ghalint run

**Purpose**: Security and configuration validation

```bash
# Run ghalint
ghalint run .github/workflows/

# Run with specific config
ghalint run -config .ghalint.yml .github/workflows/
```

**What it checks**:

- Security issues
- Permissions configuration
- Secrets usage
- Third-party action versions
- Workflow triggers
- Configuration best practices

#### 3. zizmor

**Purpose**: Scan workflows for GitHub Actions security issues

```bash
# Run zizmor
zizmor .
```

**What it checks**:

- Information leaks
- Insecure triggers
- Overly permissive tokens
- Insecure step-level configurations
- Vulnerable third-party actions

## Validation Checklist

### Syntax Validation

- [ ] YAML syntax is valid
- [ ] Workflow structure is correct
- [ ] Action inputs are valid
- [ ] Expressions are properly formatted

### Security Validation

- [ ] `permissions` explicitly set
- [ ] `persist-credentials: false` on checkout
- [ ] Secrets properly referenced
- [ ] Third-party actions pinned to SHA
- [ ] Timeout-minutes configured

### Best Practices

- [ ] Job and step timeouts set
- [ ] Minimal permissions granted
- [ ] No deprecated actions
- [ ] Shell commands are safe
- [ ] Error handling implemented

## Common Validation Failures

### actionlint failures

**Common issues**:

- Invalid YAML syntax
- Unknown action inputs
- Expression syntax errors
- Deprecated action versions

**Fix**: Follow actionlint suggestions

### ghalint failures

**Common issues**:

- Missing `permissions` block
- Overly permissive permissions
- Unpinned action versions
- Security vulnerabilities

**Fix**: Add security configurations

### zizmor failures

**Common issues**:

- Potential secret leaks in logs
- Usage of unpinned actions
- Insecure runner configurations

**Fix**: Follow zizmor security recommendations and harden the workflow.

## Validation Workflow

### Before Committing

1. **Edit workflow** - Make changes to `.github/workflows/*.yml`

2. **Run validation script**:

   ```bash
   bash github-actions-validation/scripts/validate.sh
   ```

3. **Fix issues** - Address all validation failures

4. **Test workflow** - Trigger workflow to verify

5. **Commit** - Only commit valid workflows

## Security Best Practices

### Permissions

Always set minimal permissions:

```yaml
permissions:
  contents: read # Read-only by default
  pull-requests: write # Only when needed
```

### Secrets Management

```yaml
# ✅ Good - Use secrets properly
env:
  API_KEY: ${{ secrets.API_KEY }}

# ❌ Bad - Don't echo secrets
run: echo ${{ secrets.API_KEY }}
```

### Actions Checkout

```yaml
# ✅ Good - Secure checkout
- uses: actions/checkout@v4
  with:
    persist-credentials: false

# ❌ Bad - Insecure checkout
- uses: actions/checkout@v4
```

### Timeout Settings

```yaml
# ✅ Good - Timeouts configured
jobs:
  build:
    timeout-minutes: 30
    steps:
      - name: Build
        timeout-minutes: 10

# ❌ Bad - No timeouts
jobs:
  build:
    steps:
      - name: Build
```

### Third-party Actions

```yaml
# ✅ Good - Pinned to SHA
- uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2

# ❌ Bad - Unpinned version
- uses: actions/setup-node@v4
```

## Quick Reference

### Essential Commands

```bash
# Run all validations
bash github-actions-validation/scripts/validate.sh

# Run for specific workflows directory
bash github-actions-validation/scripts/validate.sh ./test-workflows/
```

### Validation Checklist

Before committing:

- [ ] Validation script passes (`bash github-actions-validation/scripts/validate.sh`)
- [ ] Permissions are minimal
- [ ] Secrets are properly used
- [ ] Actions are pinned to SHA

## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use the validation script.

### actionlint

**Purpose**: Validate workflow syntax and detect common issues

```bash
# Check all workflows
actionlint .github/workflows/*.{yml,yaml}

# Check specific workflow
actionlint .github/workflows/ci.yml

# Check with shellcheck integration
actionlint -shellcheck= .github/workflows/*.yml
```

**What it checks**:

- YAML syntax errors
- Invalid workflow structure
- Deprecated actions
- Invalid action inputs
- Expression syntax errors
- Shell command issues
- Best practice violations

### ghalint run

**Purpose**: Security and configuration validation

```bash
# Run ghalint
ghalint run .github/workflows/

# Run with specific config
ghalint run -config .ghalint.yml .github/workflows/
```

**What it checks**:

- Security issues
- Permissions configuration
- Secrets usage
- Third-party action versions
- Workflow triggers
- Configuration best practices

### zizmor

**Purpose**: Scan workflows for GitHub Actions security issues

```bash
# Run zizmor
zizmor .
```

**What it checks**:

- Information leaks
- Insecure triggers
- Overly permissive tokens
- Insecure step-level configurations
- Vulnerable third-party actions

## Summary

GitHub Actions validation ensures secure and reliable workflows:

1. **Automate validation** - Use `github-actions-validation/scripts/validate.sh` for comprehensive checks
2. **Validate frequently** - Run checks during development, not just before commit
3. **Set minimal permissions** - Follow least privilege principle
4. **Secure secrets** - Never expose in logs
5. **Pin actions** - Use commit SHA for third-party actions
6. **Validate before committing** - Never commit invalid workflows
