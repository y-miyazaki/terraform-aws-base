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

Structured PR output:

- Baseline mode: update `## Overview` and `## Changes`.
- Full-body mode: apply complete body via `--body-file`.
- `## Changes` must classify files (Config/Docs/Feature/Test/Other) with line counts.
- Report selected mode and reason.

## Execution Scope

- **Always use `scripts/pr_body.sh` or `scripts/pr_fetch.sh`**. Do not run individual `gh` commands.
- `pr_body.sh` is deterministic and idempotent.
- Semantic completion belongs to Step 3, not shell scripts.

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
- [troubleshooting](references/common-troubleshooting.md)
- [classification](references/category-change-classification.md)
- [guidelines](references/category-pr-body-guidelines.md)
- [workflows](references/category-agent-workflows.md)
- [implementation](references/category-implementation-details.md)

## Workflow

1. Run `pr_fetch.sh` to collect PR metadata.
2. Run `pr_body.sh` to build deterministic baseline (`## Overview`, `## Changes`).
3. Select mode:

- Use baseline mode when request scope is summary refresh only.
- Use full-body mode when request explicitly asks to populate all template sections.

4. For full-body output, generate template-aligned content from validated context (PR metadata, changed file list, and template-required section headings).
5. Apply full body with `pr_body.sh --body-file <FILE>`.
6. Confirm success by fetching PR body and verifying required sections are present.

## Error Handling and Troubleshooting

- If `pr_fetch.sh` fails, stop and return command output with auth/repository guidance.
- If PR is not found, return `status: failed` with PR number and repository.
- If full-body file generation fails, keep baseline update only and mark full-body step as deferred.
- If template is missing or malformed, apply baseline-only mode and return deferred reason for template-dependent sections.

## Best Practices

- Always start with `pr_fetch.sh`, then `pr_body.sh`
- Avoid individual `gh` commands unless debugging.
