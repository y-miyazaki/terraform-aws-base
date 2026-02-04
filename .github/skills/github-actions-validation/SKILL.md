---
name: github-actions-validation
description: GitHub Actions workflow validation covering syntax, security, and best practices. Always use validate.sh script. For troubleshooting, see reference/.
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

## ⚠️ CRITICAL: Always Use the Validation Script

**DO NOT run individual commands (actionlint, ghalint, zizmor) directly.**

**The validation script handles everything automatically.**

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

## Validation Checklist

Before committing workflow changes:

- [ ] Validation script passes
- [ ] All syntax errors resolved
- [ ] Security warnings addressed
- [ ] Timeout settings configured
- [ ] Permissions minimized

## Validation Workflow

### Before Committing

1. Make changes to workflow files
2. Run validation script: `bash github-actions-validation/scripts/validate.sh`
3. Fix any reported issues
4. Re-run validation until all checks pass
5. Commit only when validation succeeds

### Common Patterns

**Syntax validation failed**:
→ Check YAML indentation and structure
→ See [reference/troubleshooting.md](reference/troubleshooting.md) for specific errors

**Security warnings**:
→ Review permissions and secrets usage
→ See [reference/security.md](reference/security.md) for best practices

**Need to debug specific tool**:
→ See [reference/individual-commands.md](reference/individual-commands.md) for command options

## Available Reference Documentation

Detailed troubleshooting and command reference organized by topic:

**Troubleshooting**: Failure patterns for actionlint/ghalint/zizmor → [reference/troubleshooting.md](reference/troubleshooting.md)
**Security**: Permissions, secrets, third-party actions → [reference/security.md](reference/security.md)
**Individual Commands**: Command options for debugging only → [reference/individual-commands.md](reference/individual-commands.md)
