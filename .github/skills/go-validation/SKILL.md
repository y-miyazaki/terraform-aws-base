---
name: go-validation
description: Go code validation workflow covering formatting, linting, testing, and security. Always use validate.sh script. For troubleshooting, see reference/.
license: MIT
---

# Go Validation

This skill provides guidance for validating Go code using the comprehensive validation script.

## When to Use This Skill

This skill is applicable for:

- Validating Go code before committing
- Running comprehensive quality checks
- Ensuring test coverage meets standards
- Security vulnerability scanning

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

```bash
# Full validation (recommended before commit)
bash go-validation/scripts/validate.sh

# Directory-specific validation (faster feedback during development)
bash go-validation/scripts/validate.sh ./path/to/code/

# Auto-fix formatting issues
bash go-validation/scripts/validate.sh --fix

# With verbose output
bash go-validation/scripts/validate.sh --verbose
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **`go mod tidy`** - Clean up and verify dependencies
2. **`go fmt`** - Format Go code
3. **`go vet`** - Static analysis for suspicious constructs
4. **`golangci-lint`** - Comprehensive linting (30+ linters)
5. **`go test -v -race -cover`** - Run tests with race detection and coverage
6. **`govulncheck`** - Security vulnerability scanning

## Validation Requirements

Before considering code complete:

- [ ] All validation checks pass
- [ ] Test coverage ≥ 80%
- [ ] No test failures
- [ ] No race conditions
- [ ] No security vulnerabilities

## Validation Workflow

1. **Make changes** - Implement feature or fix
2. **Run validation**: `bash go-validation/scripts/validate.sh ./path/to/code/`
3. **Fix issues** - Address failures reported
4. **Re-run validation** - Ensure all checks pass
5. **Commit** - Only when validation passes

## Reference Documentation

For detailed information:

- **[Individual Commands](reference/individual-commands.md)** - Command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Error resolution
- **[Testing Best Practices](reference/testing.md)** - Test patterns and coverage
- **[Security Best Practices](reference/security.md)** - Security guidelines
