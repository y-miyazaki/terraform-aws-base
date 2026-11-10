---
name: terraform-validation
description: >-
  Validate Terraform syntax, linting, and security with terraform fmt/validate, tflint, and trivy.
  Use when committing Terraform changes, running CI validation, or checking IaC security issues.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.1"
---

## Input

- Terraform path or directory (required)
- Validation script (required): `scripts/validate.sh` (run from the terraform-validation skill directory)
- `--fix` (optional): rewrites formatting with `terraform fmt` (and argument order with `--check-order`)
- `--verbose` (optional)
- `--check-order` (optional): run the argument order check (ORD-01) on top-level arguments of `resource`, `data`, and `module` blocks; requires `python3` and a `terraform_attr_order.py` helper next to `validate.sh`, which this skill does not bundle
- `--generate-docs` (optional): writes `README.md` in each Terraform module directory with `terraform-docs`; requires `terraform-docs`. Pass it only when the user asks for generated docs, because it changes files

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Structured results in the script's order: tflint, terraform validate, terraform fmt, argument order (with `--check-order`), trivy (`trivy fs <target> --format table`).

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script runs all checks in deterministic order and continues after a failing tool (no fail-fast).
- The trivy step runs `trivy fs` with trivy's default scanners (vulnerabilities and secrets) unless the repository configures trivy (for example a `trivy.yaml` that enables `misconfig`), and its findings do not fail the step. Report trivy findings as evidence for the reviewer; do not treat a passing trivy step as proof that no misconfigurations exist.
- **File changes:** `--fix` rewrites formatting (and argument order with `--check-order`); `--generate-docs` writes `README.md` files. Do not modify files otherwise.
- Individual commands are for debugging only (see [references/common-individual-commands.md](references/common-individual-commands.md)).

### USE FOR:

- run Terraform syntax/lint/security checks before commit
- reproduce CI validation failures locally
- validate a scoped Terraform directory during iterative changes

### DO NOT USE FOR:

- perform design and architecture review
- implement Terraform resource changes as a primary task
- validate non-Terraform files

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [common-individual-commands.md](references/common-individual-commands.md) (read on failure)
- [category-security.md](references/category-security.md) (read on failure)

## Workflow

1. Run `bash scripts/validate.sh`.
2. For scoped runs, pass one or more target directories: `bash scripts/validate.sh <terraform-dir>`.
3. Use `--fix` for formatting corrections and `--verbose` for diagnostics.
4. Retry at most 2 times after fixes; if checks still fail, return blocking findings and stop.

### Error Handling

| Condition                                                                                                                         | Severity    | Action                                                                                                               |
| --------------------------------------------------------------------------------------------------------------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------- |
| `scripts/validate.sh` missing                                                                                                     | Fatal       | Stop; report missing script                                                                                          |
| No `.tf` files under target path                                                                                                  | Info        | Report no reviewable Terraform; stop                                                                                 |
| Required binary missing (`terraform`, `tflint`, `trivy`; `python3` with `--check-order`; `terraform-docs` with `--generate-docs`) | Fatal       | Stop; report the missing binary; set `Status: ❌ FAIL`                                                               |
| `--check-order` fails with `can't open file ... terraform_attr_order.py`                                                          | Recoverable | Report argument order as `⊘ Skipped` (helper not bundled), not as an ORD-01 violation; leave ORD-01 to manual review |
| Single tool fails, others succeed                                                                                                 | Recoverable | Report every tool; mark the failed tool ❌ Fail with exit status                                                     |
| All tools fail                                                                                                                    | Fatal       | Set `Status: ❌ FAIL` with per-tool stderr summaries in `## Error Details`                                           |
| `common-checklist.md` unavailable                                                                                                 | Fatal       | Stop; report missing dependency                                                                                      |
| `common-output-format.md` unavailable                                                                                             | Recoverable | Note missing file; emit `## Summary`, `## Tool Results`, and `## Error Details` only                                 |

### Examples

- Prompt: `Validate Terraform fmt, validate, tflint, and trivy`
- Command: `bash scripts/validate.sh`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md). Additional invocations: [common-individual-commands.md](references/common-individual-commands.md) (read on debugging).
