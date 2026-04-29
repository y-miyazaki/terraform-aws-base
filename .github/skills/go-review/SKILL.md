---
name: go-review
description: >-
  Reviews Go source code for correctness, security, performance, and best practices.
  Checks design decisions, concurrency patterns, and error handling requiring human judgment.
  Use when reviewing Go pull requests, evaluating architecture patterns, or assessing security of Go code.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Go source code files (`.go`) in the PR (required)
- PR description and linked issues (required)
- Related tests and documentation (optional)

## Output Specification

**Output format (MANDATORY)** - Use this exact structure:

- Checks Summary: Total/Passed/Failed/Deferred counts
- Checks (Failed/Deferred Only): Show only ❌ and ⊘ items in checklist order
- Issues: Numbered list with full details for each failed or deferred item
- Use fixed ItemIDs from [references/common-checklist.md](references/common-checklist.md)
- If all pass: "No failed or deferred checks" / "No issues found"

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus only on checks requiring human/AI judgment (design, concurrency, security patterns)
- **Do not run go-validation or execute go fmt/vet/golangci-lint/go test/govulncheck**
- Do not modify code files or approve/merge PRs

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

**Category Details** (read when reviewing related code):

- [category-architecture.md](references/category-architecture.md) - Read when reviewing package design, interfaces, or dependency injection
- [category-code-standards.md](references/category-code-standards.md) - Read when reviewing naming, style, or Go idioms
- [category-concurrency.md](references/category-concurrency.md) - Read when reviewing goroutines, channels, mutexes, or race conditions
- [category-context.md](references/category-context.md) - Read when reviewing context.Context propagation, timeout, or cancellation
- [category-dependencies.md](references/category-dependencies.md) - Read when reviewing go.mod, module versioning, or dependency changes
- [category-documentation.md](references/category-documentation.md) - Read when reviewing godoc comments or documentation updates
- [category-error-handling.md](references/category-error-handling.md) - Read when reviewing error types, wrapping, or sentinel errors
- [category-function-design.md](references/category-function-design.md) - Read when reviewing function signatures, parameters, or return values
- [category-global.md](references/category-global.md) - Read when reviewing package structure, imports, or naming basics
- [category-performance.md](references/category-performance.md) - Read when reviewing allocations, string operations, or preallocation
- [category-security.md](references/category-security.md) - Read when reviewing input validation, crypto usage, or SQL injection prevention
- [category-testing.md](references/category-testing.md) - Read when reviewing test structure, table-driven tests, or mocking

## Workflow

1. **Understand Context** - Read PR description, linked issues, and determine change type (feature/bugfix/refactor)
2. **Systematic Review** - Apply checklist categories relevant to the changes, loading reference files as needed
3. **Report Issues** - Output in the format below

## Output Format

```markdown
# Go Code Review Result

## Checks Summary

- Total checks: 34
- Passed: 32
- Failed: 1
- Deferred: 1

## Checks (Failed/Deferred Only)

- ERR-01 Error Wrapping: ❌ Fail
- CTX-02 Context Timeout Handling: ⊘ Deferred (awaiting API timeout policy decision)

## Issues

1. ERR-01: Error Wrapping
   - File: `pkg/service/processor.go` L45
   - Problem: Error string returned without stack trace
   - Impact: Difficult debugging, unable to identify error location
   - Recommendation: Wrap with `fmt.Errorf("failed to process: %w", err)`

2. CTX-01: Public API Context Handling
   - File: `internal/handler/api.go` L23
   - Problem: ProcessData function doesn't accept context.Context
   - Impact: No timeout control, no cancellation propagation, difficult testing
   - Recommendation: Change to `func ProcessData(ctx context.Context, data []byte) error`
```

## Best Practices

- **Constructive and specific**: Include code examples and common patterns
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Prevent security oversights**: Pay special attention to SEC-\* items
