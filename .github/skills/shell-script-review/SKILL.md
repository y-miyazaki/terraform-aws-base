---
name: shell-script-review
description: >-
  Reviews shell scripts for correctness, security, maintainability, and best practices.
  Checks error handling, input validation, common library usage, and function design requiring human judgment.
  Use when reviewing shell script pull requests, evaluating script security, or assessing bash code quality.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Shell script file(s) (`.sh`) in the PR (required)
- PR description and linked issues (required)
- Common library files (`lib/all.sh`) for project-specific patterns (optional)
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
- Focus only on checks requiring human/AI judgment (design, security, error handling patterns)
- **Do not run shell-script-validation or execute bash -n/shellcheck**
- Do not modify script files or approve/merge PRs

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

**Category Details** (read when reviewing related code):

- [category-code-standards.md](references/category-code-standards.md) - Read when reviewing naming, quoting, or script template compliance
- [category-dependencies.md](references/category-dependencies.md) - Read when reviewing external commands, version requirements, or aqua
- [category-documentation.md](references/category-documentation.md) - Read when reviewing function docstrings, usage examples, or comments
- [category-error-handling.md](references/category-error-handling.md) - Read when reviewing error_exit, cleanup trap, or error checking patterns
- [category-function-design.md](references/category-function-design.md) - Read when reviewing function structure, parameters, or return values
- [category-global.md](references/category-global.md) - Read when reviewing SCRIPT_DIR, lib/all.sh source, or basic structure
- [category-logging.md](references/category-logging.md) - Read when reviewing log_info, log_warn, or log_error usage
- [category-performance.md](references/category-performance.md) - Read when reviewing command efficiency, unnecessary forks, or pipelines
- [category-security.md](references/category-security.md) - Read when reviewing input validation, path traversal, or privilege escalation
- [category-testing.md](references/category-testing.md) - Read when reviewing unit tests, mock functions, or bats usage

## Workflow

### Step 1: Understand Context

Read PR description, understand script purpose, and identify the operational use case.

### Step 2: Automated Checks First

Confirm shell-script-validation has been run (`bash -n`, `shellcheck`). If execution is missing or failing, request rerun before semantic review.

### Step 3: Systematic Review

Apply checklist categories relevant to the changes, loading reference files as needed.

### Step 4: Report Issues

Output according to [references/common-output-format.md](references/common-output-format.md).

## Best Practices

- **Constructive and specific**: Include code examples and common library references
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Respect project standards**: Emphasize common library usage (lib/all.sh)
