---
name: go-validation
description: Use go-validation/scripts/validate.sh for Go code validation. This skill provides the validation workflow, coverage requirements, and troubleshooting guidance. Individual commands are for debugging only.
license: MIT
---

# Go Test and Validation

This skill provides comprehensive guidance for validating and testing Go code before committing changes. It covers automated validation scripts, manual testing procedures, coverage requirements, and security checks.

## When to Use This Skill

This skill is applicable for:

- Running validation checks before committing Go code
- Verifying code quality and formatting
- Checking test coverage and ensuring it meets project standards
- Running security vulnerability scans
- Validating code changes in specific directories
- Understanding validation requirements and procedures
- Debugging validation failures

## Validation Commands

### ⚠️ Required: Use the Validation Script

**Always use the comprehensive validation script.** This is the primary and recommended method for all validation tasks. Individual commands should only be used for debugging specific failures.

```bash
# Validate specific directory (Recommended for development)
# Pass the directory path as a positional argument
bash go-validation/scripts/validate.sh ./example/gin1/

# Validate entire project (Recommended before commit)
bash go-validation/scripts/validate.sh

# Auto-fix issues where possible
# Use --fix or -f flag to automatically handle go fmt, go mod tidy, and fixable lints
bash go-validation/scripts/validate.sh ./example/gin1/ --fix
```

### When to Use Individual Commands

Use individual commands **only** for:

- Debugging specific validation failures reported by the script
- Understanding what the validation script does internally
- Developing or improving the validation script itself

**Do not use individual commands as your primary validation method.**

### Features

- **Directory-Specific Validation**: Pass the directory or package path as a positional argument to validate only changed packages. This speeds up the feedback loop compared to scanning the full repository.
- **Auto-Fix Capabilities**: `--fix` (or `-f`) flag automatically handles:
  - `go mod tidy` dependencies
  - `go fmt` formatting
  - Fixable `golangci-lint` issues
- **Manual Fixes Required**:
  - `go vet` issues
  - Test failures
  - Race conditions
  - Security vulnerabilities

### What the Validation Script Checks

The validation script performs the following checks in order:

1. **`go mod tidy`** - Clean up and verify dependencies
   - Removes unused dependencies
   - Adds missing dependencies
   - Updates go.mod and go.sum files

2. **`go fmt`** - Format Go code
   - Ensures consistent code formatting
   - Follows Go standard formatting rules

3. **`go vet`** - Static analysis
   - Detects suspicious constructs
   - Finds potential bugs
   - Checks for common mistakes

4. **`golangci-lint`** - Comprehensive linting
   - Runs multiple linters in parallel
   - Checks code quality and style
   - Enforces best practices

5. **`go test -v -race -cover`** - Run tests with race detection and coverage
   - Executes all tests with verbose output
   - Detects race conditions
   - Measures test coverage

6. **`govulncheck`** - Security vulnerability scanning
   - Scans for known vulnerabilities in dependencies
   - Checks against the Go vulnerability database

## Validation Requirements

### Mandatory Requirements

Before considering code modifications complete, ensure:

- ✅ **All validation checks pass** - Every check in the validation script must succeed
- ✅ **Test coverage ≥ 80%** - Maintain or exceed 80% code coverage
- ✅ **No test failures** - All tests must pass before committing
- ✅ **No race conditions** - `go test -race` must pass without warnings
- ✅ **No security vulnerabilities** - `govulncheck` must report no issues

### Coverage Goals

**Target Coverage: 80% or higher**

- All public functions and methods must have tests
- Critical business logic should have 100% coverage
- Edge cases and error paths must be tested

### Checking Coverage

```bash
# Run tests with coverage report
go test -cover ./...

# Generate detailed coverage report
go test -coverprofile=coverage.out ./...

# View coverage in browser
go tool cover -html=coverage.out

# Check coverage percentage
go test -cover ./... | grep coverage
```

## Manual Testing

### Testing Approach

- **Production code**: Must be tested in `*_test.go` files
- **Test framework**: Use testify for assertions and mocks
- **Test helpers**: Keep in test files, never in production code
- **Mocks**: Define in `*_test.go` files, not in production code

### Test File Requirements

```go
// Example test file structure
package mypackage_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Tests follow AAA pattern: Arrange-Act-Assert
func TestMyFunction(t *testing.T) {
    // Arrange - Set up test data and dependencies

    // Act - Execute the function being tested

    // Assert - Verify the results
}
```

## Validation Workflow

### Before Committing Code

Follow this workflow before committing any Go code changes:

1. **Make code changes** - Implement the feature or fix

2. **Run validation on specific directory** (recommended for faster feedback):

   ```bash
   bash go-validation/scripts/validate.sh ./path/to/changed/code/
   ```

3. **Fix any issues** - Address failures reported by the validation script

