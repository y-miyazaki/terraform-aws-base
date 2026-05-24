---
name: github-actions-validation
description: >-
  Validate GitHub Actions workflows for syntax and security with actionlint, ghalint, and zizmor.
  Use when committing workflow changes, running CI validation, or checking workflow security issues.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Workflow YAML in `.github/workflows/` (required)
- Validation script: `scripts/validate.sh` (required)
- Optional: specific directory path

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured validation results from three tools: actionlint → ghalint → zizmor.
Return `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` with tool-attributed evidence.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes all tools in order.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md))
- **Do not review workflow design decisions** (use github-actions-review for that)

### USE FOR:

- validate workflow changes before commit or merge
- rerun CI-equivalent local checks for workflow failures
- verify syntax and security findings from validation tools

### DO NOT USE FOR:

- judge workflow architecture or operational policy quality
- edit workflow files automatically
- validate non-workflow YAML files

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when validation fails unexpectedly
- [common-individual-commands.md](references/common-individual-commands.md) - Read when debugging a specific tool (actionlint/ghalint/zizmor)

**Category Details** (read when investigating specific failures):

- [category-security.md](references/category-security.md) - Read when zizmor or ghalint reports security issues

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <path>` for scoped validation).
2. Parse script output and map results to checklist ItemIDs.
3. Report failed/deferred items per [references/common-output-format.md](references/common-output-format.md).

### Examples

- Prompt: `Validate workflows and report only failed checks with ItemIDs.`
- Command: `bash scripts/validate.sh ./.github/workflows/`
- Output: failed/deferred checks mapped to `actionlint`, `ghalint`, or `zizmor`.

