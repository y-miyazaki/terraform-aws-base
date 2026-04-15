---
name: instructions-review
description: Instructions file review for structure, completeness, and consistency. Use for manual review of .instructions.md files checking content quality and standards compliance.
license: MIT
---

## Purpose

Reviews `.github/instructions/*.instructions.md` files for structure, completeness, consistency, and practical usability compliance.

This skill provides comprehensive guidance for reviewing `.github/instructions/*.instructions.md` files to ensure quality, consistency, and practical usability.

## When to Use This Skill

Recommended usage:

- During pull request review for instructions file changes
- Before merging new or updated instructions files
- When standardizing instructions files across the project
- For quality assurance of documentation
- When adding new instructions files to ensure consistency
- During periodic documentation audits

## Input Specification

This skill expects:

- Instructions file(s) (required) - `.github/instructions/*.instructions.md` files
- Reference files for comparison (optional) - go.instructions.md, github-actions-workflow.instructions.md
- aqua.yaml file (optional) - For optional tool coverage context
- PR description and context (optional) - Understanding purpose of changes

Format:

- Instructions files: Markdown with YAML front matter (applyTo, description)
- aqua.yaml: YAML file listing all project tools
- Reference files: Existing instructions files for consistency comparison

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
- Reviewer reads .instructions.md files and systematically applies review checklist items from reference/checklist.md
- **Boundary**: Focus on quality, structure, consistency, and practical usability checks that require human/AI judgment
- **Out-of-scope boundary**: Do not execute validation tools from this review skill
- **When to use**: Review .github/instructions/\*.instructions.md files for structure, completeness, consistency, and practical usability

**What this skill does**:

- Verify 4-chapter structure (Standards → Guidelines → Testing → Security)
- Check front matter completeness (applyTo, description)
- Validate naming conventions and tool standards documentation
- Verify validation commands are executable and comprehensive (minimum 3)
- Check security guidelines existence and completeness
- Assess consistency across all instructions files
- Validate tool coverage against aqua.yaml
- Review content quality (conciseness, examples, no redundancy)

What this skill does NOT do (Out of Scope):

- Modify instructions files automatically
- Execute validation commands to test them
- Review non-instructions files
- Check code quality in referenced files
- Validate tool configurations (use tool-specific validation for that)
- Approve or merge pull requests
- Generate new instructions files from scratch

**Key principles**:

- **Structure First**: All files must follow the 4-chapter structure (Standards → Guidelines → Testing and Validation → Security Guidelines)
- **Consistency Focus**: This skill emphasizes consistency across all instructions files
- **Practical Validation**: All validation commands must be executable with examples
- **Manual Review Required**: Structure, completeness, and cross-file consistency require human judgment

## Constraints

Prerequisites:

- Instructions files are available for review
- aqua.yaml is optional when checking tool coverage documentation
- Reference files (go.instructions.md, github-actions-workflow.instructions.md) should be available for consistency checks
- Reviewer must understand the 4-chapter structure requirement

Limitations:

- Cannot validate command execution behavior from this review skill
- Consistency checks require multiple files for comparison
- Tool coverage checks depend on optional aqua.yaml accuracy when provided
- Cannot assess technical accuracy of content (requires domain expertise)
- Line count ranges are guidelines, not strict requirements

## Failure Behavior

Error handling:

- Missing front matter: Flag as CRITICAL (G-01), cannot determine file scope
- Missing required chapter: Flag as CRITICAL (STRUCT-01), incomplete structure
- Insufficient validation commands (<3): Flag as IMPORTANT (TEST-02), inadequate coverage
- Missing security chapter: Flag as CRITICAL (STRUCT-01), security gap
- Inconsistent chapter order: Flag as IMPORTANT (CONS-01), reduces usability
- Missing aqua.yaml: Output info, skip optional tool coverage checks (TEST-05, COMP-03)

Error reporting format:

- Clear categorization: Critical (🔴), Important (🟡), Enhancement (🟢)
- Specific item IDs for tracking (G-01, STRUCT-01, TEST-02, FORMAT-01, CLARITY-01)
- Problem + Impact + Recommendation format for all issues
- Cross-references to reference files when applicable

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Instructions file review checklist
- **common-output-format.md** - Review report format specification
- **common-troubleshooting.md** - Frequent issues and recommended fixes

