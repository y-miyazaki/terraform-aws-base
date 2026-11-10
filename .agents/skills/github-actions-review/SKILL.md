---
name: github-actions-review
description: >-
  Review GitHub Actions workflows for correctness, security, and maintainability.
  Use when reviewing GitHub Actions workflow PRs, checking workflow security,
  evaluating CI/CD pipeline design, or assessing permissions and secret handling.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.1.1"
---

## Input

- Workflow YAML and/or composite action YAML (`action.yml`) and PR context or file diffs (required)
- Validation output from the companion `github-actions-validation` report or CI (optional): used to skip tool-detectable checks

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Each issue must include file path with line reference (`<path>#L<line>`), risk summary, and remediation guidance.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Do not modify workflow files or approve/merge PRs

### USE FOR:

- review workflow security and correctness with human judgment
- assess trigger design, permissions, and secrets handling
- review multi-workflow PRs for policy and maintainability risks

### DO NOT USE FOR:

- execute syntax/security validators (`actionlint`, `ghalint`, `zizmor`)
- auto-fix workflow YAML files
- replace deterministic workflow validation checks

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [category-global.md](references/category-global.md) (always read)
- [category-ordering.md](references/category-ordering.md) (always read)
- [category-security.md](references/category-security.md) (always read)
- [category-best-practices.md](references/category-best-practices.md) (always read)
- [category-error-handling.md](references/category-error-handling.md) (always read)
- [category-performance.md](references/category-performance.md) (always read)
- [category-tool-integration.md](references/category-tool-integration.md) (always read)
- [category-anti-patterns.md](references/category-anti-patterns.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)

## Workflow

1. Read PR context and workflow intent; extract events, `permissions`, secret usage, and external action references. If PR context is unavailable, review file diffs only and defer PR-context-dependent checks.
2. Scope findings to changed files and hunks. Report violations in unchanged code outside the diff only under `## Expert Assessment`, not `## Issues`. For ad-hoc file review without a diff, treat the whole file as in scope.
3. Exclude generated files and vendored third-party code (for example workflow files produced by a generator) from primary findings unless they introduce security-critical risk.
4. For very large PRs (>50 changed workflow or action files), prioritize security/correctness checks first and defer low-risk style checks if evidence is insufficient.
5. When validation output (companion `github-actions-validation` report or equivalent CI results) is supplied, do not re-report failures those tools detect: take the overlapping ItemID's status from the tool result, cite the tool, and spend the review on judgment checks. Category items with a validation `Note:` name the known overlaps.
6. Apply the full review checklist and collect failed/deferred items.
7. Output report with the required sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first, then correctness, then maintainability.

### Error Handling

| Condition                             | Severity    | Action                                                                                                |
| ------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `common-checklist.md` unavailable     | Fatal       | Stop, report missing dependency                                                                       |
| `common-output-format.md` unavailable | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |
| PR contains no workflow YAML files    | Recoverable | Report "no reviewable workflows" and stop                                                             |

### Examples

- Prompt: `Review workflow PR and report failed/deferred checks`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); each issue includes path, line, and remediation.
