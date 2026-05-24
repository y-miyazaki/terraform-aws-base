---
name: terraform-review
description: >-
  Review Terraform quality, security, and architecture decisions.
  Use when reviewing Terraform PRs requiring judgment beyond automated checks across modules and environments.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Terraform `.tf`/`.tfvars` files and PR context or file diffs (required)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Return review output with `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues`.
Each issue must include file path, risk summary, and remediation guidance.

## Execution Scope

- Apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- **Do not run terraform-validation or execute terraform fmt/validate/tflint/trivy**
- Do not modify Terraform files or approve/merge PRs
- Scope includes Terraform only; Terragrunt files are out of scope.
- Scope assumes a single repository context.
- Scope is provider-agnostic unless a referenced checklist item states provider-specific constraints.

### USE FOR:

- review Terraform PRs using `terraform-validation` logs, or defer validator-dependent checks if logs are missing
- assess security, module design, and architecture trade-offs in Terraform changes
- evaluate cross-module risks across Terraform environments

### DO NOT USE FOR:

- run deterministic validators (`terraform fmt/validate`, `tflint`, `trivy`)
- implement new Terraform resources as code changes
- execute any CLI validation workflow as a substitute for this review skill

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [global](references/category-global.md), [security](references/category-security.md), [modules](references/category-modules.md), [state](references/category-state.md) - Read when reviewing resource structure, security, modules, or state management.
- [ci](references/category-ci-lint.md), [compliance](references/category-compliance.md), [cost](references/category-cost.md), [data](references/category-data-sources.md) - Read when reviewing CI integration, compliance, cost concerns, or data sources.
- [dependency](references/category-dependency.md), [events](references/category-events.md), [migration](references/category-migration.md), [naming](references/category-naming.md) - Read when reviewing dependencies, events, migration, or naming conventions.
- [outputs](references/category-outputs.md), [patterns](references/category-patterns.md), [perf](references/category-performance.md), [tagging](references/category-tagging.md) - Read when reviewing outputs, design patterns, performance, or tagging.
- [tfvars](references/category-tfvars.md), [variables](references/category-variables.md), [versioning](references/category-versioning.md) - Read when reviewing variable definitions, tfvars, or version constraints.
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read on failure or when evidence is unavailable

## Workflow

1. Read PR context and module scope.
2. Confirm `terraform-validation` results (stdout/stderr logs from `<agent-root>/skills/terraform-validation/scripts/validate.sh`); if missing, request rerun by posting: `Please run terraform-validation and share output logs.`, then defer validator-dependent checks.
3. If PR context is unavailable, review file diffs only and defer PR-context-dependent checks.
4. If changed files contain no `.tf` or `.tfvars`, return `status: skipped` with reason `no Terraform review target`.
5. If validation output is partial, keep available findings and defer missing-tool checks with explicit tool name.
6. Review checklist categories touched by changed files and collect failed/deferred items.
7. If a referenced category file is missing, defer affected checks with the missing file path.
8. Output required sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first, then correctness, then maintainability. For conflicting findings, prioritize the higher-severity category and document the conflict in `## Issues`.

### Examples

- Prompt: `Review this Terraform PR and return failed/deferred checks only.`
- Input context: changed files `terraform/env/prod/main.tf`, `terraform/env/prod/variables.tf`, `terraform/env/prod/terraform.tfvars`; validation log missing `tflint` output.
- Output sample: `## Checks Summary` with deferred count, `## Checks (Failed/Deferred Only)` including deferred `tflint` check with reason `missing terraform-validation output`, and `## Issues` ordered by `SEC-*`, correctness, maintainability.
- Prompt: `Review this Terraform PR and report security reasoning from existing validation logs.`
- Output sample: security findings are evaluated from existing logs and code context; no validator commands are executed.

