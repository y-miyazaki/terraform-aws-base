# GitHub PR Body Checklist

## Pre-conditions

- PRECOND-01: Target PR exists and is accessible via `gh pr view`
- PRECOND-02: `gh` CLI is authenticated (`gh auth status` returns 0)
- PRECOND-03: Script at `scripts/github/update-pr-body.sh` is executable

## Execution Steps

- STEP-01: Fetch current PR body from GitHub (`gh pr view --json body`)
- STEP-02: Classify file changes by type (Terraform, Go, workflow, docs, etc.)
- STEP-03: Generate `## Overview` content (or use `--overview-file` if provided)
- STEP-04: Generate `## Changes` list with file classifications
- STEP-05: Update PR body via `gh pr edit --body`

## Output Verification

- OUT-01: `## Overview` section is present and non-empty
- OUT-02: `## Changes` section is present with at least one entry
- OUT-03: Other existing PR body sections are preserved unchanged
- OUT-04: Operation is idempotent (re-running produces the same result)

See [common-output-format.md](common-output-format.md) for PR body output structure.
