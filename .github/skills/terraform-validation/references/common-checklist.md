# Terraform Validation Checklist

## Execution Order

Run tools in this order (fail-fast: stop on first failure):

1. `terraform fmt` — formatting compliance
2. `terraform validate` — HCL syntax and schema validation
3. `tflint` — linting and provider-specific rule checks
4. `trivy config` — security misconfiguration scan

## Checks by Tool

### terraform fmt
- FMT-01: All .tf files are formatted per `terraform fmt` standard
- FMT-02: Consistent indentation (2-space) throughout
- FMT-03: Argument alignment follows canonical style

### terraform validate
- SYNTAX-01: HCL parses without errors
- SYNTAX-02: All referenced variables and modules resolve
- SYNTAX-03: Resource and data source schemas are valid
- SYNTAX-04: No missing required arguments

### tflint
- LINT-01: All enabled rules pass with zero findings
- LINT-02: AWS provider-specific rules pass
- LINT-03: No deprecated resource types or argument names
- LINT-04: Custom ruleset (`.tflint.hcl`) compliance verified

### trivy config
- SEC-01: No HIGH or CRITICAL severity misconfigurations
- SEC-02: No hardcoded secrets detected
- SEC-03: IAM policies comply with least-privilege principles
- SEC-04: Suppressed findings have documented justifications

## Pass Criteria

- All tools exit with code 0
- No errors or warnings above configured thresholds
- See [common-output-format.md](common-output-format.md) for output structure
