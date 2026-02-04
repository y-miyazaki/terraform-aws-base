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

## ⚠️ CRITICAL: Always Use the Validation Script

**DO NOT run individual commands (go fmt, go vet, golangci-lint, go test) directly.**

**The validation script handles everything automatically.**

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

- ✅ **All validation checks pass**
- ✅ **Test coverage ≥ 80%**
- ✅ **No test failures**
- ✅ **No race conditions**
- ✅ **No security vulnerabilities**

## Validation Workflow

### Before Committing

1. **Make code changes** - Implement feature or fix
2. **Run validation on changed directory** (recommended):
   ```bash
   bash go-validation/scripts/validate.sh ./path/to/changed/code/
   ```
3. **Fix any issues** - Address failures reported
4. **Re-run validation** - Ensure all checks pass
5. **Optional: Run full project validation**:
   ```bash
   bash go-validation/scripts/validate.sh
   ```
6. **Commit** - Only commit when validation passes

## Common Failures & Quick Fixes

### Formatting Errors

```
Error: go fmt check failed
Files not formatted correctly
```

**Fix**: Auto-format with `--fix` flag

```bash
bash go-validation/scripts/validate.sh --fix
```

### go vet Errors

```
Error: go vet failed
main.go:15: unreachable code
```

**Fix**: Read error message, correct the code issue, re-run validation

### Lint Errors

```
Error: golangci-lint failed
error: unused variable 'result'
```

**Fix**: Address linter suggestions (remove unused code, check errors, etc.)

### Test Failures

```
Error: Tests failed
Expected: 5, Got: 3
```

**Fix**: Fix test logic or implementation, ensure all tests pass

### Race Conditions

```
WARNING: DATA RACE
Read at 0x00c000102090 by goroutine 7
```

**Fix**: Add proper synchronization (mutex, channels, atomic operations)

### Coverage Below 80%

```
Error: Coverage below 80%
Current coverage: 65.4%
```

**Fix**: Write tests for uncovered code, focus on public APIs and error paths

### Security Vulnerabilities

```
govulncheck: found vulnerabilities
Vulnerability in golang.org/x/crypto
```

**Fix**: Update vulnerable dependencies to patched versions

## Troubleshooting

### Validation Script Not Found

```bash
# Navigate to project root
cd /workspace

# Verify script exists
ls -la .github/skills/go-validation/scripts/validate.sh

# Run with bash explicitly
bash go-validation/scripts/validate.sh
```

### Slow Validation

```bash
# Validate only changed directory (much faster)
bash go-validation/scripts/validate.sh ./path/to/changed/code/
```

### Need More Details

For detailed information, see the reference documentation:

- **[Individual Commands](reference/individual-commands.md)** - Detailed command usage for debugging
- **[Troubleshooting Guide](reference/troubleshooting.md)** - Comprehensive error resolution
- **[Testing Best Practices](reference/testing.md)** - Test patterns and coverage strategies
- **[Security Best Practices](reference/security.md)** - Security guidelines and patterns
