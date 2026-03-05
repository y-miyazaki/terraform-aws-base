---
name: terraform-review
description: Terraform configuration code review for design decisions and best practices. Use for manual review of Terraform files checking design decisions requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

## Purpose

Conducts code review of Terraform configurations checking design decisions and best practices requiring human judgment.

Manual code review guidance for Terraform configurations, covering design decisions and patterns requiring human judgment.

## When to Use This Skill

Recommended usage:

- Performing code reviews on Terraform pull requests
- Checking Terraform configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review
- After automated checks (terraform fmt/validate/tflint/trivy) pass

## Input Specification

This skill expects:

- Terraform files (required) - `.tf` files in the PR
- PR description and linked issues (required) - Context for understanding changes
- Automated check results (required) - terraform fmt, terraform validate, tflint, trivy status
- Related documentation (optional) - README or Terraform documentation updates

Format:

- Terraform files: Valid HCL syntax
- PR context: Markdown text describing purpose and changes
- Check results: Pass/fail status from CI/CD pipeline or validation script
- Environment: Specify target environment (dev/staging/production)

## Output Specification

**Output format (MANDATORY)** - Use this exact structure:

- ## Checks section: List of failed review items only (ItemID ItemName: ❌ Fail)
- ## Issues section: Numbered list of detected problems with details
- Each issue includes: Item ID + Name, File path + line number, Problem description, Impact assessment, Specific recommendation with code example
- If all checks pass: "No issues found"

See reference/common-output-format.md for detailed format specification and examples.

## Execution Scope

**How to use this skill**:

- This skill provides manual review guidance requiring human/AI judgment
- Reviewer reads Terraform configurations and systematically applies review checklist items from [reference/common-checklist.md](reference/common-checklist.md)
- **Prerequisites**: Automated validation must pass before manual review
  - Run terraform-validation first to ensure fmt/validate/lint/security checks pass
- **When to use**: After automated checks pass, for design decisions, security patterns, and best practices requiring judgment

**What this skill does**:

- Review design decisions and architecture patterns requiring human judgment
- Check security patterns (encryption, IAM, resource policies, VPC)
- Validate module structure and responsibility separation
- Assess variable design (type safety, defaults, validation)
- Review output design and sensitive data handling
- Check tagging consistency and requirements
- Verify naming conventions and documentation completeness
- Assess monitoring, alerting, and logging patterns
- Review state management and backend configuration
- Check dependency ordering and implicit dependencies
- Evaluate design patterns and anti-patterns

What this skill does NOT do (Out of Scope):

- Check syntax errors (use terraform validate for that)
- Run linting (use tflint for that)
- Perform security scanning (use trivy config for that)
- Execute terraform plan or apply
- Modify Terraform files automatically
- Approve or merge pull requests
- Review non-Terraform files in the PR
- AWS-specific checks for non-AWS environments

## Constraints

Prerequisites:

- Automated checks (terraform fmt, terraform validate, tflint, trivy config) must pass before manual review
- Terraform files must have valid HCL syntax
- PR description and context must be available
- Reviewer must have access to reference documentation
- AWS-based Terraform (other providers may need adjustment)

Limitations:

- Review focuses on design patterns and best practices, not syntax
- Cannot validate actual AWS resource creation or behavior
- Assumes familiarity with Terraform best practices
- Reference documentation required for detailed category checks
- AWS-specific recommendations may need adjustment for other cloud providers

## Failure Behavior

Error handling:

- Automated checks failed: Request fixes before starting manual review, output message listing failed checks
- Missing PR context: Request PR description and linked issues, cannot proceed without context
- Invalid Terraform syntax: Refer to terraform validate or tflint errors, do not proceed with manual review
- Inaccessible reference files: Output warning, proceed with available knowledge only
- Ambiguous design decision: Flag as potential issue with recommendation to clarify intent or add comments

Error reporting format:

- Clear indication of blocking issues vs. recommendations
- Specific file paths and line numbers for all issues
- Code examples for recommended fixes
- References to patterns in reference documentation

