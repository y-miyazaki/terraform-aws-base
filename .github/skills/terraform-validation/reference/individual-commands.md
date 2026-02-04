# Terraform Validation - Individual Commands Reference

## ⚠️ For Debugging Only

Always prefer: `bash terraform-validation/scripts/validate.sh`

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

### trivy config
```bash
trivy config --severity HIGH,CRITICAL .
```

See [Troubleshooting Guide](troubleshooting.md) for detailed error resolution.
