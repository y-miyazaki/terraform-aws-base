## Debugging Reference: Individual Commands

**Use these commands only when debugging validation failures.** For normal validation, always use `./scripts/validate.sh`.

### yamllint

**Purpose**: Verify YAML syntax is valid

```bash
# Check single file
yamllint aws_architecture_diagram.yaml

# Check all DAC files
yamllint aws_architecture_diagram*.yaml

# Check with specific config
yamllint -c .yamllint aws_architecture_diagram.yaml
```

**What it checks**:

- YAML syntax errors
- Indentation issues
- Invalid characters
- Structural problems

### awsdac

**Purpose**: Create PNG from YAML and validate structure

```bash
# Generate single diagram
awsdac -d aws_architecture_diagram.yaml -o diagram.png

# Generate with specific environment
awsdac -d aws_architecture_diagram_prd.yaml -o diagram_prd.png

# Batch generation
for env in dev stg prd; do
    awsdac -d aws_architecture_diagram_${env}.yaml \
           -o aws_architecture_diagram_${env}.png
done
```

**What it validates**:

- All resources are reachable from Canvas
- Links have valid source and target
- Resource types are recognized
- Hierarchy is correct

### File validation

**Purpose**: Confirm PNG was generated successfully

```bash
# Check file type
file diagram.png

# View file size
ls -lh diagram.png

# Open for visual inspection
open diagram.png  # macOS
xdg-open diagram.png  # Linux
```

## Troubleshooting Common Issues

### yamllint failures

**Common issues**:

- Indentation errors
- Missing colons
- Invalid YAML structure
- Trailing spaces

**Fix**: Correct YAML syntax according to error message

### awsdac generation failures

**Common issues**:

- Invalid resource references
- Missing required fields
- Incorrect resource types
- Broken hierarchy

**Fix**: Review error message and correct YAML structure

### Visual issues

**Common problems**:

- Resources overlapping
- Links crossing unnecessarily
- Poor layout
- Missing connections

**Fix**: Adjust resource positions or link types

## Manual Validation Workflow

### Before Committing

1. **Edit YAML** - Make diagram changes

2. **Check syntax**:

   ```bash
   yamllint aws_architecture_diagram.yaml
   ```

3. **Generate diagram**:

   ```bash
   awsdac -d aws_architecture_diagram.yaml -o diagram.png
   ```

4. **Visual inspection** - Open PNG and verify:
   - All resources are present
   - Connections are correct
   - Layout is clear
   - Labels are readable

5. **Fix issues** - Correct YAML according to error messages

6. **Regenerate** - Repeat until diagram is correct

7. **Commit** - Commit both YAML and PNG

## Quick Test

```bash
# Generate to temporary file and verify
awsdac -d aws_architecture_diagram.yaml -o test.png && \
file test.png && \
rm -f test.png
```

## Security Validation

### Security Checklist

- [ ] No sensitive information in YAML
- [ ] No IP addresses or account IDs
- [ ] No internal hostnames
- [ ] Titles use generic names

### Sensitive Information

**Avoid including**:

- Specific IP addresses
- AWS account IDs
- Internal domain names
- Proprietary service names
- Security group details

**Use instead**:

- Generic labels ("Private Subnet")
- Service types ("RDS Aurora")
- Standard ports ("443", "3306")
- General descriptions

## MCP Tool Usage

### Using awsdac-mcp-server

```bash
# 1. Get format information
mcp_awsdac-mcp-se_getDiagramAsCodeFormat

# 2. Generate diagram to file
mcp_awsdac-mcp-se_generateDiagramToFile

# 3. Get Base64 output (for display)
mcp_awsdac-mcp-se_generateDiagram
```
