## Common Troubleshooting Guide

This document lists frequent issues found during instructions file reviews and their recommended fixes.

## Issue 1: Inconsistent Chapter Order

**Problem**: Testing and Validation is nested inside Guidelines

**Root Cause**: Incorrect chapter hierarchy in YAML frontmatter

**Fix**: Extract as independent chapter, place before Security Guidelines

**Example**:
```yaml
# ❌ Incorrect
- name: Guidelines
  sections:
    - Testing and Validation

# ✅ Correct
- name: Guidelines
  sections: [...]
- name: Testing and Validation
  sections: [...]
```

## Issue 2: Insufficient Validation Commands

**Problem**: Only 1-2 validation commands documented

**Root Cause**: Missing tools from aqua.yaml inventory

**Fix**: Review aqua.yaml and add all relevant tools (minimum 3 items)

**How to Check**:
1. Check `aqua.yaml` for available tools
2. Verify at least 3 validation commands documented
3. Include tool version and purpose for each

Related checklist IDs: TEST-01, TEST-02, TEST-05, COMP-03

## Issue 3: Missing Security Guidelines Chapter

**Problem**: Security chapter does not exist

**Root Cause**: Incomplete template usage

**Fix**: Add chapter covering secrets management and best practices

**Required Topics**:
- Secrets management (environment variables, config files)
- Credential handling
- Sensitive data patterns
- Security scanning tools

Related checklist IDs: STRUCT-01, SEC-01, SEC-02

## Issue 4: Inconsistent Documentation Level

**Problem**: Less detailed than other files

**Root Cause**: Insufficient review against peer files

**Fix**: Review other files and expand to equivalent detail level

**How to Standardize**:
1. Compare section lengths with peer instructions files
2. Check if all standard topics are covered
3. Expand thin sections to match peer detail level
4. Ensure consistent code example quality

Related checklist IDs: STD-03, CONS-03, QUAL-02

## Issue 5: Output Report Format Drift

**Problem**: Review output format differs from the canonical contract

**Root Cause**: Reviewer used ad-hoc reporting instead of `common-output-format.md`

**Fix**:
1. Reformat report using `references/common-output-format.md`
2. Ensure failed/deferred items use fixed ItemIDs from `references/common-checklist.md`
3. Keep passed checks only in summary counts

Related checklist IDs: QUAL-03, CONS-04
