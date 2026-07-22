---
name: github-actions-validation
description: >-
  Validate GitHub Actions workflows for syntax and security with actionlint, ghalint, and zizmor.
  Use when committing workflow changes, running CI validation, or checking workflow security issues.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.1"
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

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)
- [category-security.md](references/category-security.md) (always read)

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <path>` for scoped validation).
2. Parse script output and map results to checklist ItemIDs.
3. Report failed/deferred items per [references/common-output-format.md](references/common-output-format.md).

### Error Handling

| Condition                              | Severity    | Action                                                              |
| -------------------------------------- | ----------- | ------------------------------------------------------------------- |
| `scripts/validate.sh` missing          | Fatal       | Stop; report missing script                                         |
| No workflow YAML under target path     | Info        | Report no reviewable workflows; stop                                |
| actionlint / ghalint / zizmor missing  | Recoverable | Defer checks for that tool; note in `## Checks (Failed/Deferred Only)` |
| Single tool fails, others succeed      | Recoverable | Report passing tools; defer failed tool with exit status            |
| All tools fail                         | Fatal       | Return `status: failed` with per-tool stderr summaries               |
| `common-checklist.md` unavailable      | Fatal       | Stop; report missing dependency                                     |
| `common-output-format.md` unavailable  | Recoverable | Use inline output contract                                          |

### Examples

- Prompt: `Validate workflows and report only failed checks with ItemIDs.`
- Command: `bash scripts/validate.sh ./.github/workflows/`
- Output: failed/deferred checks mapped to `actionlint`, `ghalint`, or `zizmor`.
