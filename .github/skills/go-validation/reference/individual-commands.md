# Go Validation - Individual Commands Reference

## Contents

- [Go Validation - Individual Commands Reference](#go-validation---individual-commands-reference)
  - [Contents](#contents)
  - [⚠️ For Debugging Only](#️-for-debugging-only)
  - [Commands Overview](#commands-overview)
  - [1. go mod tidy](#1-go-mod-tidy)
  - [2. go fmt](#2-go-fmt)
  - [3. go vet](#3-go-vet)
  - [4. golangci-lint](#4-golangci-lint)
  - [5. go test](#5-go-test)
  - [6. govulncheck](#6-govulncheck)
  - [Coverage Analysis Commands](#coverage-analysis-commands)
    - [Generating Coverage Reports](#generating-coverage-reports)
    - [Coverage Modes](#coverage-modes)
    - [Interpreting Coverage Reports](#interpreting-coverage-reports)
  - [Additional Tools](#additional-tools)
    - [staticcheck](#staticcheck)
    - [gosec](#gosec)
    - [go-critic](#go-critic)
  - [Profiling Commands](#profiling-commands)
  - [Summary](#summary)

## ⚠️ For Debugging Only

This document contains detailed information about individual validation commands.

**Always prefer the validation script:** `bash go-validation/scripts/validate.sh`

Use individual commands **only** when:
- Debugging specific validation failures reported by the script
- Understanding what the validation script does internally
- Developing or improving the validation script itself

## Commands Overview

The validation script runs these commands in order:
1. go mod tidy
2. go fmt
3. go vet
4. golangci-lint
5. go test -v -race -cover
6. govulncheck

## 1. go mod tidy

**Purpose**: Clean up and verify dependencies

```bash
# Clean up dependencies
go mod tidy

# Verify dependencies
go mod verify
```

**What it checks**:
- Removes unused dependencies
- Adds missing dependencies
- Updates go.mod and go.sum files
- Verifies checksums

**Common failures**:
- Incompatible dependency versions
- Corrupted go.mod or go.sum
- Invalid imports

## 2. go fmt

**Purpose**: Format Go code

```bash
# Format all files
go fmt ./...

# Format specific file
go fmt path/to/file.go

# Format recursively
go fmt ./pkg/...
```

**What it checks**:
- Consistent indentation
- Proper spacing
- Canonical formatting

**Common failures**:
- Parse errors in code
- Invalid syntax

## 3. go vet

**Purpose**: Static analysis for suspicious constructs

```bash
# Run vet on all packages
go vet ./...

# Run vet on specific package
go vet ./pkg/mypackage
```

**What it checks**:
- Unreachable code
- Incorrect printf formats
- Shadowed variables
- Invalid struct tags
- Mutex misuse
- Common mistakes

**Common failures**:
- Printf format mismatches
- Shadowed loop variables
- Unreachable code after return
- Invalid build tags

## 4. golangci-lint

**Purpose**: Comprehensive linting with multiple linters

```bash
# Run golangci-lint
golangci-lint run

# Run with config file
golangci-lint run --config .golangci.yml

# Run with auto-fix
golangci-lint run --fix

# Run on specific directory
golangci-lint run ./pkg/...
```

**What it checks**:
- Code quality and style
- Best practices violations
- Performance issues
- Error handling
- Security issues
- Dead code

**Common failures**:
- Unused variables/imports
- Error return values not checked
- Inefficient string concatenation
- Magic numbers
- Cognitive complexity too high

## 5. go test

**Purpose**: Run tests with race detection and coverage

```bash
# Run all tests
go test ./...

# Run with verbose output
go test -v ./...

# Run with race detection
go test -race ./...

# Run with coverage
go test -cover ./...

# Run with coverage profile
go test -coverprofile=coverage.out ./...

# View coverage in browser
go tool cover -html=coverage.out

# Run specific test
go test -run TestFunctionName ./...

# Run tests in specific package
go test ./pkg/mypackage/...

# Run benchmarks
go test -bench=. ./...

# Run tests with short mode
go test -short ./...

# Run tests with timeout
go test -timeout 30s ./...
```

**What it checks**:
- Test correctness
- Race conditions
- Code coverage
- Performance (benchmarks)

**Common failures**:
- Test logic errors
- Race conditions
- Insufficient coverage
- Timeout exceeded

## 6. govulncheck

**Purpose**: Security vulnerability scanning

```bash
# Scan for vulnerabilities
govulncheck ./...

# Scan with JSON output
govulncheck -json ./...
```

**What it checks**:
- Known vulnerabilities in dependencies
- Go vulnerability database
- Direct and indirect dependencies

**Common failures**:
- Vulnerable dependencies
- Outdated packages with known CVEs

## Coverage Analysis Commands

### Generating Coverage Reports

```bash
# Generate coverage profile
go test -coverprofile=coverage.out ./...

# View coverage in terminal
go tool cover -func=coverage.out

# View coverage in browser
go tool cover -html=coverage.out

# Generate coverage for specific package
go test -coverprofile=coverage.out ./pkg/mypackage

# Generate coverage with mode
go test -covermode=atomic -coverprofile=coverage.out ./...
```

### Coverage Modes

- **set**: Did each statement run?
- **count**: How many times did each statement run?
- **atomic**: Like count, but counts precisely in parallel tests

### Interpreting Coverage Reports

```bash
# Coverage by function
go tool cover -func=coverage.out

# Output format:
# path/to/file.go:FunctionName  LineRange  Coverage%
```

## Additional Tools

### staticcheck

```bash
# Install
go install honnef.co/go/tools/cmd/staticcheck@latest

# Run
staticcheck ./...
```

### gosec

```bash
# Install
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Run
gosec ./...
```

### go-critic

```bash
# Install
go install github.com/go-critic/go-critic/cmd/gocritic@latest

# Run
gocritic check ./...
```

## Profiling Commands

```bash
# CPU profiling
go test -cpuprofile=cpu.prof -bench=. ./...
go tool pprof cpu.prof

# Memory profiling
go test -memprofile=mem.prof -bench=. ./...
go tool pprof mem.prof

# View in browser
go tool pprof -http=:8080 cpu.prof
```

## Summary

This reference provides command-level details for debugging Go validation failures. Always use the validation script for normal development workflow.
