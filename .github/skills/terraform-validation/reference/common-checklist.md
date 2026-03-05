# Terraform Validation Checklist

## Syntax

- SYNTAX-01: terraform validate pass
- SYNTAX-02: Valid HCL syntax
- SYNTAX-03: No parsing errors
- SYNTAX-04: Resource syntax correct

## Formatting

- FMT-01: terraform fmt compliance
- FMT-02: Consistent indentation
- FMT-03: Proper spacing

## Linting

- LINT-01: tflint pass
- LINT-02: No style violations
- LINT-03: AWS provider rules pass
- LINT-04: Custom rules compliance

## Security

- SEC-01: trivy config pass
- SEC-02: No security issues
- SEC-03: No hardcoded secrets
- SEC-04: Policy compliance

## Module Validation

- MOD-01: Module syntax valid
- MOD-02: Variables defined
- MOD-03: Outputs valid
- MOD-04: Module references correct