4. **Run validation again** - Ensure all checks pass

5. **Optional: Run full project validation**:

   ```bash
   bash go-validation/scripts/validate.sh
   ```

6. **Commit changes** - Only commit when all validations pass

### Handling Validation Failures

#### go mod tidy failures

- Check for incompatible dependency versions
- Verify go.mod and go.sum are not corrupted
- Ensure all imports are valid

#### go fmt failures

- Run `go fmt ./...` to auto-format
- Or use `--fix` flag with the validation script

#### go vet failures

- Read the error message carefully
- Fix the reported issues (usually potential bugs)
- Common issues: unreachable code, incorrect printf formats, shadowed variables

#### golangci-lint failures

- Review the specific linter that failed
- Fix the code quality issue
- Refer to golangci-lint documentation for specific linter rules

#### Test failures

- Read the test output to understand what failed
- Fix the failing test or the code being tested
- Ensure test coverage doesn't decrease

#### Race condition failures

- Identify the concurrent access pattern
- Add proper synchronization (mutexes, channels, etc.)
- Ensure goroutines are properly managed

#### govulncheck failures

- Update vulnerable dependencies to patched versions
- If no patch available, consider alternative packages
- Document any accepted risks

## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use the validation script.

### What the Validation Script Checks

The validation script performs the following checks in order:

1. **`go mod tidy`** - Clean up and verify dependencies
2. **`go fmt`** - Format Go code
3. **`go vet`** - Static analysis
4. **`golangci-lint`** - Comprehensive linting
5. **`go test -v -race -cover`** - Run tests with race detection and coverage
6. **`govulncheck`** - Security vulnerability scanning

### Useful Test Commands

```bash
# Run all tests
go test ./...

# Run tests with verbose output
go test -v ./...

# Run specific test
go test -run TestFunctionName ./...

# Run tests in specific package
go test ./pkg/mypackage/...

# Run tests with race detection and coverage
go test -v -race -cover ./...

# Run benchmarks
go test -bench=. ./...
```

## Best Practices

### Continuous Validation

- Run validation frequently during development
- Don't wait until the end to validate
- Fix issues as they appear
- Keep validation passing at all times

### Test-Driven Development (TDD)

1. Write failing test
2. Write minimal code to pass test
3. Run validation
4. Refactor if needed
5. Repeat

## Security Validation

### Security Best Practices

- The validation script runs `govulncheck` automatically
- Update dependencies promptly when vulnerabilities are found
- Review security advisories for project dependencies
- Use `go mod tidy` to remove unused dependencies
- Avoid dependencies with known security issues

### Additional Security Checks

Beyond `govulncheck`, ensure:

- No sensitive data in error messages
- Proper timeout and cancellation with `context`
- Race condition detection with `go test -race`
- Input validation for external data
- No hardcoded credentials or secrets

## Troubleshooting

### Validation Script Not Found

```bash
# Navigate to the project root
cd /workspace

# Verify script exists
ls -la .github/skills/go-validation/scripts/validate.sh

# Make script executable if needed
chmod +x .github/skills/go-validation/scripts/validate.sh
```

### Permission Denied

```bash
# Run with bash explicitly
bash go-validation/scripts/validate.sh -f ./example/gin1/
```

### Slow Validation

```bash
# Validate only changed directory instead of entire project
bash go-validation/scripts/validate.sh ./path/to/changed/code/

# Skip slow checks during development (not recommended before commit)
go test -short ./...
```

### Coverage Below 80%

```bash
# Identify uncovered code
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Focus on uncovered functions
# Write tests for uncovered code paths
# Re-run validation
```

## Quick Reference

### Essential Commands

```bash
# Full validation (recommended before commit)
bash go-validation/scripts/validate.sh

# Directory-specific validation (during development)
bash go-validation/scripts/validate.sh ./path/to/code/

# Auto-fix issues
bash go-validation/scripts/validate.sh ./path/to/code/ --fix
```

### Validation Checklist

Before committing:

- [ ] Validation script passes (`bash go-validation/scripts/validate.sh`)
- [ ] Test coverage ≥ 80%
- [ ] No test failures
- [ ] No race conditions
- [ ] No security vulnerabilities

## Summary

Go validation ensures code quality, test coverage, and security:

1. **Automate validation** - Use `go-validation/scripts/validate.sh` for comprehensive checks
2. **Validate frequently** - Run checks during development, not just before commit
3. **Meet coverage goals** - Maintain ≥ 80% test coverage
4. **Leverage auto-fix** - Use `--fix` flag for automatic corrections
5. **Use directory-specific validation** - Faster feedback during development
6. **Monitor security** - Run `govulncheck` regularly
7. **Validate before committing** - Never commit code that fails validation

For detailed testing patterns and best practices, refer to the `go-testing` skill.
