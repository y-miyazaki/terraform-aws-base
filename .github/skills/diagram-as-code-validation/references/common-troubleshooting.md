## Diagram as Code Validation - Troubleshooting Guide

### yamllint Failures

**Issue**: YAML syntax or indentation error

**Fix**:
1. Correct indentation and mapping/list structure
2. Remove trailing spaces and invalid characters
3. Re-run `bash diagram-as-code-validation/scripts/validate.sh ./aws_architecture_diagram.yaml`

### awsdac Failures

**Issue**: Unknown resource type

**Fix**:
1. Replace with supported AWS DAC resource type
2. Verify capitalization and service naming

**Issue**: Invalid link endpoints

**Fix**:
1. Confirm each link source/target ID exists in resources
2. Update IDs to match declared resources exactly

**Issue**: Diagram generation failed

**Fix**:
1. Run manual command to isolate error: `awsdac -d <input.yaml> -o <output.png>`
2. Resolve reported schema/resource issues and retry

### File Verification Failures

**Issue**: PNG not generated or zero-byte output

**Fix**:
1. Check output path permissions
2. Re-run generation and validate with `file <output.png>`
3. Ensure prior steps (`yamllint`, `awsdac`) succeeded

### Revalidation

After applying fixes, run:

```bash
bash diagram-as-code-validation/scripts/validate.sh
```
