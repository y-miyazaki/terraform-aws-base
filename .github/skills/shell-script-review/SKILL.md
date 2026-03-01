---
name: shell-script-review
description: Shell Script code review for correctness, security, maintainability, and best practices. Use for manual review of shell scripts checking design decisions and security patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Shell Script Code Review

This skill provides comprehensive guidance for reviewing Shell Script code to ensure correctness, security, maintainability, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on shell script pull requests
- Checking shell scripts before merging
- Ensuring security and best practices adherence
- Validating design decisions and error handling patterns
- Security and maintainability review

**Note**: This guide assumes bash-based shell scripts with common library usage (lib/all.sh).

**Note**: Linting and auto-checkable items (syntax errors, shellcheck warnings) are excluded from this review as they should be caught by validation scripts or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the script purpose and use case
- Check if this is new script, enhancement, or bug fix
- Verify related documentation updates

### Step 2: Automated Checks First

Verify automated validation has passed:

- `bash -n` (syntax check)
- `shellcheck` (static analysis)

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
# Shell Script Code Review Result

## Checks

- SEC-01 Input Validation: ❌ Fail

## Issues

**No issues found** (if all checks pass)

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

**Global & Base**: SCRIPT_DIR, lib/all.sh source, basic structure → [reference/global.md](reference/global.md)
**Code Standards**: Naming, quoting, script template compliance → [reference/code-standards.md](reference/code-standards.md)
**Function Design**: Function structure, parameters, return values → [reference/function-design.md](reference/function-design.md)
**Error Handling**: error_exit, cleanup trap, error checking → [reference/error-handling.md](reference/error-handling.md)
**Security**: Input validation, path traversal, privilege escalation → [reference/security.md](reference/security.md)
**Performance**: Command efficiency, unnecessary forks, pipelines → [reference/performance.md](reference/performance.md)
**Testing**: Unit tests, mock functions, bats usage → [reference/testing.md](reference/testing.md)
**Documentation**: Function docstrings, usage examples, comments → [reference/documentation.md](reference/documentation.md)
**Dependencies**: External commands, version requirements, aqua → [reference/dependencies.md](reference/dependencies.md)
**Logging**: log_info, log_warn, log_error usage → [reference/logging.md](reference/logging.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and common library references
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use serena for project structure, grep_search for patterns
- **Prioritize automation**: Avoid excessive focus on syntax errors and shellcheck
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Respect project standards**: Emphasize common library usage (lib/all.sh)

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 10 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
