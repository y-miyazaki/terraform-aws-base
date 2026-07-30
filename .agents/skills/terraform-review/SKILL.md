---
name: terraform-review
description: >-
  Review Terraform quality, security, and architecture decisions.
  Use when reviewing Terraform PRs requiring judgment beyond automated checks across modules and environments.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.1"
---

## Input

- Terraform `.tf`/`.tfvars` files and PR context or file diffs (required)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Each issue must include file path, risk summary, and remediation guidance.

## Execution Scope

- Apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Do not modify Terraform files or approve/merge PRs
- Scope includes Terraform only; Terragrunt files are out of scope.
- Scope assumes a single repository context.
- Scope is provider-agnostic unless a referenced checklist item states provider-specific constraints.

### USE FOR:

- reviewing Terraform PRs for security, architecture, and module design issues
- assessing cross-module risks and environment-specific concerns in Terraform changes

### DO NOT USE FOR:

- executing validation tools (`terraform fmt`, `terraform validate`, `tflint`, `trivy`)
- implementing new Terraform resources as code changes

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-global.md](references/category-global.md) (always read)
- [category-security.md](references/category-security.md) (always read)
- [category-modules.md](references/category-modules.md) (always read)
- [category-state.md](references/category-state.md) (always read)
- [category-ci-lint.md](references/category-ci-lint.md) (always read)
- [category-compliance.md](references/category-compliance.md) (always read)
- [category-cost.md](references/category-cost.md) (always read)
- [category-data-sources.md](references/category-data-sources.md) (always read)
- [category-dependency.md](references/category-dependency.md) (always read)
- [category-events.md](references/category-events.md) (always read)
- [category-migration.md](references/category-migration.md) (always read)
- [category-naming.md](references/category-naming.md) (always read)
- [category-ordering.md](references/category-ordering.md) (always read)
- [category-outputs.md](references/category-outputs.md) (always read)
- [category-patterns.md](references/category-patterns.md) (always read)
- [category-performance.md](references/category-performance.md) (always read)
- [category-tagging.md](references/category-tagging.md) (always read)
- [category-tfvars.md](references/category-tfvars.md) (always read)
- [category-variables.md](references/category-variables.md) (always read)
- [category-versioning.md](references/category-versioning.md) (always read)

## Workflow

1. Read PR context and module scope.
2. If PR context is unavailable, review file diffs only and defer PR-context-dependent checks.
3. If changed files contain no `.tf` or `.tfvars`, return `status: skipped` with reason `no Terraform review target`.
4. Apply the full review checklist and collect failed/deferred items.
5. If a referenced category file is missing, defer affected checks with the missing file path.
6. Output required sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first, then correctness, then maintainability. For conflicting findings, prioritize the higher-severity category and document the conflict in `## Issues`.

### Error Handling

| Condition                                | Severity    | Action                                                                                                |
| ---------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `common-checklist.md` unavailable        | Fatal       | Stop; report missing dependency                                                                       |
| `common-output-format.md` unavailable    | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |
| Changed files contain no `.tf`/`.tfvars` | Recoverable | Return `status: skipped`; reason `no Terraform review target`                                         |
| Referenced category file missing         | Recoverable | Defer affected checks; note missing file path                                                         |

### Examples

- Prompt: `Review this Terraform PR and return failed/deferred checks only`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); do not run validators.
- Prompt: `Review this Terraform PR for security and module design`
- Result: Same output contract; evaluate from `.tf` source and PR context only — do not execute validator commands.
