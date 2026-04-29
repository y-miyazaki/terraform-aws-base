---
name: go-validation
description: >-
  Validates Go source code for formatting, linting, testing, and security using go fmt, go vet,
  golangci-lint, go test, and govulncheck. Use when committing Go code, running CI validation,
  debugging test failures, or checking for security vulnerabilities in Go projects.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Go source code files (`.go`) in current directory or specified path (required)
- Validation script: `go-validation/scripts/validate.sh` (required)
- Optional: directory path, `--fix` for auto-formatting, `--verbose` for detailed output

## Output Specification

Structured validation results from six tools in execution order: go mod tidy → go fmt → go vet → golangci-lint → go test → govulncheck.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes all tools in recommended order with proper configuration
- Individual tool commands available for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md))
- **Do not review code design decisions** (use go-review for that)
- Test coverage threshold: 80%

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when validation fails with unexpected errors
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging a specific tool (go fmt/vet/lint/test/govulncheck)

**Category Details** (read when investigating specific failures):

- [category-security.md](references/category-security.md) - Read when govulncheck reports vulnerabilities
- [category-testing.md](references/category-testing.md) - Read when tests fail or coverage is below threshold

## Workflow

**Always use the validation script. Do not run individual commands.**

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

1. **`go mod tidy`** - Clean up and verify dependencies
2. **`go fmt`** - Format Go code
3. **`go vet`** - Static analysis for suspicious constructs
4. **`golangci-lint`** - Comprehensive linting (30+ linters)
5. **`go test -v -race -cover`** - Run tests with race detection and coverage
6. **`govulncheck`** - Security vulnerability scanning

## Output Format

```
✓ go mod tidy: Dependencies verified
✓ go fmt: All files formatted
✓ go vet: No issues found
✓ golangci-lint: No issues found
✓ go test: All tests passed (coverage: XX%)
✓ govulncheck: No vulnerabilities found
All validations passed
```

## Best Practices

- Run full validation before every commit
- Use `--fix` to auto-correct formatting issues
- Use directory-specific validation for faster feedback during development
- All checks must pass before considering code complete
