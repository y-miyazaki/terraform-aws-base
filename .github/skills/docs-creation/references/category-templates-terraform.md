## Terraform Template Variants

Language-specific template variants. Use when the Terraform profile is detected.

Use these variants when Terraform profile is detected.

## specification_terraform

```markdown
# Terraform Specification

This document defines the repository behavior, module contracts, and environment-specific
configuration for Terraform-managed resources.

## Scope

<Describe covered stacks, environments, and exclusions.>

## Module Contracts

### `modules/<path>`

**Inputs**:

| Variable | Type     | Required | Default   | Description   |
| -------- | -------- | -------- | --------- | ------------- |
| `<var>`  | `<type>` | Yes/No   | `<value>` | <description> |

**Outputs**:

| Output     | Description   |
| ---------- | ------------- |
| `<output>` | <description> |

## Resource Specifications

| Resource Type | Name Pattern | Required Tags | Notes   |
| ------------- | ------------ | ------------- | ------- |
| `<aws_*>`     | `<pattern>`  | `<tags>`      | <notes> |

## Validation and Safety Checks

- `terraform fmt -check`
- `terraform validate`
- `<project specific checks>`

## Change Management

<Define plan/apply workflow, approval requirements, and rollback notes.>
```
