# GitHub PR Body Checklist

## Pre-conditions (PRECOND)

- PRECOND-01 (SHOULD): Target PR exists and is accessible via `gh pr view`
- PRECOND-02 (SHOULD): `gh` CLI is authenticated (`gh auth status` returns 0)
- PRECOND-03 (SHOULD): `scripts/pr_body.sh` is executable

## Execution Steps (STEP)

- STEP-01 (SHOULD): Fetch current PR body from GitHub (`scripts/pr_fetch.sh`)
- STEP-02 (SHOULD): Keep the script's file classification (Config, Docs, Feature, Test, Other) in `## Changes`
- STEP-03 (SHOULD): Generate deterministic `## Overview` content
- STEP-04 (SHOULD): Generate `## Changes` list with file classifications
- STEP-05 (SHOULD): Run AI completion for every template H2 that carries guidance comments or examples (e.g. `## Testing`, `## Checklist`)
- STEP-06 (SHOULD): Apply the completed body via `pr_body.sh --body-file`

## Output Verification (OUT)

- OUT-01 (SHOULD): `## Overview` section is present and non-empty
- OUT-02 (SHOULD): `## Changes` section is present with at least one entry
- OUT-03 (SHOULD): Every template H2 that carries guidance comments or examples contains visible content after AI completion
- OUT-04 (SHOULD): Other existing PR body sections are preserved unchanged when not explicitly regenerated
- OUT-05 (SHOULD): Operation is idempotent for deterministic baseline re-runs

See [common-output-format.md](common-output-format.md) for PR body output structure.
