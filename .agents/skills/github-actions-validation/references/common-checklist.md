# GitHub Actions Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `yaml_map_order.py check` — alphabetical map key order (ORD-01)
2. `actionlint` — YAML syntax and GitHub Actions schema validation
3. `ghalint` — GitHub Actions best practice and policy checks
4. `zizmor` — security-focused static analysis

## YAML map key order (ORD)

- ORD-01 (SHOULD): Map keys under `env`, `inputs`, `outputs`, `permissions`, `secrets`, and `with` are alphabetically ordered (ASCII / `LC_ALL=C`)

## actionlint (ACT)

- ACT-01 (SHOULD): Valid YAML structure and no parse errors
- ACT-02 (SHOULD): GitHub Actions schema fields are correct (on, jobs, steps)
- ACT-03 (SHOULD): Expression syntax (`${{ }}`) is valid
- ACT-04 (SHOULD): Runner labels are recognized
- ACT-05 (SHOULD): Job dependency (`needs`) references are resolvable

## ghalint (GH)

- GH-01 (SHOULD): Job-level permissions are explicitly scoped
- GH-02 (SHOULD): `actions/checkout` is present before code operations
- GH-03 (SHOULD): Workflow-level and job-level settings comply with policy
- GH-04 (SHOULD): No prohibited action patterns detected

## zizmor (ZIZ)

- ZIZ-01 (SHOULD): No script injection vulnerabilities (untrusted input in `run:`)
- ZIZ-02 (SHOULD): Third-party actions pinned to full commit SHA
- ZIZ-03 (SHOULD): No hardcoded secrets or tokens in workflow files
- ZIZ-04 (SHOULD): `pull_request_target` usage is safe from fork-based attacks

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
