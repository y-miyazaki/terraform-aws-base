# Go Validation - Troubleshooting Guide

## Contents

- [Go Validation - Troubleshooting Guide](#go-validation---troubleshooting-guide)
  - [Contents](#contents)
  - [Overview](#overview)
  - [go mod tidy Failures](#go-mod-tidy-failures)
    - [Issue: Incompatible dependency versions](#issue-incompatible-dependency-versions)
    - [Issue: Corrupted go.sum](#issue-corrupted-gosum)
    - [Issue: Replace directives not working](#issue-replace-directives-not-working)
  - [go fmt Failures](#go-fmt-failures)
    - [Issue: Parse errors](#issue-parse-errors)
    - [Issue: File permissions](#issue-file-permissions)
  - [go vet Failures](#go-vet-failures)
    - [Issue: Printf format mismatches](#issue-printf-format-mismatches)
    - [Issue: Shadowed variables](#issue-shadowed-variables)
    - [Issue: Unreachable code](#issue-unreachable-code)
  - [golangci-lint Failures](#golangci-lint-failures)
    - [Issue: Unused variables](#issue-unused-variables)
    - [Issue: Error not checked](#issue-error-not-checked)
    - [Issue: Inefficient string concatenation](#issue-inefficient-string-concatenation)
    - [Issue: Cognitive complexity too high](#issue-cognitive-complexity-too-high)
    - [Issue: Magic numbers](#issue-magic-numbers)
  - [Test Failures](#test-failures)
    - [Issue: Test logic errors](#issue-test-logic-errors)
    - [Issue: Table-driven test failures](#issue-table-driven-test-failures)
    - [Issue: Test timeout](#issue-test-timeout)
  - [Race Condition Failures](#race-condition-failures)
    - [Issue: Data race detected](#issue-data-race-detected)
    - [Issue: Concurrent map access](#issue-concurrent-map-access)
  - [Coverage Failures](#coverage-failures)
    - [Issue: Coverage below 80%](#issue-coverage-below-80)
    - [Issue: Unable to measure coverage](#issue-unable-to-measure-coverage)
  - [govulncheck Failures](#govulncheck-failures)
    - [Issue: Known vulnerability found](#issue-known-vulnerability-found)
    - [Issue: Indirect dependency vulnerability](#issue-indirect-dependency-vulnerability)
    - [Issue: No patch available](#issue-no-patch-available)
  - [Validation Script Issues](#validation-script-issues)
    - [Issue: Script not found](#issue-script-not-found)
    - [Issue: Permission denied](#issue-permission-denied)
    - [Issue: Command not found in script](#issue-command-not-found-in-script)
  - [Summary](#summary)

## Overview

This guide provides detailed troubleshooting steps for validation failures. Always start with the validation script, then refer to this guide for specific error types.

## go mod tidy Failures

### Issue: Incompatible dependency versions

```
go: example.com/pkg v1.0.0 requires example.com/dep v2.0.0, but go.mod has v1.0.0
```

**Solutions**:
1. Update dependency: `go get example.com/dep@v2.0.0`
2. Update all dependencies: `go get -u ./...`
3. Check for conflicting requirements in go.mod
4. Review indirect dependencies with: `go mod graph`

### Issue: Corrupted go.sum

```
verifying checksum failed
```

**Solutions**:
1. Delete go.sum and regenerate: `rm go.sum && go mod tidy`
2. Verify with: `go mod verify`
3. Check for manual edits to go.sum

### Issue: Replace directives not working

```
replacement module without version must be directory path
```

**Solutions**:
1. Use absolute or relative path: `replace example.com/pkg => ./local/pkg`
2. Or specify version: `replace example.com/pkg => example.com/pkg v1.0.0`

## go fmt Failures

### Issue: Parse errors

```
parse error: expected '}', found 'EOF'
```

**Solutions**:
1. Check for syntax errors
2. Ensure all braces are closed
3. Run `go build` to see detailed error
4. Check for unmatched quotes or parentheses

### Issue: File permissions

```
permission denied
```

**Solutions**:
1. Check file permissions: `ls -la`
2. Fix with: `chmod 644 *.go`

## go vet Failures

### Issue: Printf format mismatches

```
Printf format %d has arg value of wrong type string
```

**Solutions**:
1. Fix format specifier:
   - `%d` for int
   - `%s` for string
   - `%v` for any
   - `%+v` for struct with field names
   - `%#v` for Go-syntax representation
2. Ensure argument types match format

### Issue: Shadowed variables

```
declaration of "err" shadows declaration at line 10
```

**Solutions**:
1. Rename inner variable
2. Use different variable name
3. Remove unnecessary redeclaration
4. Consider scope restructuring

**Example fix**:
```go
// Bad
err := doSomething()
if err != nil {
    for _, item := range items {
        err := processItem(item) // shadows err
        if err != nil {
            return err
        }
    }
}

// Good
err := doSomething()
if err != nil {
    for _, item := range items {
        if processErr := processItem(item); processErr != nil {
            return processErr
        }
    }
}
```

### Issue: Unreachable code

```
unreachable code
```

**Solutions**:
1. Remove code after return/panic
2. Fix conditional logic
3. Check for missing else branches

## golangci-lint Failures

### Issue: Unused variables

```
variable 'result' is unused (ineffassign)
```

**Solutions**:
1. Use the variable
2. Remove unused variable
3. Use `_` if intentionally unused: `_, err := someFunc()`

### Issue: Error not checked

```
Error return value is not checked (errcheck)
```

**Solutions**:
1. Check error:
```go
if err := someFunc(); err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}
```
2. Explicitly ignore with comment:
```go
_ = file.Close() // Best effort close
```

### Issue: Inefficient string concatenation

```
consider using strings.Builder (ineffassign)
```

**Solutions**:
```go
// Bad
result := ""
for _, s := range strings {
    result += s
}

// Good
var builder strings.Builder
for _, s := range strings {
    builder.WriteString(s)
}
result := builder.String()
```

### Issue: Cognitive complexity too high

```
cognitive complexity 32 of func `ProcessData` is high (gocognit)
```

**Solutions**:
1. Extract methods to separate functions
2. Use early returns to reduce nesting
3. Apply table-driven patterns
4. Consider redesigning the function

### Issue: Magic numbers

```
mnd: Magic number: 3600 (gomnd)
```

**Solutions**:
```go
// Bad
timeout := time.Duration(3600) * time.Second

// Good
const defaultTimeout = 3600 * time.Second
timeout := defaultTimeout
```

## Test Failures

### Issue: Test logic errors

```
Expected: 5
Actual: 3
```

**Solutions**:
1. Review test expectations
2. Fix implementation
3. Add debug output: `t.Logf("value: %v", value)`
4. Use `go test -v` for verbose output

### Issue: Table-driven test failures

```
Test case "negative input" failed
```

**Solutions**:
1. Use `t.Run()` for subtests:
```go
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        result := MyFunc(tt.input)
        if result != tt.expected {
            t.Errorf("got %v, want %v", result, tt.expected)
        }
    })
}
```
2. Add more descriptive test names
3. Review specific test case data

### Issue: Test timeout

```
panic: test timed out after 10m0s
```

**Solutions**:
1. Increase timeout: `go test -timeout 30m`
2. Review for infinite loops
3. Check for deadlocks
4. Use context with timeout in tests

## Race Condition Failures

### Issue: Data race detected

```
WARNING: DATA RACE
Read at 0x00c0001020a0 by goroutine 7:
  main.(*Server).handleRequest()
      /path/to/file.go:42
Previous write at 0x00c0001020a0 by goroutine 6:
  main.(*Server).updateState()
      /path/to/file.go:35
```

**Solutions**:

1. **Use mutex protection**:
```go
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

func (c *SafeCounter) Increment() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.count++
}

func (c *SafeCounter) Value() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.count
}
```

2. **Use channels for communication**:
```go
// Instead of shared variable
type Server struct {
    requests chan Request
    done     chan bool
}

func (s *Server) worker() {
    for {
        select {
        case req := <-s.requests:
            s.handleRequest(req)
        case <-s.done:
            return
        }
    }
}
```

3. **Use sync/atomic for simple counters**:
```go
type Counter struct {
    value atomic.Int64
}

func (c *Counter) Increment() {
    c.value.Add(1)
}

func (c *Counter) Value() int64 {
    return c.value.Load()
}
```

### Issue: Concurrent map access

```
fatal error: concurrent map writes
```

**Solutions**:

1. **Use sync.Map**:
```go
var cache sync.Map

// Write
cache.Store("key", value)

// Read
if val, ok := cache.Load("key"); ok {
    // use val
}

// Delete
cache.Delete("key")
```

2. **Protect map with mutex**:
```go
type SafeMap struct {
    mu sync.RWMutex
    data map[string]interface{}
}

func (m *SafeMap) Set(key string, value interface{}) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.data[key] = value
}

func (m *SafeMap) Get(key string) (interface{}, bool) {
    m.mu.RLock()
    defer m.mu.RUnlock()
    val, ok := m.data[key]
    return val, ok
}
```

3. **Use channels to serialize access**:
```go
type MapOp struct {
    op    string // "set" or "get"
    key   string
    value interface{}
    result chan interface{}
}

func mapManager(ops chan MapOp) {
    data := make(map[string]interface{})
    for op := range ops {
        switch op.op {
        case "set":
            data[op.key] = op.value
        case "get":
            op.result <- data[op.key]
        }
    }
}
```

## Coverage Failures

### Issue: Coverage below 80%

```
coverage: 65.4% of statements
FAIL: Coverage below 80%
```

**Solutions**:

1. **Identify uncovered code**:
```bash
go test -coverprofile=/workspace/tmp/coverage.out ./...
go tool cover -html=/workspace/tmp/coverage.out
```

2. **Write tests for uncovered functions**:
   - Focus on public APIs first
   - Test error paths
   - Test edge cases

3. **Check coverage per package**:
```bash
go test -cover ./... | grep -v "no test files"
```

### Issue: Unable to measure coverage

```
no Go files in current directory
```

**Solutions**:
1. Navigate to correct directory
2. Run from project root: `go test -cover ./...`
3. Specify package path explicitly

## govulncheck Failures

### Issue: Known vulnerability found

```
Vulnerability: CVE-2024-1234 in golang.org/x/crypto
Found in: golang.org/x/crypto@v0.0.0-20240101000000-abcdef123456
Fixed in: golang.org/x/crypto@v0.1.0
```

**Solutions**:
1. Update vulnerable package: `go get golang.org/x/crypto@latest`
2. Check for patch version: `go list -m -versions golang.org/x/crypto`
3. Update go.mod and run: `go mod tidy`

### Issue: Indirect dependency vulnerability

```
Found vulnerability in transitive dependency
golang.org/x/crypto@v0.0.0 (indirect)
```

**Solutions**:
1. Find dependency path: `go mod graph | grep x/crypto`
2. Update direct dependency that pulls in vulnerable package
3. Use `replace` directive if needed:
```go
replace golang.org/x/crypto => golang.org/x/crypto v0.1.0
```

### Issue: No patch available

```
No fix available for CVE-2024-5678
```

**Solutions**:
1. Consider alternative packages
2. Document accepted risk in security.md
3. Monitor for updates
4. Check if vulnerability affects your usage

## Validation Script Issues

### Issue: Script not found

```
bash: go-validation/scripts/validate.sh: No such file or directory
```

**Solutions**:
```bash
# Navigate to project root
cd /workspace

# Verify script exists
ls -la .github/skills/go-validation/scripts/validate.sh

# Run with full path
bash .github/skills/go-validation/scripts/validate.sh
```

### Issue: Permission denied

```
permission denied: go-validation/scripts/validate.sh
```

**Solutions**:
```bash
# Make executable
chmod +x .github/skills/go-validation/scripts/validate.sh

# Or run with bash explicitly
bash .github/skills/go-validation/scripts/validate.sh
```

### Issue: Command not found in script

```
line 42: golangci-lint: command not found
```

**Solutions**:
1. Install missing tool:
```bash
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```
2. Verify installation: `which golangci-lint`
3. Add to PATH if needed

## Summary

This troubleshooting guide covers common validation failures and their solutions. For normal development, always use the validation script first, then refer to this guide for specific error patterns.
