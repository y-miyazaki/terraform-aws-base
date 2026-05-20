## Shell Script Validation - Individual Commands Reference

### ⚠️ For Debugging Only

Always prefer: `bash scripts/validate.sh`

## Commands

### bash -n
```bash
# Syntax check
bash -n script.sh
```

### shellcheck
```bash
# Static analysis
shellcheck script.sh

# With specific severity
shellcheck --severity=warning script.sh
```

See [Troubleshooting Guide](common-troubleshooting.md) for detailed error resolution.
