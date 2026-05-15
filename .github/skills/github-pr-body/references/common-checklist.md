# GitHub PR Body Checklist

## Pre-conditions

- PRECOND-01: Target PR exists and is accessible via `gh pr view`
- PRECOND-02: `gh` CLI is authenticated (`gh auth status` returns 0)
- PRECOND-03: `.github/skills/github-pr-body/scripts/pr_body.sh` is executable

## Execution Steps

- STEP-01: Fetch current PR body from GitHub (`gh pr view --json body`)
- STEP-02: Classify file changes by type (Terraform, Go, workflow, docs, etc.)
- STEP-03: Generate deterministic `## Overview` content
- STEP-04: Generate `## Changes` list with file classifications
- STEP-05: Run AI completion for `## Testing`, `## Type of Change`, `## Checklist`, and `## Additional Notes` when template guidance is present
- STEP-06: Apply the completed body via `pr_body.sh --body-file`

## Output Verification

- OUT-01: `## Overview` section is present and non-empty
- OUT-02: `## Changes` section is present with at least one entry
- OUT-03: `## Testing`, `## Type of Change`, `## Checklist`, and `## Additional Notes` contain visible content when AI completion produced them
- OUT-04: Other existing PR body sections are preserved unchanged when not explicitly regenerated
- OUT-05: Operation is idempotent for deterministic baseline re-runs

See [common-output-format.md](common-output-format.md) for PR body output structure.
