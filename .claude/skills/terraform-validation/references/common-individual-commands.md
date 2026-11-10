# Terraform Validation - Individual Commands Reference

## For Debugging Only

Always prefer: `bash scripts/validate.sh`

## Commands

### terraform fmt

```bash
# Check formatting
terraform fmt -check

# Auto-format
terraform fmt -recursive
```

### terraform validate

```bash
terraform init
terraform validate
```

### tflint

```bash
tflint --recursive
```

### trivy

```bash
# What validate.sh runs (default scanners unless the repository configures trivy)
trivy fs <terraform-dir> --format table

# Misconfiguration-only scan that fails on HIGH/CRITICAL findings
trivy config --severity HIGH,CRITICAL --exit-code 1 <terraform-dir>
```

See [Troubleshooting Guide](common-troubleshooting.md) for detailed error resolution.
