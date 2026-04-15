---
name: github-actions-review
description: GitHub Actions Workflow code review for correctness, security, and best practices. Use for manual review of workflow files checking design decisions and security patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

## Purpose

Provide comprehensive guidance for reviewing GitHub Actions workflow configurations to ensure correctness, security, and best practices compliance.

## When to Use This Skill

Recommended usage:

- During pull request code review process
- Before merging workflow changes
- When evaluating security implications of workflow modifications
- For architecture and design review of complex workflows

## Input Specification

This skill expects:

- GitHub Actions Workflow YAML file(s) (required) - Files in `.github/workflows/` directory
- PR description and linked issues (required) - Context for understanding changes
- Related documentation (optional) - README or workflow documentation updates

Format:

- Workflow files: Target workflow files under review
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
- Reviewer reads workflow files and systematically applies review checklist items from [reference/common-checklist.md](reference/common-checklist.md)
- **Boundary**:
  - Focus only on checks that require human/AI judgment
  - Treat YAML/lint/security automation as out of scope for this review skill
  - Do not run github-actions-validation from this review skill
- **When to use**: For design decisions, security patterns, and best practices requiring judgment

**What this skill does**:

- Review workflow design decisions requiring human judgment
- Check security patterns (pull_request_target, secrets handling)
- Validate best practices adherence
- Assess performance optimizations (caching, parallelization)
- Verify error handling patterns
- Evaluate tool integration approaches

What this skill does NOT do (Out of Scope):

- Check YAML syntax errors (use actionlint for that)
- Validate runs-on or step names (use actionlint/yamllint for that)
- Execute actionlint/ghalint/zizmor commands from this review skill
- Test workflow execution
- Modify workflow files automatically
- Approve or merge pull requests
- Check non-workflow files in the PR
- Perform automated security scanning (use zizmor for that)

## Constraints

Prerequisites:

- PR context and workflow files are available
- PR description and context must be available
- Reviewer must have access to reference documentation

Limitations:

- Review focuses on design and security patterns, not syntax
- Cannot validate actual workflow execution behavior
- Assumes familiarity with GitHub Actions concepts
- Reference documentation required for detailed category checks

## Failure Behavior

Error handling:

- Missing PR context: Request PR description and linked issues, cannot proceed without context
- Invalid YAML syntax: Record as validation concern and continue reviewing judgment-based items when possible
- Inaccessible reference files: Output warning, proceed with available knowledge only
- Ambiguous security pattern: Flag as potential issue with recommendation to clarify intent

Error reporting format:

- Clear indication of blocking issues vs. recommendations
- Specific file paths and line numbers for all issues
- Code examples for recommended fixes
- References to official GitHub Actions documentation

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - GitHub Actions review checklist
- **common-output-format.md** - Review report format specification

**Category Details**:

- **category-best-practices.md** - Best practices detailed guide
- **category-error-handling.md** - Error handling patterns detailed guide
- **category-global.md** - Workflow-level configuration patterns detailed guide
- **category-performance.md** - Performance optimization guide
- **category-security.md** - Security checks detailed guide (SEC-01 through SEC-07)
- **category-tool-integration.md** - GitHub Actions tool integration patterns detailed guide

## Workflow

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the workflow purpose and trigger conditions
- Check if this is new workflow, enhancement, or bug fix
- Verify related documentation updates

### Step 2: Confirm Review Boundary

Focus on manual checks only:

- Trigger and permission design decisions
- Security-sensitive patterns requiring context-aware judgment
- Maintainability and operability tradeoffs

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
# GitHub Actions Workflow Code Review Result

## Checks Summary

- Total checks: 28
- Passed: 27
- Failed: 1
- Deferred: 0

## Checks (Failed/Deferred Only)

- SEC-03 Careful pull_request_target Usage: ❌ Fail

## Issues

**No issues found** (if all checks pass and there are no deferred checks)

**OR**

1. SEC-03: Careful Use of pull_request_target
   - File: `.github/workflows/ci.yml` L23
   - Problem: Using pull_request_target without proper protections
   - Impact: Arbitrary code execution and secret exposure from external PRs possible
   - Recommendation: Switch to pull_request or add fork validation in if conditions

2. PERF-02: Work Reduction with Caching
   - File: `.github/workflows/test.yml` L45-60
   - Problem: Dependencies fetched on every run without caching
   - Impact: Increased execution time and unnecessary network usage
   - Recommendation: Add actions/cache for dependency caching with appropriate restore-keys
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the workflow being reviewed.

**Checklist**: Complete review checklist → [reference/common-checklist.md](reference/common-checklist.md)
**Output Format Reference**: Canonical report template → [reference/common-output-format.md](reference/common-output-format.md)

**Global & Base**: Workflow names and triggers → [reference/category-global.md](reference/category-global.md)
**Error Handling**: continue-on-error patterns → [reference/category-error-handling.md](reference/category-error-handling.md)
**Tool Integration**: Actions and composite actions → [reference/category-tool-integration.md](reference/category-tool-integration.md)
**Security**: pull_request_target and secrets → [reference/category-security.md](reference/category-security.md)
**Performance**: Caching and parallelization → [reference/category-performance.md](reference/category-performance.md)
**Best Practices**: Reusability and maintainability → [reference/category-best-practices.md](reference/category-best-practices.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and official documentation references
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Prioritize automation**: Avoid excessive focus on actionlint/ghalint/zizmor

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
