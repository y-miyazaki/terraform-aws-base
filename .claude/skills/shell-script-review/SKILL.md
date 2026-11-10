---
name: shell-script-review
description: >-
  Review shell scripts for security, correctness, maintainability, and Bats suite
  pairing (TEST-00) with emphasis on operational safety.
  Use when reviewing shell script PRs requiring judgment beyond static checks,
  including whether paired Bats suites were added or updated per TEST-00.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.2.1"
---

## Input

- Shell script files and PR context or file diffs (required)
- Related Bats suites paired with changed scripts when present (recommended for TEST-00)
- Validation output from the companion `shell-script-validation` report or CI (optional): used to skip tool-detectable checks

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md). That file is the source of truth for the output contract.

Each issue must include file path with line reference (`<path>#L<line>`), risk summary, and remediation guidance.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus on checks requiring human/AI judgment (design, security, error handling patterns)
- Do not modify script files or approve/merge PRs

### USE FOR:

- review shell-script PRs for judgment beyond static checks
- assess operational safety and script maintainability risks
- review security-sensitive script changes requiring judgment
- verify Bats suite pairing (TEST-00) against companion Bats rules (stem `bats`)

### DO NOT USE FOR:

- execute `bash -n`, `shellcheck`, or validation scripts
- perform auto-remediation in source files
- review non-shell-only changes with no script impact

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) (read on failure)
- [category-global.md](references/category-global.md) (always read)
- [category-security.md](references/category-security.md) (always read)
- [category-error-handling.md](references/category-error-handling.md) (always read)
- [category-anti-patterns.md](references/category-anti-patterns.md) (always read)
- [category-code-standards.md](references/category-code-standards.md) (always read)
- [category-dependencies.md](references/category-dependencies.md) (always read)
- [category-documentation.md](references/category-documentation.md) (always read)
- [category-function-design.md](references/category-function-design.md) (always read)
- [category-logging.md](references/category-logging.md) (always read)
- [category-testing.md](references/category-testing.md) (always read)

## Workflow

1. Read PR context and script intent. If PR context is unavailable, review file diffs only and defer PR-context-dependent checks.
2. Scope findings to changed files and hunks. Report violations in unchanged code outside the diff only under `## Expert Assessment`, not `## Issues`. For ad-hoc file review without a diff, treat the whole file as in scope.
3. Exclude generated files and vendored third-party code (for example vendored scripts copied from upstream) from primary findings unless they introduce security-critical risk.
4. For very large PRs (>50 changed shell scripts), prioritize security/correctness checks first and defer low-risk style checks if evidence is insufficient.
5. When validation output (companion `shell-script-validation` report or equivalent CI results) is supplied, do not re-report failures those tools detect: take the overlapping ItemID's status from the tool result, cite the tool, and spend the review on judgment checks. Category items with a validation `Note:` name the known overlaps.
6. Apply the full review checklist and collect failed/deferred ItemIDs.
7. Output required report sections per [references/common-output-format.md](references/common-output-format.md). Prioritize `SEC-*` findings first.

### Error Handling

| Condition                             | Severity    | Action                                                                                                |
| ------------------------------------- | ----------- | ----------------------------------------------------------------------------------------------------- |
| `common-checklist.md` unavailable     | Fatal       | Stop, report missing dependency                                                                       |
| `common-output-format.md` unavailable | Recoverable | Note missing file; emit `## Checks Summary`, `## Checks (Failed/Deferred Only)`, and `## Issues` only |
| PR contains only non-shell files      | Recoverable | Report "no reviewable shell scripts" and stop                                                         |

### Examples

- Prompt: `Review shell script changes for security and style`
- Result: Structured report per [references/common-output-format.md](references/common-output-format.md); include TEST-00 pairing judgment when scripts change.
