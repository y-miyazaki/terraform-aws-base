---
name: diagram-as-code-validation
description: Validates AWS Diagram as Code (DAC) YAML files using yamllint and awsdac. Use for syntax checking, diagram generation, and structure verification. Always use the 3-step validation workflow.
license: MIT
---

## Purpose

Validates AWS Diagram as Code (DAC) YAML files using yamllint and awsdac for syntax checking, diagram generation, and structure verification.

This skill provides guidance for validating Diagram as Code (DAC) YAML files and generating AWS architecture diagrams.

## When to Use This Skill

Recommended usage:

- After editing DAC YAML files
- Before committing diagram changes
- When generating diagrams for multiple environments
- For debugging diagram generation failures
- During architecture review processes

## Input Specification

This skill expects:

- DAC YAML file(s) (required) - AWS architecture diagram definitions
- Output PNG filename (required for generation)
- yamllint configuration file (optional) - `.yamllint` if custom rules needed
- Environment identifier (optional) - For multi-environment diagrams (dev/stg/prd)

Format:

- YAML file: Valid YAML syntax with DAC structure (Canvas, Resources, Links)
- Output filename: String ending in `.png`
- Environment: String identifier (e.g., "dev", "stg", "prd")

## Output Specification

Structured validation results and generated artifacts:

- yamllint output: List of syntax errors with line numbers, or success confirmation
- awsdac output: PNG diagram file or error messages with specific failure reasons
- file verification: File type confirmation and size information

Success output format:

```
✓ YAML syntax valid
✓ Diagram generated: diagram.png (XXX KB)
✓ File type: PNG image data
```

Error output format:

```
✗ yamllint: Line X: [error description]
✗ awsdac: [specific failure reason]
```

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- **Primary method**: Always use `scripts/validate.sh` for comprehensive validation
- Script executes yamllint and awsdac in recommended order with proper configuration
- **Manual invocation**: Individual tool commands available for debugging (see reference/troubleshooting.md)
- **Automated CI/CD**: Integrate validate.sh into CI pipeline for automated checks

**What this skill does**:

- Validate YAML syntax using yamllint
- Generate PNG diagrams from YAML using awsdac
- Verify diagram structure and resource hierarchy
- Check link validity (source/target references)
- Confirm output file generation

What this skill does NOT do (Out of Scope):

- Modify YAML files automatically
- Fix diagram layout issues
- Validate AWS resource configurations (use terraform-validation for that)
- Check actual AWS infrastructure state
- Generate diagrams in formats other than PNG
- Perform security scanning of AWS resources

## Constraints

Prerequisites:

- yamllint installed and available in PATH
- awsdac installed and available in PATH
- YAML file follows DAC structure (Canvas, Resources, Links)
- Write permission to output directory

Limitations:

- Only validates YAML syntax and DAC structure, not AWS resource validity
- PNG generation requires valid resource hierarchy from Canvas
- Large diagrams (>100 resources) may have layout issues
- MCP tool (awsdac-mcp-server) requires separate installation and may not be available

## Failure Behavior

Error handling:

- YAML syntax error: yamllint outputs error with line number, exit without diagram generation
- Invalid resource reference: awsdac outputs error message, no PNG created
- Missing required fields: awsdac outputs specific field error, no PNG created
- File write error: Output error message about permissions, no PNG created
- Invalid hierarchy: awsdac outputs reachability error, no PNG created

Error reporting format:

- Standard error output with specific error messages
- Exit code: 0=success, non-zero=error
- Error messages include line numbers and field names when applicable

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - DAC YAML validation checklist
- **common-output-format.md** - Validation result report format specification

## Validation Script Usage

**Always use the validation script. Do not run individual commands.**

### Usage

```bash
# Full validation of all DAC files
bash diagram-as-code-validation/scripts/validate.sh

# Validate specific YAML file
bash diagram-as-code-validation/scripts/validate.sh ./aws_architecture_diagram.yaml

# Validate specific directory
bash diagram-as-code-validation/scripts/validate.sh ./diagrams/
```

### What the Script Does

The validation script performs all checks in the correct order:

1. **yamllint** - YAML syntax validation
2. **awsdac** - Diagram generation and structure verification
3. **File verification** - Output confirmation and integrity check

## Validation Requirements

Before committing DAC changes:

- [ ] YAML syntax is valid (yamllint passes)
- [ ] Diagram generates successfully (awsdac passes)
- [ ] PNG output file created and verified
- [ ] All resource links are valid (no dangling references)
- [ ] Canvas hierarchy is correct

## Workflow

1. **Make changes** - Edit YAML DAC files
2. **Run validation**: `bash diagram-as-code-validation/scripts/validate.sh`
3. **Fix issues** - Address any YAML or structure errors
4. **Verify diagram** - Check generated PNG visually
5. **Commit** - Only when validation passes

Detailed command options for troubleshooting are in [reference/common-individual-commands.md](reference/common-individual-commands.md).
