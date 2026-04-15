---
name: shell-script-review
description: Shell Script code review for correctness, security, maintainability, and best practices. Use for manual review of shell scripts checking design decisions and security patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

## Purpose

Conducts code review of shell scripts for correctness, security, maintainability, and best practices using manual review of design decisions and security patterns.

This skill provides comprehensive guidance for reviewing Shell Script code to ensure correctness, security, maintainability, and best practices compliance.

## When to Use This Skill

Recommended usage:

- During pull request code review process
- Before merging shell script changes
- When evaluating security implications of script modifications
- For design review of complex scripts or error handling patterns
- When assessing common library usage compliance

## Input Specification

This skill expects:

- Shell script file(s) (required) - `.sh` files in the PR
- PR description and linked issues (required) - Context for understanding changes
- Common library files (optional) - lib/all.sh for project-specific patterns
- Related documentation (optional) - README or script documentation updates

Format:

- Shell scripts: Target shell script files with `.sh` extension
- PR context: Markdown text describing purpose and changes
- Optional validation context: Summary of validation outcomes when provided
- Common library: Bash source file with shared functions

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
- Reviewer reads shell scripts and systematically applies review checklist items from [reference/common-checklist.md](reference/common-checklist.md)
- **Boundary**:
  - Focus only on checks that require human/AI judgment
  - Treat syntax/static-analysis automation as out of scope for this review skill
  - Do not run shell-script-validation from this review skill
- **When to use**: For design decisions, security patterns, and best practices requiring judgment

**What this skill does**:

- Review design decisions and error handling patterns requiring human judgment
- Check security patterns (input validation, path traversal, privilege escalation)
- Validate common library usage (lib/all.sh functions)
- Assess error handling (error_exit, cleanup trap, error checking)
- Verify code standards (naming, quoting, script template compliance)
- Evaluate performance considerations (command efficiency, unnecessary forks)
- Review test quality and coverage
- Check documentation completeness

What this skill does NOT do (Out of Scope):

- Check syntax errors (use bash -n for that)
- Run static analysis (use shellcheck for that)
- Execute bash -n/shellcheck commands from this review skill
- Execute scripts for testing
- Modify script files automatically
- Approve or merge pull requests
- Review non-shell-script files in the PR
- Validate external command availability (use dependency checks for that)

## Constraints

Prerequisites:

- PR context and shell script files are available
- PR description and context must be available
- Reviewer must have access to reference documentation
- Common library (lib/all.sh) should be available for pattern validation

Limitations:

- Review focuses on design patterns and security, not syntax
- Cannot validate actual script execution behavior
- Assumes bash-based scripts (not sh, zsh, or other shells)
- Reference documentation required for detailed category checks
- Cannot detect runtime logic errors

## Failure Behavior

Error handling:

- Missing PR context: Request PR description and linked issues, cannot proceed without context
- Invalid bash syntax: Record as validation concern and continue reviewing judgment-based items when possible
- Inaccessible reference files: Output warning, proceed with available knowledge only
- Ambiguous security pattern: Flag as potential issue with recommendation to clarify intent or add validation

Error reporting format:

- Clear indication of blocking issues vs. recommendations
- Specific file paths and line numbers for all issues
- Code examples for recommended fixes using common library functions
- References to lib/all.sh or project standards when applicable

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Shell script review checklist
- **common-output-format.md** - Review report format specification

**Category Details**:

- **category-code-standards.md** - Code standards guide
- **category-dependencies.md** - Dependency management guide
- **category-documentation.md** - Documentation standards
- **category-error-handling.md** - Error handling patterns detailed guide
- **category-function-design.md** - Function design guide
- **category-global.md** - Overall design patterns
- **category-logging.md** - Logging standards guide
- **category-performance.md** - Performance optimization guide
- **category-security.md** - Security patterns detailed guide
- **category-testing.md** - Test design guide

## Workflow

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the script purpose and use case
- Check if this is new script, enhancement, or bug fix
- Verify related documentation updates

### Step 2: Confirm Review Boundary

Focus on manual checks only:

- Security patterns and misuse risks
- Error-handling design and script maintainability
- Project-specific conventions and architecture consistency

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
# Shell Script Code Review Result

## Checks Summary

- Total checks: 30
- Passed: 29
- Failed: 1
- Deferred: 0

## Checks (Failed/Deferred Only)

- SEC-01 Input Validation: ❌ Fail

## Issues

**No issues found** (if all checks pass and there are no deferred checks)

**OR**

1. SEC-01: Input Validation
   - File: `scripts/deploy.sh` L23
   - Problem: User input used directly in command without validation
   - Impact: Command injection risk
   - Recommendation: Validate input with regex patterns and allowlist confirmation

2. ERR-03: error_exit Usage
   - File: `scripts/backup.sh` L45
   - Problem: Using echo+exit 1 on error instead of common function
   - Impact: Inconsistent error handling, missing logging
   - Recommendation: Use `error_exit "backup failed"` instead
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: SCRIPT_DIR, lib/all.sh source, basic structure → [reference/category-global.md](reference/category-global.md)
**Code Standards**: Naming, quoting, script template compliance → [reference/category-code-standards.md](reference/category-code-standards.md)
**Function Design**: Function structure, parameters, return values → [reference/category-function-design.md](reference/category-function-design.md)
**Error Handling**: error_exit, cleanup trap, error checking → [reference/category-error-handling.md](reference/category-error-handling.md)
**Security**: Input validation, path traversal, privilege escalation → [reference/category-security.md](reference/category-security.md)
**Performance**: Command efficiency, unnecessary forks, pipelines → [reference/category-performance.md](reference/category-performance.md)
**Testing**: Unit tests, mock functions, bats usage → [reference/category-testing.md](reference/category-testing.md)
**Documentation**: Function docstrings, usage examples, comments → [reference/category-documentation.md](reference/category-documentation.md)
**Dependencies**: External commands, version requirements, aqua → [reference/category-dependencies.md](reference/category-dependencies.md)
**Logging**: log_info, log_warn, log_error usage → [reference/category-logging.md](reference/category-logging.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and common library references
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use serena for project structure, grep_search for patterns
- **Prioritize automation**: Avoid excessive focus on syntax errors and shellcheck
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Respect project standards**: Emphasize common library usage (lib/all.sh)
