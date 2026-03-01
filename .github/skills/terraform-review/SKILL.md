---
name: terraform-review
description: Code review guide for Terraform configurations. Use for manual review of Terraform files checking design decisions requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Terraform Code Review

This skill provides comprehensive guidance for reviewing Terraform code to ensure correctness, security, maintainability, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Terraform pull requests
- Checking Terraform configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

**Note**: This guide assumes AWS-based Terraform usage. For Azure/GCP environments, some recommendations (especially in the Security section) may need adjustment.

**Note**: Linting and auto-checkable items (syntax errors, naming conventions, terraform fmt/validate, tflint, trivy) are excluded from this review as they should be caught by pre-commit hooks or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the purpose of the changes
- Check if this is new infrastructure or modification
- Verify which environment (dev/staging/production) is affected

### Step 2: Automated Checks First

Verify automated checks have passed:

- `terraform fmt -check`
- `terraform validate`
- `tflint`
- `trivy config`

If automated checks fail, request fixes before manual review.

### Step 3: Systematic Review

Review categories systematically based on the changes. Use the reference documentation for detailed checks in each category.

### Step 4: Report Issues

Report issues following the Output Format below, including only failed checks with specific recommendations.

## Output Format

Review results must be output in structured format:

### Output Elements

1. **Checks** (Review items checklist)
   - Display only failed review items
   - Format: `ItemID ItemName: ❌ Fail`
   - Purpose: Highlight issues requiring attention
   - If all checks pass, output "No issues found"

2. **Issues** (Detected problems)
   - Display details for each failed item
   - Numbered list format for each problem
   - Each issue includes:
     - Item ID + Item Name
     - File: file path and line number
     - Problem: Description of the issue
     - Impact: Scope and severity
     - Recommendation: Specific fix suggestion

### Output Format Example

```markdown
# Terraform Code Review Result

## Checks

- G-02 Secret Hardcoding Prohibition: ❌ Fail

## Issues

**No issues found** (if all checks pass)

**OR**

1. G-02: Secret Hardcoding Prohibition
   - File: `terraform/modules/api/main.tf` L45
   - Problem: Hardcoded password detected
   - Impact: Security risk, secrets in Git history
   - Recommendation: Use variable or AWS Secrets Manager

2. SEC-03: Resource Policy with Condition
   - File: `terraform/base/s3.tf` L12-15
   - Problem: S3 bucket policy missing condition clause
   - Impact: Potential unintended access permissions
   - Recommendation: Add `aws:SecureTransport` condition
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: Module usage, secrets, versioning, for_each patterns → [reference/global.md](reference/global.md)
**Modules**: Module structure, provider versions, responsibility → [reference/modules.md](reference/modules.md)
**Variables**: Type safety, defaults, descriptions, validation → [reference/variables.md](reference/variables.md)
**Outputs**: Description requirements, sensitive data → [reference/outputs.md](reference/outputs.md)
**Tfvars**: Secret handling, environment separation → [reference/tfvars.md](reference/tfvars.md)
**Security**: Encryption, IAM, resource policies, VPC → [reference/security.md](reference/security.md)
**Tagging**: Tag consistency and requirements → [reference/tagging.md](reference/tagging.md)
**Events & Observability**: Monitoring, alerting, logging → [reference/events.md](reference/events.md)
**Versioning**: Immutable versioning strategies → [reference/versioning.md](reference/versioning.md)
**Naming & Documentation**: Naming conventions, comments → [reference/naming.md](reference/naming.md)
**CI & Lint**: Pre-commit hooks, CI/CD integration → [reference/ci-lint.md](reference/ci-lint.md)
**Patterns**: Design patterns and anti-patterns → [reference/patterns.md](reference/patterns.md)
**State & Backend**: State management, backend configuration → [reference/state.md](reference/state.md)
**Compliance & Policy**: OPA policies, compliance standards → [reference/compliance.md](reference/compliance.md)
**Cost Optimization**: Resource sizing, lifecycle policies → [reference/cost.md](reference/cost.md)
**Performance & Limits**: API limits, parallel exec, large-scale → [reference/performance.md](reference/performance.md)
**Migration & Refactoring**: Import strategies, state migration → [reference/migration.md](reference/migration.md)
**Dependency & Ordering**: depends_on, implicit dependencies → [reference/dependency.md](reference/dependency.md)
**Data Sources & Imports**: Data source usage, imports → [reference/data-sources.md](reference/data-sources.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and reference links
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use context7 for module docs, serena for project structure
- **Prioritize automation**: Avoid excessive focus on syntax errors and terraform fmt/validate/tflint/trivy
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Note AWS context**: AWS-specific checks may need adjustment for other cloud environments

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 19 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
