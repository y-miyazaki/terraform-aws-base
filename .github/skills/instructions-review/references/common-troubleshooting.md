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

## Issue 3: Missing Security Guidelines Chapter

**Problem**: Security chapter does not exist

**Root Cause**: Incomplete template usage

**Fix**: Add chapter covering secrets management and best practices

**Required Topics**:
- Secrets management (environment variables, config files)
- Credential handling
- Sensitive data patterns
- Security scanning tools

## Issue 4: Inconsistent Documentation Level

**Problem**: Less detailed than other files

**Root Cause**: Insufficient review against peer files

**Fix**: Review other files and expand to equivalent detail level

**How to Standardize**:
1. Compare section lengths with peer instructions files
2. Check if all standard topics are covered
3. Expand thin sections to match peer detail level
4. Ensure consistent code example quality
