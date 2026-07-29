# Terraform Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `terraform fmt` — formatting compliance
2. `terraform validate` — HCL syntax and schema validation
3. `tflint` — linting and provider-specific rule checks
4. `trivy config` — security misconfiguration scan

## terraform fmt (FMT)

- FMT-01 (SHOULD): All .tf files are formatted per `terraform fmt` standard
- FMT-02 (SHOULD): Consistent indentation (2-space) throughout
- FMT-03 (SHOULD): Argument alignment follows canonical style

## terraform validate (SYNTAX)

- SYNTAX-01 (SHOULD): HCL parses without errors
- SYNTAX-02 (SHOULD): All referenced variables and modules resolve
- SYNTAX-03 (SHOULD): Resource and data source schemas are valid
- SYNTAX-04 (SHOULD): No missing required arguments

## tflint (LINT)

- LINT-01 (SHOULD): All enabled rules pass with zero findings
- LINT-02 (SHOULD): AWS provider-specific rules pass
- LINT-03 (SHOULD): No deprecated resource types or argument names
- LINT-04 (SHOULD): Custom ruleset (`.tflint.hcl`) compliance verified

## trivy config (SEC)

- SEC-01 (SHOULD): No HIGH or CRITICAL severity misconfigurations
- SEC-02 (SHOULD): No hardcoded secrets detected
- SEC-03 (SHOULD): IAM policies comply with least-privilege principles
- SEC-04 (SHOULD): Suppressed findings have documented justifications

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
