---
name: go-review
description: Go code review for correctness, security, performance, and best practices. Use for manual review of Go code checking design decisions and patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

## Purpose

Conducts code review of Go source files for correctness, security, performance, and best practices using manual review of design decisions and patterns.

This skill provides comprehensive guidance for reviewing Go code to ensure correctness, security, performance, and best practices compliance.

## When to Use This Skill

Recommended usage:

- During pull request code review process
- Before merging Go code changes
- When evaluating design decisions or architecture patterns
- For security review of sensitive code paths
- When assessing concurrency patterns or performance implications

## Input Specification

This skill expects:

- Go source code files (required) - `.go` files in the PR
- PR description and linked issues (required) - Context for understanding changes
- Related tests and documentation (optional) - Test files and README updates

Format:

- Go files: Target Go files under review
- PR context: Markdown text describing purpose and changes
- Optional validation context: Summary of validation outcomes when provided

## Output Specification

**Output format (MANDATORY)** - Use this exact structure:

- ## Checks Summary section: Total/Passed/Failed/Deferred counts
- ## Checks (Failed/Deferred Only) section: Show only ❌ and ⊘ items in checklist order
- ## Issues section: Numbered list with full details for each failed or deferred item
- Keep full evaluation data for all checks internally using fixed ItemIDs from reference/common-checklist.md
- If there are no failed or deferred checks: output "No failed or deferred checks" in Checks and "No issues found" in Issues

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- This skill provides manual review guidance requiring human/AI judgment
- Reviewer reads Go source files and systematically applies review checklist items from [reference/common-checklist.md](reference/common-checklist.md)
- **Boundary**:
  - Focus only on checks that require human/AI judgment
  - Treat formatting/lint/test/security automation as out of scope for this review skill
  - Do not run go-validation from this review skill
- **When to use**: For design decisions, concurrency patterns, and best practices requiring judgment

**What this skill does**:

- Review design decisions and architecture patterns requiring human judgment
- Check context.Context propagation and cancellation patterns
- Validate concurrency patterns (goroutines, channels, mutexes)
- Assess error handling and wrapping strategies
- Verify security patterns (input validation, crypto usage, SQL injection prevention)
- Evaluate performance considerations (allocations, string operations)
- Review test quality and coverage
- Check interface design and dependency injection

What this skill does NOT do (Out of Scope):

- Check syntax errors or formatting (use go fmt/vet for that)
- Run linters (use golangci-lint for that)
- Execute tests (use go test for that)
- Check for vulnerabilities (use govulncheck for that)
- Execute go fmt/go vet/golangci-lint/go test/govulncheck commands from this review skill
- Modify code files automatically
- Approve or merge pull requests
- Review non-Go files in the PR
- Perform runtime profiling or benchmarking

## Constraints

Prerequisites:

- PR context and Go files are available
- PR description and context must be available
- Reviewer must have access to reference documentation

Limitations:

- Review focuses on design patterns and best practices, not syntax
- Cannot validate actual runtime behavior or performance
- Assumes familiarity with Go idioms and Effective Go guidelines
- Reference documentation required for detailed category checks
- Test coverage analysis requires test execution results

## Failure Behavior

Error handling:

- Missing PR context: Request PR description and linked issues, cannot proceed without context
- Invalid Go syntax: Record as validation concern and continue reviewing judgment-based items when possible
- Inaccessible reference files: Output warning, proceed with available knowledge only
- Ambiguous design pattern: Flag as potential issue with recommendation to clarify intent or add comments

Error reporting format:

- Clear indication of blocking issues vs. recommendations
- Specific file paths and line numbers for all issues
- Code examples for recommended fixes following Go idioms
- References to Effective Go or official Go documentation

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Go code review checklist
- **common-output-format.md** - Review report format specification

**Category Details**:

- **category-architecture.md** - Architecture patterns detailed guide
- **category-code-standards.md** - Code standards guide
- **category-concurrency.md** - Concurrency patterns detailed guide
- **category-context.md** - Context usage patterns detailed guide
- **category-dependencies.md** - Dependency management guide
- **category-documentation.md** - Documentation standards
- **category-error-handling.md** - Error handling patterns detailed guide
- **category-function-design.md** - Function design guide
- **category-global.md** - Overall design patterns
- **category-performance.md** - Performance optimization guide
- **category-security.md** - Security patterns detailed guide
- **category-testing.md** - Test design guide

## Workflow

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the purpose of the changes
- Check if this is new feature, bug fix, or refactoring
- Review related tests and documentation updates

### Step 2: Confirm Review Boundary

Focus on manual checks only:

- Architecture and API design decisions
- Concurrency and cancellation safety patterns
- Error-handling quality and maintainability

Do not execute validation tools in this review workflow.

### Step 3: Systematic Review

Review categories systematically based on the changes. Use the reference documentation for detailed checks in each category.

### Step 4: Report Issues

Report issues following the Output Format below, using Checks Summary + Failed/Deferred-only Checks + full Issues details.

## Output Format

Review results must be output in structured format:

### Output Elements

1. **Checks** (Review items checklist)
   - Display `Checks Summary` with Total/Passed/Failed/Deferred counts
   - Display `Checks (Failed/Deferred Only)` for ❌ and ⊘ items only
   - Keep ItemIDs fixed and sorted in checklist order
   - If there are no failed or deferred checks, output "No failed or deferred checks"

2. **Issues** (Detected problems)
   - Display details for each failed or deferred item
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

## Checks Summary

- Total checks: 34
- Passed: 32
- Failed: 1
- Deferred: 1

## Checks (Failed/Deferred Only)

- ERR-01 Error Wrapping: ❌ Fail
- CTX-02 Context Timeout Handling: ⊘ Deferred (awaiting API timeout policy decision)

## Issues

**No issues found** (if all checks pass and there are no deferred checks)

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

**Global & Base**: Package structure, imports, naming basics → [reference/category-global.md](reference/category-global.md)
**Context Handling**: context.Context propagation, timeout, cancellation → [reference/category-context.md](reference/category-context.md)
**Concurrency**: Goroutines, channels, mutexes, race conditions → [reference/category-concurrency.md](reference/category-concurrency.md)
**Code Standards**: Naming, style, idioms, simplicity → [reference/category-code-standards.md](reference/category-code-standards.md)
**Function Design**: Function signatures, parameters, return values → [reference/category-function-design.md](reference/category-function-design.md)
**Error Handling**: Error types, wrapping, sentinel errors → [reference/category-error-handling.md](reference/category-error-handling.md)
**Security**: Input validation, crypto, SQL injection, secrets → [reference/category-security.md](reference/category-security.md)
**Performance**: Allocations, string concatenation, preallocation → [reference/category-performance.md](reference/category-performance.md)
**Testing**: Test structure, table-driven tests, mocking, coverage → [reference/category-testing.md](reference/category-testing.md)
**Architecture**: Package design, interfaces, dependency injection → [reference/category-architecture.md](reference/category-architecture.md)
**Documentation**: godoc, comments, examples → [reference/category-documentation.md](reference/category-documentation.md)
**Dependencies**: Module management, versioning, security → [reference/category-dependencies.md](reference/category-dependencies.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and common patterns
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use serena for project structure, grep_search for patterns
- **Prioritize automation**: Avoid excessive focus on syntax errors and go fmt/vet/golangci-lint
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Respect Go idioms**: Follow Effective Go and common patterns

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