## Reference Files Guide

When using this skill with an agent, reference the following files via @-mention for detailed guidance:

**Standard Components**:

- **common-checklist.md** - Terraform code review checklist
- **common-output-format.md** - Review report format specification

**Category Details**:

- **category-ci-lint.md** - tflint configuration checks detailed guide
- **category-compliance.md** - Compliance patterns detailed guide
- **category-cost.md** - Cost optimization guide
- **category-data-sources.md** - Data source design guide
- **category-dependency.md** - Resource dependency patterns detailed guide
- **category-events.md** - Event-driven architecture guide
- **category-global.md** - Module usage patterns detailed guide
- **category-migration.md** - Migration patterns detailed guide
- **category-modules.md** - Module structure guide
- **category-naming.md** - Naming conventions guide
- **category-outputs.md** - Output design guide
- **category-patterns.md** - Design patterns detailed guide
- **category-performance.md** - Performance optimization guide
- **category-security.md** - Security patterns detailed guide (encryption, IAM, policies, VPC security, S3 access control)
- **category-state.md** - State management best practices
- **category-tagging.md** - Tagging management guide
- **category-tfvars.md** - tfvars design guide
- **category-variables.md** - Variable design guide
- **category-versioning.md** - Versioning strategy guide

## Workflow

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

**Global & Base**: Module usage, secrets, versioning, for_each patterns → [reference/category-global.md](reference/category-global.md)
**Modules**: Module structure, provider versions, responsibility → [reference/category-modules.md](reference/category-modules.md)
**Variables**: Type safety, defaults, descriptions, validation → [reference/category-variables.md](reference/category-variables.md)
**Outputs**: Description requirements, sensitive data → [reference/category-outputs.md](reference/category-outputs.md)
**Tfvars**: Secret handling, environment separation → [reference/category-tfvars.md](reference/category-tfvars.md)
**Security**: Encryption, IAM, resource policies, VPC → [reference/category-security.md](reference/category-security.md)
**Tagging**: Tag consistency and requirements → [reference/category-tagging.md](reference/category-tagging.md)
**Events & Observability**: Monitoring, alerting, logging → [reference/category-events.md](reference/category-events.md)
**Versioning**: Immutable versioning strategies → [reference/category-versioning.md](reference/category-versioning.md)
**Naming & Documentation**: Naming conventions, comments → [reference/category-naming.md](reference/category-naming.md)
**CI & Lint**: Pre-commit hooks, CI/CD integration → [reference/category-ci-lint.md](reference/category-ci-lint.md)
**Patterns**: Design patterns and anti-patterns → [reference/category-patterns.md](reference/category-patterns.md)
**State & Backend**: State management, backend configuration → [reference/category-state.md](reference/category-state.md)
**Compliance & Policy**: OPA policies, compliance standards → [reference/category-compliance.md](reference/category-compliance.md)
**Cost Optimization**: Resource sizing, lifecycle policies → [reference/category-cost.md](reference/category-cost.md)
**Performance & Limits**: API limits, parallel exec, large-scale → [reference/category-performance.md](reference/category-performance.md)
**Migration & Refactoring**: Import strategies, state migration → [reference/category-migration.md](reference/category-migration.md)
**Dependency & Ordering**: depends_on, implicit dependencies → [reference/category-dependency.md](reference/category-dependency.md)
**Data Sources & Imports**: Data source usage, imports → [reference/category-data-sources.md](reference/category-data-sources.md)

## Best Practices

When performing code reviews:

- **Constructive and specific**: Include code examples and reference links
- **Context-aware**: Understand PR purpose and requirements, consider tradeoffs
- **Clear priorities**: Distinguish between "must fix" and "nice to have"
- **Leverage MCP tools**: Use context7 for module docs, serena for project structure
- **Prioritize automation**: Avoid excessive focus on syntax errors and terraform fmt/validate/tflint/trivy
- **Prevent security oversights**: Pay special attention to SEC-\* items
- **Note AWS context**: AWS-specific checks may need adjustment for other cloud environments
