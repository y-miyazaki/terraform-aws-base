---
name: diagram-as-code-validation
description: >-
  Validates AWS Diagram as Code (DAC) YAML files for syntax and structure using yamllint and
  awsdac. Generates PNG architecture diagrams from YAML definitions. Use when editing DAC YAML
  files, generating AWS architecture diagrams, or validating diagram structure before commit.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- DAC YAML file(s) - AWS architecture diagram definitions (required)
- Output PNG filename (required for generation)
- yamllint configuration file (`.yamllint`) (optional)
- Environment identifier for multi-environment diagrams (dev/stg/prd) (optional)

## Output Specification

Structured validation results and generated artifacts: yamllint → awsdac → file verification.

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- **Always use `scripts/validate.sh`** for comprehensive validation. Do not run individual commands.
- Script executes yamllint and awsdac in recommended order
- **Do not modify YAML files automatically**
- Only generates PNG format diagrams

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Validation checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

## Workflow

**Always use the validation script. Do not run individual commands.**

```bash
# Full validation of all DAC files
bash diagram-as-code-validation/scripts/validate.sh

# Validate specific YAML file
bash diagram-as-code-validation/scripts/validate.sh ./aws_architecture_diagram.yaml

# Validate specific directory
bash diagram-as-code-validation/scripts/validate.sh ./diagrams/
```

### What the Script Does

1. **yamllint** - YAML syntax validation
2. **awsdac** - Diagram generation and structure verification
3. **File verification** - Output confirmation and integrity check

Detailed command options for troubleshooting are in [references/common-individual-commands.md](references/common-individual-commands.md).

## Output Format

```
✓ YAML syntax valid
✓ Diagram generated: diagram.png (XXX KB)
✓ File type: PNG image data
```

## Best Practices

- Run validation before every DAC commit
- Verify generated PNG visually after validation passes
- All resource links must be valid (no dangling references)
- Canvas hierarchy must be correct
