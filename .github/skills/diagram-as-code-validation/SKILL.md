---
name: diagram-as-code-validation
description: Use yamllint and awsdac for DAC validation. This skill provides the validation workflow for AWS architecture diagrams. Detailed command options are for debugging only.
license: MIT
---

# Diagram as Code Validation

This skill provides guidance for validating Diagram as Code (DAC) YAML files and generating AWS architecture diagrams.

## When to Use This Skill

This skill is applicable for:

- Validating DAC YAML syntax
- Generating PNG diagrams from YAML
- Verifying diagram structure and correctness
- Ensuring all resources are properly linked
- Debugging diagram generation failures

## Validation Commands

### ⚠️ Required Validation Steps

**Always use these commands for validation.** Detailed command options below are for debugging specific failures.

Follow these steps to validate DAC files:

```bash
# 1. YAML syntax check
yamllint aws_architecture_diagram.yaml

# 2. Generate diagram
awsdac -d aws_architecture_diagram.yaml -o diagram.png

# 3. Verify output
file diagram.png
```

### When to Use Additional Command Options

Use detailed command options **only** for:

- Debugging specific validation failures
- Testing with custom configurations
- Batch processing multiple files

**For normal validation, use the required steps above.**

### Debugging Reference: Command Options

#### 1. YAML Syntax Check

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

#### 2. Generate Diagram

**Purpose**: Create PNG from YAML and validate structure

```bash
# Generate diagram
awsdac -d aws_architecture_diagram.yaml -o diagram.png

# Generate with specific environment
awsdac -d aws_architecture_diagram_prd.yaml -o diagram_prd.png
```

**What it validates**:

- All resources are reachable from Canvas
- Links have valid source and target
- Resource types are recognized
- Hierarchy is correct

#### 3. Verify Output

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

## Validation Checklist

### Structure Validation

- [ ] **YAML syntax is valid** - No yamllint errors
- [ ] **All Resources reachable from Canvas** - Proper hierarchy
- [ ] **Links have valid Source/Target** - All referenced resources exist
- [ ] **Titles are understandable** - Clear, descriptive names
- [ ] **Environment name in Region Title** - e.g., "ap-northeast-1 (Production)"
- [ ] **VPC/Subnet hierarchy is accurate** - Proper nesting

### Content Validation

- [ ] **Resource types are correct** - Match AWS service types
- [ ] **Links represent actual connections** - Accurate architecture
- [ ] **Stacks are properly organized** - Logical grouping
- [ ] **Labels are descriptive** - e.g., "HTTPS", "SQL"

## Common Validation Failures

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

## Validation Workflow

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

5. **Fix issues** - Adjust YAML as needed

6. **Regenerate** - Repeat until diagram is correct

7. **Commit** - Commit both YAML and PNG

## Generation Test

### Quick Test

```bash
# Generate to temporary file and verify
awsdac -d aws_architecture_diagram.yaml -o test.png && \
file test.png && \
rm -f test.png
```

### Full Test

```bash
# Generate all environment diagrams
for env in dev stg prd; do
    awsdac -d aws_architecture_diagram_${env}.yaml \
           -o aws_architecture_diagram_${env}.png
done
```

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

## Best Practices

### Validation Frequency

- Run `yamllint` after every YAML edit
- Generate PNG after structural changes
- Visual inspection before committing
- Regenerate all environments before release

## Security Validation

### Security Checklist

- [ ] No sensitive information in YAML
- [ ] No IP addresses or account IDs
- [ ] No internal hostnames
- [ ] Titles use generic names
- [ ] Diagram reviewed before public sharing

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

## Quick Reference

### Essential Commands

```bash
# Validate YAML
yamllint aws_architecture_diagram.yaml

# Generate diagram
awsdac -d aws_architecture_diagram.yaml -o diagram.png

# Quick test
awsdac -d aws_architecture_diagram.yaml -o test.png && \
file test.png && rm -f test.png
```

### Validation Checklist

Before committing:

- [ ] yamllint passes (`yamllint aws_architecture_diagram.yaml`)
- [ ] awsdac generates successfully (`awsdac -d ... -o ...`)
- [ ] Visual layout is clear
- [ ] No sensitive information
- [ ] Environment name in title

## Summary

DAC validation ensures accurate architecture diagrams:

1. **Validate YAML syntax** - Use `yamllint`
2. **Generate diagrams** - Use `awsdac`
3. **Visual inspection** - Verify correctness
4. **Check structure** - Ensure proper hierarchy
5. **Verify links** - Confirm connections
6. **Remove sensitive data** - Protect confidential information
7. **Validate before committing** - Never commit invalid diagrams
