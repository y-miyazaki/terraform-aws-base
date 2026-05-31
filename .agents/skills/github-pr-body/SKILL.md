---
name: github-pr-body
description: >-
  Update PR body content with deterministic baseline sections and optional full-body completion.
  Use when creating PRs or regenerating template-driven summaries.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- PR number and `owner/repo` (required)
- Existing PR template/body context (required)
- Authenticated `gh` environment (required)

## Output Specification

Return structured Markdown in accordance with [references/common-output-format.md](references/common-output-format.md).

Structured PR output:

- Baseline mode: update `## Overview` and `## Changes`.
- Full-body mode: apply complete body via `--body-file`.
- `## Changes` must classify files (Config/Docs/Feature/Test/Other) with line counts.
- Report selected mode and reason.

## Execution Scope

- **Always use `scripts/pr_body.sh` or `scripts/pr_fetch.sh`**. Do not run individual `gh` commands.
- `pr_body.sh` is deterministic and idempotent.

### USE FOR:

- generate deterministic baseline PR body sections
- regenerate PR body from template sections after code updates
- fill remaining sections in full-body mode from validated context

### DO NOT USE FOR:

- post review comments or resolve review threads
- create commits or modify source files
- replace issue triage workflows

## Reference Files Guide

- [common-checklist.md](references/common-checklist.md) (always read)
- [common-output-format.md](references/common-output-format.md) (always read)
- [common-troubleshooting.md](references/common-troubleshooting.md) - Read when fetching PR data or applying body updates fails unexpectedly.
- [category-change-classification.md](references/category-change-classification.md) - Read when classifying the PR change type.
- [category-pr-body-guidelines.md](references/category-pr-body-guidelines.md) - Read when applying PR body writing guidelines.
- [category-agent-workflows.md](references/category-agent-workflows.md) - Read when selecting baseline or full-body mode.
- [category-implementation-details.md](references/category-implementation-details.md) - Read when populating implementation detail sections.

## Workflow

1. Run `pr_fetch.sh` to collect PR metadata.
2. Run `pr_body.sh` to build deterministic baseline (`## Overview`, `## Changes`).
3. Select mode:

- Use baseline mode when request scope is summary refresh only.
- Use full-body mode when request explicitly asks to populate all template sections.

4. If full-body mode is selected, generate template-aligned content from validated context (PR metadata, changed file list, and template-required section headings); if baseline mode is selected, skip to Step 6.
5. If full-body mode is selected, apply full body with `pr_body.sh --body-file <FILE>`.
6. Confirm success by fetching PR body and verifying required sections are present for the selected mode.

