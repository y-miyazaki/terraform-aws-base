---
name: go-validation
description: Go code validation workflow covering formatting, linting, testing, and security using go fmt, go vet, golangci-lint, go test, and govulncheck. Always use validate.sh script for comprehensive validation. For troubleshooting, see reference/.
license: MIT
---

## Purpose

Validates Go source code for formatting, correctness, and security using go fmt, go vet, golangci-lint, go test, and govulncheck.

This skill provides guidance for validating Go code using the comprehensive validation script.

## When to Use This Skill

Recommended usage:

- Before committing Go code changes
- During pull request validation in CI/CD
- After making any code modifications
- When debugging test failures or linting issues
- For security compliance verification before release
- During development for fast feedback (use directory-specific validation)

## Input Specification

This skill expects:

- Go source code files (required) - `.go` files in current directory or specified path
- Validation script (required) - `go-validation/scripts/validate.sh`
- Optional directory path (optional) - Specific directory to validate
- Optional flags (optional) - `--fix` for auto-formatting, `--verbose` for detailed output

Format:

- Go files: Valid Go source code with `.go` extension
- Directory path: Relative or absolute path to Go code directory
- Flags: `--fix` or `--verbose` as command-line arguments
- Default: Validates all Go files in current directory if no path specified

## Output Specification

Structured validation results from five tools in execution order:

- go mod tidy output: Dependency cleanup status
- go fmt output: Formatting issues or confirmation
- go vet output: Static analysis warnings with file paths and line numbers
- golangci-lint output: Linting issues from 30+ linters with severity levels
- go test output: Test results with coverage percentage and race detection results
- govulncheck output: Security vulnerabilities with CVE identifiers

Success output format:

```
✓ go mod tidy: Dependencies verified
✓ go fmt: All files formatted
✓ go vet: No issues found
✓ golangci-lint: No issues found
✓ go test: All tests passed (coverage: XX%)
✓ govulncheck: No vulnerabilities found
All validations passed
```

Error output format:

```
✗ go fmt: [file]: formatting required
✗ go vet: [file]:[line]: [warning]
✗ golangci-lint: [file]:[line]: [linter]: [issue]
✗ go test: [test name]: FAIL
✗ govulncheck: [vulnerability]: [CVE-XXXX-XXXX]
Exit code: 1
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes go mod tidy, go fmt, go vet, golangci-lint, go test, and govulncheck in recommended order
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Clean up and verify dependencies using go mod tidy
- Format Go code using go fmt
- Perform static analysis using go vet
- Run comprehensive linting using golangci-lint (30+ linters)
- Execute tests with race detection and coverage using go test
- Scan for security vulnerabilities using govulncheck
- Validate test coverage meets 80% threshold

What this skill does NOT do (Out of Scope):

- Modify code logic or fix bugs automatically (except formatting with --fix flag)
- Review code design decisions (use go-review for that)
- Execute benchmarks or performance profiling
- Generate code or tests automatically
- Approve or merge pull requests
- Validate non-Go files
- Deploy or build production binaries

## Constraints

Prerequisites:

- Go toolchain installed (go command available in PATH)
- golangci-lint installed and available in PATH
- govulncheck installed and available in PATH
- Go module initialized (go.mod file exists)
- Validation script must be executable
- Test files must exist for coverage validation

Limitations:

- Test coverage threshold is fixed at 80%
- Race detection may slow down test execution
- golangci-lint configuration must be present for custom rules
- Cannot validate code that doesn't compile
- Requires network access for govulncheck vulnerability database

## Failure Behavior

Error handling:

- Tool not found: Output error message indicating which tool is missing, exit with code 1
- Compilation error: go vet outputs specific error with file and line, exit with code 1
- Test failure: go test outputs failed test name and details, exit with code 1
- Coverage below 80%: Output coverage percentage and exit with code 1
- Race condition detected: go test outputs race report, exit with code 1
- Security vulnerability found: govulncheck outputs CVE details, exit with code 1
- Multiple errors: Report all errors from all tools before exiting

Error reporting format:

- Each tool outputs errors to standard error
- Exit code: 0=success, 1=validation failed
- Error messages include file paths, line numbers, and specific issues
- Detailed troubleshooting available in reference/troubleshooting.md

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Go code validation checklist
- **common-output-format.md** - Validation result report format specification
- **common-troubleshooting.md** - Troubleshooting guide
- **common-individual-commands.md** - Individual command execution (go fmt/vet/lint/test/govulncheck)

**Category Details**:

- **category-security.md** - Security validation guide
- **category-testing.md** - Test execution guide

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

## Workflow

1. **Make changes** - Implement feature or fix
2. **Run validation**: `bash go-validation/scripts/validate.sh ./path/to/code/`
3. **Fix issues** - Address failures reported
4. **Re-run validation** - Ensure all checks pass
5. **Commit** - Only when validation passes
