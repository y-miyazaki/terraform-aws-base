---
name: go-review
description: Go code review for correctness, security, performance, and best practices. Use for manual review of Go code checking design decisions and patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Go Code Review

This skill provides comprehensive guidance for reviewing Go code to ensure correctness, security, performance, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Go pull requests
- Checking Go code before merging
- Ensuring security and best practices adherence
- Validating design decisions and architecture patterns
- Performance and concurrency review

**Note**: Linting and auto-checkable items (syntax errors, formatting, golangci-lint) are excluded from this review as they should be caught by validation scripts or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the purpose of the changes
- Check if this is new feature, bug fix, or refactoring
- Review related tests and documentation updates

### Step 2: Automated Checks First

Verify automated validation has passed:

- `go fmt`
- `go vet`
- `golangci-lint`
- `go test -race -cover`
- `govulncheck`

If automated checks fail, request fixes before manual review.

### Step 3: Systematic Review

Review categories systematically based on the changes. Use the reference documentation for detailed checks in each category.

### Step 4: Report Issues

Report issues following the Output Format below, including only failed checks with specific recommendations.

## Output Format

Review results must be output in structured format:

### Output Elements

1. **Checks** (Review items checklist)
   - Display only failed review items
   - Format: `ItemID ItemName: ❌ Fail`
   - Purpose: Highlight issues requiring attention
   - If all checks pass, output "No issues found"

2. **Issues** (Detected problems)
   - Display details for each failed item
   - Numbered list format for each problem
   - Each issue includes:
     - Item ID + Item Name
     - File: file path and line number
     - Problem: Description of the issue
     - Impact: Scope and severity
     - Recommendation: Specific fix suggestion with code example

### Output Format Example

```markdown
# Go Code Review Result

## Checks

- ERR-01 Error Wrapping: ❌ Fail

## Issues

**No issues found** (if all checks pass)

**OR**

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

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: Package structure, imports, naming basics → [reference/global.md](reference/global.md)
**Context Handling**: context.Context propagation, timeout, cancellation → [reference/context.md](reference/context.md)
**Concurrency**: Goroutines, channels, mutexes, race conditions → [reference/concurrency.md](reference/concurrency.md)
**Code Standards**: Naming, style, idioms, simplicity → [reference/code-standards.md](reference/code-standards.md)
**Function Design**: Function signatures, parameters, return values → [reference/function-design.md](reference/function-design.md)
**Error Handling**: Error types, wrapping, sentinel errors → [reference/error-handling.md](reference/error-handling.md)
**Security**: Input validation, crypto, SQL injection, secrets → [reference/security.md](reference/security.md)
**Performance**: Allocations, string concatenation, preallocation → [reference/performance.md](reference/performance.md)
**Testing**: Test structure, table-driven tests, mocking, coverage → [reference/testing.md](reference/testing.md)
**Architecture**: Package design, interfaces, dependency injection → [reference/architecture.md](reference/architecture.md)
**Documentation**: godoc, comments, examples → [reference/documentation.md](reference/documentation.md)
**Dependencies**: Module management, versioning, security → [reference/dependencies.md](reference/dependencies.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and common patterns
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use serena for project structure, grep_search for patterns
- **Prioritize automation**: Avoid excessive focus on syntax errors and go fmt/vet/golangci-lint
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Respect Go idioms**: Follow Effective Go and common patterns

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 12 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
