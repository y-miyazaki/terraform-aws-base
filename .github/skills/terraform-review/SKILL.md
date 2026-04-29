---
name: terraform-review
description: >-
  Reviews Terraform configurations for design decisions, security patterns, and best practices.
  Checks module structure, variable design, tagging, state management, and compliance requiring human judgment.
  Use when reviewing Terraform pull requests, evaluating infrastructure architecture, or assessing security of IaC code.
license: Apache-2.0
metadata:
  author: y-miyazaki
  version: "1.0.0"
---

## Input

- Terraform files (`.tf`) in the PR (required)
- PR description and linked issues (required)
- Related documentation (optional)
- Target environment: dev/staging/production

## Output Specification

**Output format (MANDATORY)** - Use this exact structure:

- Checks Summary: Total/Passed/Failed/Deferred counts
- Checks (Failed/Deferred Only): Show only ❌ and ⊘ items in checklist order
- Issues: Numbered list with full details for each failed or deferred item
- Use fixed ItemIDs from [references/common-checklist.md](references/common-checklist.md)
- If all pass: "No failed or deferred checks" / "No issues found"

See [references/common-output-format.md](references/common-output-format.md) for detailed format specification.

## Execution Scope

- Systematically apply review checklist from [references/common-checklist.md](references/common-checklist.md)
- Focus only on checks requiring human/AI judgment (design, security, compliance patterns)
- **Do not run terraform-validation or execute terraform fmt/validate/tflint/trivy**
- Do not modify Terraform files or approve/merge PRs
- AWS-based Terraform (other providers may need adjustment)

## Reference Files Guide

**Standard Components** (always read):

- [common-checklist.md](references/common-checklist.md) - Complete review checklist with ItemIDs
- [common-output-format.md](references/common-output-format.md) - Report format specification

**Category Details** (read when reviewing related code):

- [category-compliance.md](references/category-compliance.md) - Read when reviewing OPA policies or compliance standards
- [category-cost.md](references/category-cost.md) - Read when reviewing resource sizing, lifecycle policies, or cost optimization
- [category-data-sources.md](references/category-data-sources.md) - Read when reviewing data source usage or imports
- [category-dependency.md](references/category-dependency.md) - Read when reviewing depends_on or implicit dependencies
- [category-events.md](references/category-events.md) - Read when reviewing monitoring, alerting, or logging patterns
- [category-global.md](references/category-global.md) - Read when reviewing module usage, secrets, or for_each patterns
- [category-migration.md](references/category-migration.md) - Read when reviewing import strategies or state migration
- [category-modules.md](references/category-modules.md) - Read when reviewing module structure or provider versions
- [category-naming.md](references/category-naming.md) - Read when reviewing naming conventions or documentation
- [category-outputs.md](references/category-outputs.md) - Read when reviewing output design or sensitive data handling
- [category-patterns.md](references/category-patterns.md) - Read when reviewing design patterns or anti-patterns
- [category-performance.md](references/category-performance.md) - Read when reviewing API limits, parallel execution, or large-scale configs
- [category-security.md](references/category-security.md) - Read when reviewing encryption, IAM, resource policies, or VPC security
- [category-state.md](references/category-state.md) - Read when reviewing state management or backend configuration
- [category-tagging.md](references/category-tagging.md) - Read when reviewing tag consistency or requirements
- [category-tfvars.md](references/category-tfvars.md) - Read when reviewing tfvars, secret handling, or environment separation
- [category-variables.md](references/category-variables.md) - Read when reviewing variable types, defaults, or validation
- [category-versioning.md](references/category-versioning.md) - Read when reviewing versioning strategies

## Workflow

1. **Understand Context** - Read PR description, linked issues, and determine target environment
2. **Systematic Review** - Apply checklist categories relevant to the changes, loading reference files as needed
3. **Report Issues** - Output in the format below

## Output Format

```markdown
# Terraform Code Review Result

## Checks Summary

- Total checks: 42
- Passed: 41
- Failed: 1
- Deferred: 0

## Checks (Failed/Deferred Only)

- G-02 Secret Hardcoding Prohibition: ❌ Fail

## Issues

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

## Best Practices

- **Constructive and specific**: Include code examples and reference links
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Note AWS context**: AWS-specific checks may need adjustment for other cloud environments
