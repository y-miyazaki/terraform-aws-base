---
name: github-actions-review
description: >-
  Reviews GitHub Actions workflow files for correctness, security, and best practices.
  Checks trigger design, secrets handling, permission scoping, and caching patterns requiring human judgment.
  Use when reviewing workflow pull requests, evaluating CI/CD security, or assessing GitHub Actions architecture.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- GitHub Actions workflow YAML file(s) in `.github/workflows/` (required)
- PR description and linked issues (required)
- Related documentation (optional)

## Output Specification

**Structured output (MANDATORY)** - Use this exact structure:

- Checks Summary: Total/Passed/Failed/Deferred counts
- Checks (Failed/Deferred Only): Show only ❌ and ⊘ items in checklist order
- Issues: Numbered list with full details for each failed or deferred item
- Use fixed ItemIDs from [references/common-checklist.md](references/common-checklist.md)
- If all pass: "No failed or deferred checks" / "No issues found"

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus only on checks requiring human/AI judgment (trigger design, security patterns)
- **Do not run github-actions-validation or execute actionlint/ghalint/zizmor**
- Do not modify workflow files or approve/merge PRs

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

**Category Details** (read when reviewing related code):

- [category-best-practices.md](references/category-best-practices.md) - Read when reviewing reusability, maintainability, or workflow structure
- [category-error-handling.md](references/category-error-handling.md) - Read when reviewing continue-on-error or failure handling patterns
- [category-global.md](references/category-global.md) - Read when reviewing workflow names, triggers, or permissions
- [category-performance.md](references/category-performance.md) - Read when reviewing caching, parallelization, or execution time
- [category-security.md](references/category-security.md) - Read when reviewing pull_request_target, secrets handling, or permission scoping
- [category-tool-integration.md](references/category-tool-integration.md) - Read when reviewing third-party actions or composite action patterns

## Workflow

### Step 1: Understand Context

Read PR description, understand workflow purpose, and verify trigger conditions.

### Step 2: Automated Checks First

Confirm github-actions-validation has been run (`actionlint`, `ghalint`, `zizmor`). If execution is missing or failing, request rerun before semantic review.

### Step 3: Systematic Review

Apply checklist categories relevant to the changes, loading reference files as needed.

### Step 4: Report Issues

Output according to [references/common-output-format.md](references/common-output-format.md).

## Best Practices

- **Constructive and specific**: Include code examples and official documentation references
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Prevent security oversights**: Pay special attention to SEC-\* items
