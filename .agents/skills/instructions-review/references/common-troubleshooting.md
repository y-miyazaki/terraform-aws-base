# Common Troubleshooting Guide

This document lists frequent issues found during instructions file reviews and their recommended fixes.

## Issue 1: Inconsistent Chapter Order

**Problem**: Testing and Validation is nested inside Guidelines

**Root Cause**: Testing and Validation written as an H3 under `## Guidelines` instead of its own H2 chapter

**Fix**: Promote it to an H2 chapter placed after Guidelines and before Security Guidelines

**Example**:

```markdown
<!-- ❌ Incorrect -->

## Guidelines

### Testing and Validation

<!-- ✅ Correct -->

## Guidelines

### Code Modification Guidelines

## Testing and Validation

## Security Guidelines
```

Related checklist IDs: STRUCT-01, STRUCT-02, STRUCT-03

## Issue 2: Always-On Validation Recipes in Instructions

**Problem**: Testing and Validation embeds `validate.sh` / linter command catalogs or "hooks handle it, skip lint" text

**Root Cause**: Treating always-on instructions as the validation launcher

**Fix**: Keep at most an on-demand skill pointer; put executable recipes in validation skills; rely on Agent hooks/pre-commit for automated lint

**How to Check**:

1. Confirm no "after every change, run …" lint mandates
2. Confirm no hook-skip explanations
3. Confirm any skill pointer is one short line without recipe blocks

Related checklist IDs: TEST-01, TEST-02, STRUCT-07

## Issue 3: Missing Security Guidelines Chapter

**Problem**: Security chapter does not exist

**Root Cause**: Incomplete template usage

**Fix**: Add the chapter and limit it to document-safety risks that automated scanners cannot detect (SEC-03)

**Topics to cover**:

- Secrets policy: no secrets in instruction files; point to environment variables or a secret manager (SEC-02)
- Risks tools cannot detect: unsafe defaults, destructive command defaults, untrusted link sources, privilege assumptions (SEC-01)
- Do not restate rules that secret scanners or CI already enforce (SEC-03)

Related checklist IDs: STRUCT-01, SEC-01, SEC-02

## Issue 4: Inconsistent Documentation Level

**Problem**: Chapter coverage or format differs from peer instruction files in the same repository

**Root Cause**: Insufficient review against peer files

**Fix**: Align coverage and format with peers without adding always-on bulk

**How to Standardize**:

1. Compare chapter and subsection coverage with peer instruction files
2. Add only missing non-obvious, project-specific content (STD-01); do not pad thin sections to match peer length
3. Keep Guidelines as ItemID title bullets; full Check/Why/Fix stays in review `category-*.md` (STD-05)
4. Add code examples only where the domain needs one, and keep them minimal (QUAL-01, QUAL-03)

Related checklist IDs: STD-03, CONS-02, QUAL-01

## Issue 5: Output Report Format Drift

**Problem**: Review output format differs from the canonical contract

**Root Cause**: Reviewer used ad-hoc reporting instead of `common-output-format.md`

**Fix**:

1. Reformat report using `references/common-output-format.md`
2. Ensure failed/deferred items use fixed ItemIDs from `references/common-checklist.md`
3. Keep passed checks only in summary counts

Related checklist IDs: QUAL-02, CONS-02
