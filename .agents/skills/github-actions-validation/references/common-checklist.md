# GitHub Actions Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `actionlint` — YAML syntax and GitHub Actions schema validation
2. `ghalint` — GitHub Actions best practice and policy checks
3. `zizmor` — security-focused static analysis

## Checks by Tool

### actionlint
- ACT-01: Valid YAML structure and no parse errors
- ACT-02: GitHub Actions schema fields are correct (on, jobs, steps)
- ACT-03: Expression syntax (`${{ }}`) is valid
- ACT-04: Runner labels are recognized
- ACT-05: Job dependency (`needs`) references are resolvable

### ghalint
- GH-01: Job-level permissions are explicitly scoped
- GH-02: `actions/checkout` is present before code operations
- GH-03: Workflow-level and job-level settings comply with policy
- GH-04: No prohibited action patterns detected

### zizmor
- ZIZ-01: No script injection vulnerabilities (untrusted input in `run:`)
- ZIZ-02: Third-party actions pinned to full commit SHA
- ZIZ-03: No hardcoded secrets or tokens in workflow files
- ZIZ-04: `pull_request_target` usage is safe from fork-based attacks

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
