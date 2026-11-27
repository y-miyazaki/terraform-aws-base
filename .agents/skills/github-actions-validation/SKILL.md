---
name: github-actions-validation
description: >-
  Validate GitHub Actions workflows for syntax and security with ORD-01 map key order checks,
  actionlint, ghalint, and zizmor.
  Use when committing workflow changes, running CI validation, or checking workflow security issues.
argument-hint: "[workflows directory] [--verbose|--quiet]"
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.1"
---

## Input

- Validation script (required): `scripts/validate.sh`
- Workflows directory (optional): a path relative to the current directory or absolute (a path that does not exist is an error); scopes the ORD-01 map order check only. actionlint, ghalint, and zizmor always scan the whole repository (ghalint takes no path argument and reads `.github/workflows` of the repository root). Without it, the ORD-01 check covers git-tracked `.github/workflows/*.yml|yaml` and `.github/actions/**/action.yml|yaml`; untracked new files are not checked until they are added to git. With it, ORD-01 covers only YAML files under that directory, so composite actions are not checked
- `--verbose` / `--quiet` (optional)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Structured validation results from four tools: ORD-01 map order → actionlint → ghalint → zizmor. Attribute evidence to the producing tool.

## Execution Scope

- **Always use `scripts/validate.sh`** for the pass/fail result. Run an individual tool command only to investigate a tool the script reported as failed (see [references/common-individual-commands.md](references/common-individual-commands.md)).
- Script executes all tools in order and stops at the first failing tool (fail-fast); later tools are reported as `⊘ Skipped`.

### USE FOR:

- validate workflow changes before commit or merge
- rerun CI-equivalent local checks for workflow failures
- verify syntax and security findings from validation tools

### DO NOT USE FOR:

- judge workflow architecture or operational policy quality
- edit workflow files unless the user asked for fixes (Workflow step 4)
- validate non-workflow YAML files

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)
- [category-security.md](references/category-security.md) (always read)

## Workflow

1. Run `bash scripts/validate.sh` (or `bash scripts/validate.sh <workflows-dir>` to scope the ORD-01 check).
2. Parse script output and map results to checklist ItemIDs.
3. Report per-tool results (pass, fail, skipped) per [references/common-output-format.md](references/common-output-format.md).
4. If checks fail and the user asked for fixes, fix reported issues and rerun the same command; otherwise report the failures.
5. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Error Handling

| Condition                                                         | Severity    | Action                                                                                                                              |
| ----------------------------------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Workflows directory argument does not exist or is not a directory | Fatal       | The script exits with `Path does not exist` or `Path is not a directory`; pass a path relative to the current directory or absolute |
| `scripts/validate.sh` missing                                     | Fatal       | Stop; report missing script                                                                                                         |
| No workflow YAML under target path                                | Info        | The script still runs every tool; report each tool's result as printed                                                              |
| python3 / actionlint / ghalint / zizmor missing                   | Fatal       | Stop; report the missing binary; set `Status: ❌ FAIL`                                                                              |
| A tool fails                                                      | Recoverable | Report earlier tools as passed, the failed tool ❌ Fail with exit status, later tools `⊘ Skipped`                                   |
| `common-checklist.md` unavailable                                 | Fatal       | Stop; report missing dependency                                                                                                     |
| `common-output-format.md` unavailable                             | Recoverable | Note missing file; emit `## Summary`, `## Tool Results`, and `## Error Details` only                                                |

### Examples

- Prompt: `Validate workflows and report only failed checks with ItemIDs`
- Command: `bash scripts/validate.sh`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); attribute evidence to ORD-01, actionlint, ghalint, or zizmor.