**Category Details**:

- **category-global.md** - General and Structure checks (G-01 to G-03, STRUCT-01 to STRUCT-03)
- **category-standards.md** - Standards Chapter checks (STD-01 to STD-03)
- **category-guidelines.md** - Guidelines Chapter checks (GUIDE-01 to GUIDE-08)
- **category-testing.md** - Testing and Validation checks (TEST-01 to TEST-06)
- **category-security.md** - Security Guidelines checks (SEC-01 to SEC-04)
- **category-quality.md** - Quality, Consistency, and Completeness checks (QUAL-01 to QUAL-04, CONS-01 to CONS-04, COMP-01 to COMP-04)

## Workflow

### Step 1: Verify Required Structure

Confirm all 4 required chapters exist in correct order:

1. Standards
2. Guidelines
3. Testing and Validation
4. Security Guidelines

### Step 2: Systematic Review by Category

Review systematically using priority levels:

- **🔴 Critical**: STRUCT, COMP (structure, completeness)
- **🟡 Important**: STD, GUIDE, TEST, SEC (content quality)
- **🟢 Enhancement**: QUAL, CONS (quality improvements, consistency)

### Step 3: Report Issues with Recommendations

Document issues using Check+Why+Fix format with actionable recommendations.

## Output Format

### Checks

Display condensed check status:

```
- Total checks: <number>
- Passed: <count>
- Failed: <count>
- Deferred: <count>

- <Failed/Deferred ItemID> <ItemName>: ❌/⊘
```

### Issues

Document failed or deferred items with full details:

1. **Item ID + Item Name**
   - Problem: Problem description
   - Impact: Impact scope and severity
   - Recommendation: Specific fix suggestion

### Examples

#### ✅ All Pass

```markdown
# Instructions Review Result

## Checks Summary

- Total checks: 26
- Passed: 24
- STRUCT-01 Four Required Chapters: ❌ Fail
- Failed: 2
- Deferred: 0

## Checks (Failed/Deferred Only)

- TEST-02 Command Count: ❌ Fail

## Issues

1. STRUCT-01 Four Required Chapters
   - Problem: Security Guidelines chapter missing
   - Impact: Missing security guidelines, incomplete standardization
   - Recommendation: Add Security Guidelines chapter covering secrets management and best practices

2. TEST-02 Command Count
   - Problem: Only 2 validation commands documented
   - Impact: Reduced test coverage, insufficient quality assurance
   - Recommendation: Review aqua.yaml and expand to minimum 3 items
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the instructions file being reviewed.

**Checklist**: Complete review checklist → [reference/common-checklist.md](reference/common-checklist.md)
**Output Format Reference**: Canonical report template → [reference/common-output-format.md](reference/common-output-format.md)
**Troubleshooting**: Frequent issues and fixes → [reference/common-troubleshooting.md](reference/common-troubleshooting.md)

**General & Structure**: Front Matter and chapter hierarchy → [reference/category-global.md](reference/category-global.md)
**Standards Chapter**: Naming conventions and tool standards → [reference/category-standards.md](reference/category-standards.md)
**Guidelines Chapter**: Documentation and modification procedures → [reference/category-guidelines.md](reference/category-guidelines.md)
**Testing & Validation**: Validation commands and tool coverage → [reference/category-testing.md](reference/category-testing.md)
**Security Guidelines**: Security items and secrets management → [reference/category-security.md](reference/category-security.md)
**Quality, Consistency & Completeness**: Content quality and cross-file consistency → [reference/category-quality.md](reference/category-quality.md)

## Best Practices

- **Reference Files**: Review go.instructions.md (222 lines) and github-actions-workflow.instructions.md (180 lines)
- **Minimum Standards**: 70+ lines, 3+ validation commands, 4 chapters required
- **Consistency Priority**: Prioritize consistency with existing files over new additions
- **Practical Focus**: Emphasize executable and practical content
- **Troubleshooting**: Refer to [reference/common-troubleshooting.md](reference/common-troubleshooting.md) for frequent issues
