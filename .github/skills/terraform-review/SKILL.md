---
name: terraform-review
description: Code review guide for Terraform configurations. This skill should be used when performing code reviews on Terraform files, checking for correctness, security, maintainability, and best practices compliance.
license: MIT
---

# Terraform Code Review

This skill provides comprehensive guidance for reviewing Terraform code to ensure correctness, security, maintainability, and best practices compliance.

## Output Language

**IMPORTANT**: Always respond in Japanese (日本語) when performing code reviews, including:

- All explanatory text
- Problem descriptions (問題の説明)
- Impact assessments (影響の評価)
- Recommendations (推奨事項)
- Check results (チェック結果)

Keep only the following in English:

- File paths (ファイルパス)
- Code snippets (コードスニペット)
- Technical identifiers (variable names, resource names, module names, etc.)

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Terraform pull requests
- Checking Terraform configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

**Note**: This guide assumes AWS-based Terraform usage. For Azure/GCP environments, some recommendations (especially in the Security section) may need adjustment.

**Note**: Linting and auto-checkable items (syntax errors, naming conventions, terraform fmt/validate, tflint, trivy) are excluded from this review as they should be caught by pre-commit hooks or CI/CD pipelines.

## Review Guidelines

### 1. Global / Base (G)

**G-01: Variables/Outputs/Module Usage**

- Problem: Incorrect variable/output usage, undocumented module interfaces
- Impact: Unexpected configurations, errors, missed breaking changes
- Recommendation: Use context7/fetch_webpage to verify latest module documentation, use correct interfaces
- Check: External modules reference latest documentation

**G-02: Secret Hardcoding Prohibition**

- Problem: Hardcoded credentials, passwords, tokens in code
- Impact: Information leakage, Git history contamination, security breach
- Recommendation: Use variables, AWS Secrets Manager, or SSM Parameter Store
- Check: No plaintext secrets in .tf files

**G-03: External Module Versioning**

- Problem: Unspecified or outdated module versions, vulnerabilities
- Impact: Unexpected breaking changes, security risks, lack of reproducibility
- Recommendation: Check GitHub releases, pin to semantic versions
- Check: All external modules have explicit version constraints

**G-04: Provider Version Constraints**

- Problem: Unpinned provider versions, overly broad version ranges
- Impact: Breaking changes causing failures, lack of reproducibility
- Recommendation: Use `required_providers` block with appropriate version constraints (>= lower, < upper)
- Check: Provider versions are explicitly constrained

**G-05: for_each/count with Post-Apply Values**

- Problem: Using resource attributes determined after apply in for_each/count keys
- Impact: Plan-time errors ("value depends on resource attributes..."), parallel apply issues
- Recommendation: Use pre-determined values (var, local, data source known attributes)
- Check: for_each/count keys are known at plan time

**G-06: Prefer for_each over count**

- Problem: List order-dependent count usage, index shift risks
- Impact: Unexpected resource recreation, destructive changes on reordering
- Recommendation: Use for_each with unique keys; count acceptable only for toggle (0/1)
- Check: for_each used instead of count except for enable/disable flags

**G-07: Module Argument Validity**

- Problem: Missing required arguments, type mismatches, misused defaults
- Impact: Module malfunction, runtime errors, unintended behavior
- Recommendation: Verify module README/variables.tf, set correct types and values
- Check: All required module arguments provided correctly

**G-08: Module Output Usage**

- Problem: Unused outputs defined, needed outputs missing
- Impact: Integration issues, code bloat, reduced readability
- Recommendation: Output only necessary values, remove unreferenced outputs
- Check: Outputs match actual usage patterns

**G-09: tfsec → trivy Migration**

- Problem: Using deprecated tfsec, missing latest vulnerability detection
- Impact: Missed security vulnerabilities, reduced CI/CD quality
- Recommendation: Migrate to Trivy, integrate into CI/CD pipeline
- Check: No tfsec references; trivy in use

### 2. Modules (M)

**M-01: Review All .tf Files in Module**

- Problem: Partial file review, missing files
- Impact: Hidden bugs, inconsistencies, quality degradation
- Recommendation: Review all `.tf` files in directory
- Check: All module files reviewed

**M-02: Provider Version Appropriateness**

- Problem: Inappropriate provider versions, forced latest, compatibility issues
- Impact: Incompatibility, bugs, existing code breakage
- Recommendation: Specify versions matching project requirements, verify breaking changes
- Check: Provider versions align with project standards

**M-03: Clear Responsibility for locals/variables/outputs**

- Problem: Mixed variables/locals/outputs, unclear responsibilities
- Impact: Reduced readability, maintainability, understanding difficulty
- Recommendation: Proper file/block placement by purpose, separation of concerns
- Check: Clear separation of variables, locals, and outputs

**M-04: Unified Tags and Naming Prefixes**

- Problem: Inconsistent tags and naming, scattered prefixes
- Impact: Difficult resource management, cost allocation impossible, search difficulties
- Recommendation: Centralized management with common variables/locals, use merge function
- Check: Consistent tagging and naming conventions

### 3. variables.tf (V)

**V-01: Concrete Types (Avoid Excessive map(any)/any)**

- Problem: Excessive `any` type usage, lack of type safety
- Impact: Runtime type errors, unexpected behavior, difficult debugging
- Recommendation: Use concrete types (`string`, `number`, `object({...})`), enforce type constraints
- Check: Minimal use of `any` and `map(any)`

**V-02: Default Value Validity**

- Problem: Inappropriate defaults, empty string/0 defaults, sentinel values
- Impact: Missed misconfigurations, unintended behavior, security risks
- Recommendation: Remove default for required variables, appropriate defaults, consider null
- Check: No sentinel values; defaults are meaningful or absent

**V-03: Description Comments + (Required)/(Optional)**

- Problem: Insufficient variable descriptions, unclear required/optional status
- Impact: User confusion, misuse, documentation gaps
- Recommendation: Write `description`, explicitly mark (Required)/(Optional), add examples
- Check: All variables have descriptions with required/optional markers

**V-04: Validation Pattern Restrictions**

- Problem: Inappropriate validations, excessive constraints (e.g., length > 0)
- Impact: Rejecting valid values, errors, operational difficulties
- Recommendation: Appropriate condition expressions, business logic validation
- Check: Validation rules are reasonable and necessary

**V-05: No Unused Variables**

- Problem: Unused variables remaining, dead code, noise
- Impact: Confusion, increased maintenance cost, reduced readability
- Recommendation: Remove unused variables, periodic cleanup
- Check: All variables are referenced

### 4. outputs.tf (O)

**O-01: All Outputs Require description**

- Problem: Insufficient output descriptions, unclear purpose
- Impact: Usage unclear, integration difficulties, documentation gaps
- Recommendation: Add `description` to all outputs, specify purpose and format
- Check: Every output has a description

**O-02: No Sensitive Information in Outputs**

- Problem: Plaintext sensitive information output, passwords, tokens
- Impact: Log leakage, security breach, compliance violations
- Recommendation: Set `sensitive = true`, avoid outputting secrets; ARN/ID acceptable
- Check: Sensitive values marked or not exposed

**O-03: Remove Unreferenced Outputs**

- Problem: Unnecessary output definitions, unused outputs
- Impact: Code bloat, reduced readability, maintenance burden
- Recommendation: Remove unused outputs, add when needed
- Check: All outputs are consumed somewhere

### 5. tfvars (T)

**T-01: No Secrets in tfvars**

- Problem: Secrets in tfvars, passwords, tokens
- Impact: Repository leak risk, Git history contamination, security breach
- Recommendation: Reference external secret stores (data sources), use environment variables
- Check: No hardcoded secrets in tfvars files

**T-02: Environment-Specific File Separation**

- Problem: Mixed environment configs, single tfvars file
- Impact: Misdeployment risk, environment contamination, operational errors
- Recommendation: Separate files per environment (dev.tfvars, prd.tfvars)
- Check: Clear environment-specific file separation

**T-03: No Cross-Environment Identifiers**

- Problem: Cross-environment ID mixing, incorrect IDs from other environments
- Impact: Cross-environment contamination, unintended resource references
- Recommendation: Only environment-specific values, validate variables/locals
- Check: No foreign environment IDs (account IDs, VPC IDs, etc.)

**T-04: No Environment Prefix Mixing**

- Problem: Incorrect environment prefixes, naming inconsistencies
- Impact: Resource naming errors, identification difficulties, operational confusion
- Recommendation: Verify correct environment prefix, follow naming rules
- Check: Consistent environment prefixes throughout

### 6. Security (SEC)

**Note**: The following security guidelines are AWS-specific. For multi-cloud repositories, verify the cloud provider context before applying.

**SEC-01: KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]**

- Problem: Missing encryption, plaintext data storage
- Impact: Data leak risk, compliance violations, audit failures
- Recommendation: Enable CMK/AWS managed key encryption, set kms_key_id
- Check: Encryption enabled for sensitive resources

**SEC-02: IAM Least Privilege**

- Problem: Excessive permissions, wildcard (\*) overuse
- Impact: Increased damage on breach, privilege escalation, information leakage
- Recommendation: Limit to necessary actions/resources, document reason for `*` usage
- Check: IAM policies follow least privilege; wildcards justified

**SEC-03: Resource Policy with Condition**

- Problem: Insufficient resource policy restrictions, missing Condition
- Impact: Unintended source access, unauthorized use, security risks
- Recommendation: Add `Condition` block with `SourceArn`/`SourceAccount` restrictions
- Check: Resource policies (SNS, SQS) include appropriate conditions

**SEC-04: No Plaintext Secrets**

- Problem: Plaintext secrets in code, hardcoded credentials
- Impact: Leak risk, Git history persistence, security breach
- Recommendation: Use Secrets Manager/SSM Parameter Store, reference via data sources
- Check: All secrets retrieved from secure stores

**SEC-05: Appropriate Logging Configuration**

- Problem: Inadequate logging, disabled log output, improper retention
- Impact: No audit trail, troubleshooting difficulties, compliance violations
- Recommendation: Proper log output/retention settings, CloudWatch Logs integration
- Check: CloudTrail, CloudWatch Logs properly configured

### 7. Tagging (TAG)

**TAG-01: Name Tag with merge(local.tags, {Name = "..."})**

- Problem: Individual Name tag settings, unused merge function
- Impact: Lack of consistency, tag management difficulties
- Recommendation: Use `merge` function for common tags + individual Name
- Check: Tags use merge pattern with common tags

**TAG-02: Remove Redundant Manual Tags**

- Problem: Duplicate tag definitions, manual tag descriptions
- Impact: Code redundancy, increased maintenance cost, inconsistency risk
- Recommendation: Use common tag locals, eliminate duplicates, follow DRY principle
- Check: No duplicate tag keys; centralized tag management

### 8. Events & Observability (E)

**E-01: EventBridge event_pattern Precision**

- Problem: Overly broad event patterns, insufficient filters
- Impact: Unnecessary invocations, increased costs, noise
- Recommendation: Filter only necessary events, narrow detail-type/source
- Check: Event patterns are specific and targeted

**E-02: CloudWatch Log Group Retention**

- Problem: Unset retention period, indefinite storage
- Impact: Increased storage costs, log bloat, management difficulties
- Recommendation: Set appropriate `retention_in_days` (7/30/90/365), match requirements
- Check: Log groups have explicit retention periods

**E-03: Alarm/Metrics/Dashboard Consistency**

- Problem: Monitoring setup inconsistencies, missing alarms
- Impact: Missed fault detection, operational difficulties, SLA violations
- Recommendation: Sync resource/monitoring configs, set alarms for critical metrics
- Check: Alarms match deployed resources

**E-04: Step Functions Log Level Appropriateness**

- Problem: Inappropriate log level, ALL setting, too much or too little logging
- Impact: Debugging difficulties, log cost increase, slow troubleshooting
- Recommendation: Use appropriate log level (OFF/ALL/ERROR/FATAL), ERROR recommended for production
- Check: Log levels match environment requirements

### 9. Versioning (VERS)

**VERS-01: required_version Aligns with Project Standards**

- Problem: Terraform version mismatch, overly broad range
- Impact: No operation guarantee, team environment inconsistency
- Recommendation: Specify project standard version range, follow documentation
- Check: required_version matches project standards

**VERS-02: Provider Version Range (>= lower, < upper)**

- Problem: Insufficient provider version pinning, no upper bound
- Impact: Unexpected breaking changes, operation failures
- Recommendation: Appropriate version constraints (`>= 4.0, < 5.0`), set upper bound
- Check: Provider versions have both lower and upper bounds

**VERS-03: External Module Pinning (Avoid SHA/pseudo version)**

- Problem: Fluctuating module versions, SHA direct reference
- Impact: Unexpected changes, build instability
- Recommendation: Pin to tag versions (`?ref=v1.2.3`), semantic versioning
- Check: Modules use tagged versions, not SHA or branch refs

### 10. Naming & Documentation (N)

**N-01: English Comments**

- Problem: Mixed language comments, policy violations
- Impact: Global team collaboration difficulties, lack of consistency
- Recommendation: Write comments in English, follow project policy
- Check: All comments are in English

**N-02: Module Header (Purpose/Overview)**

- Problem: Missing module description, no header comments
- Impact: Unclear usage, slow onboarding, maintenance difficulties
- Recommendation: Add header comment at file beginning (purpose, overview, usage example)
- Check: Module files have descriptive headers

**N-03: Important Resource Explanation Comments**

- Problem: Insufficient complex configuration explanations, unclear intent
- Impact: Reduced maintainability, understanding difficulties
- Recommendation: Add intent/reason comments, explain complex logic
- Check: Complex configurations are well-commented

### 11. CI & Lint (CI)

**CI-01: plan Diff Intentional (No Unintended Changes)**

- Problem: Unintended diff generation, drift, configuration inconsistencies
- Impact: Unexpected change application, resource recreation
- Recommendation: Scrutinize `plan` results, resolve diffs, verify state consistency
- Note: Expected diffs excluded: provider version upgrades, resource reordering, computed attributes
- Check: All plan diffs are intentional and documented

**CI-02: New Resources Clearly Justified**

- Problem: Unnecessary resource creation, unclear requirements
- Impact: Cost increase, security risks, management burden
- Recommendation: Create only necessary resources based on requirements, provide justification
- Check: New resources have clear business justification

### 12. Patterns (P)

**P-01: Avoid Excessive dynamic Blocks**

- Problem: dynamic block overuse, over-abstraction
- Impact: Reduced readability, complexity, debugging difficulties
- Recommendation: Minimal usage, prefer static declarations, prioritize clarity
- Check: Dynamic blocks used only when necessary

**P-02: Stable for_each Keys**

- Problem: Unstable key usage, values prone to change
- Impact: Resource recreation, unexpected deletion, state inconsistencies
- Recommendation: Use unchanging unique values as keys, prefer IDs or names
- Check: for_each keys are stable identifiers

**P-03: Avoid count = 0/1 Toggle Chains**

- Problem: Complex conditional branching, count chains
- Impact: Understanding difficulties, bug-prone, maintenance difficulties
- Recommendation: Simplify logic, split modules, organize conditions
- Check: Conditional logic is straightforward

### 13. State & Backend (STATE)

**STATE-01: Remote Backend with Encryption (SSE) + DynamoDB Lock**

- Problem: Insufficient state protection, no encryption, missing lock mechanism
- Impact: Conflicts, corruption, information leak risk
- Recommendation: Enable S3 encryption + DynamoDB lock, set versioning
- Check: Backend configured with encryption and locking

**STATE-02: No Credentials in Backend Configuration**

- Problem: Credentials in backend config, hardcoded access keys
- Impact: Leak risk, security breach, Git history contamination
- Recommendation: Use environment variables, IAM roles, profiles
- Check: No hardcoded credentials in backend blocks

**STATE-03: No Workspace (Unless Documented)**

- Problem: Inappropriate workspace usage, ambiguous environment separation
- Impact: Environment confusion, misdeployment
- Recommendation: Recommend directory-based environment separation, document workspace usage policy
- Check: Workspaces not used or policy is documented

**STATE-04: terraform state Manual Operations Documented**

- Problem: Manual operations as black box, no records
- Impact: Operational risk, non-reproducible, troubleshooting difficulties
- Recommendation: Record operation procedures/reasons, manage change history
- Check: State modifications are documented

### 14. Compliance & Policy (COMP)

**COMP-01: Organization/Security Hub Governance Alignment**

- Problem: Organization policy violations, governance inconsistencies
- Impact: Compliance violations, audit failures, security risks
- Recommendation: Comply with organizational governance rules, verify policies
- Check: Configuration aligns with organizational policies

**COMP-02: trivy Results in Pipeline**

- Problem: Insufficient security check automation, manual scanning
- Impact: Vulnerability introduction, quality degradation
- Recommendation: Integrate Trivy scan in pipeline, set gates
- Check: trivy scan is part of CI/CD

**COMP-03: No Default VPC/Open SG/Public S3**

- Problem: Unsafe default settings, excessive exposure
- Impact: Expanded attack surface, information leakage
- Recommendation: Explicit secure settings, minimal exposure principle, prefer private
- Check: No use of default VPC, security groups are restrictive, S3 buckets private

**COMP-04: IAM Policy with jsonencode or aws_iam_policy_document**

- Problem: String concatenation policy generation, hand-written JSON
- Impact: Syntax errors, reduced readability, maintenance difficulties
- Recommendation: Use `jsonencode` or data source `aws_iam_policy_document`
- Check: IAM policies use structured approaches

### 15. Cost Optimization (COST)

**COST-01: Avoid High-Cost Metrics/Long Retention**

- Problem: Unnecessary costs, excessive retention periods
- Impact: Budget overruns, wasted costs
- Recommendation: Retain only necessary periods/metrics, optimize costs
- Check: Retention periods and metric collection are justified

**COST-02: Mass Resource Creation Cost Justification**

- Problem: Excessive resource provisioning, insufficient cost estimation
- Impact: Cost increase, budget overruns, low ROI
- Recommendation: Justify cost-effectiveness, verify necessity, consider alternatives
- Check: Large-scale resource creation has cost analysis

**COST-03: Minimize Optional Defaults (monitoring/xray/retention)**

- Problem: Unnecessary option enablement, all defaults enabled
- Impact: Wasted costs, complexity, management burden
- Recommendation: Enable options only when needed, default to minimal configuration
- Check: Optional features explicitly enabled with justification

### 16. Performance & Limits (PERF)

**PERF-01: Avoid Excessive for_each/count Plan Time**

- Problem: Increased plan execution time, bulk processing
- Impact: Reduced development efficiency, CI/CD delays
- Recommendation: Split state, consider `-target`, resource grouping
- Check: Plan completes in reasonable time

**PERF-02: Reduce Provider Calls**

- Problem: Excessive API calls, duplicate data sources
- Impact: Rate limit hit, execution delays
- Recommendation: Cache/share data, leverage locals, minimize data sources
- Check: Data sources are not duplicated unnecessarily

**PERF-03: Monitor CloudWatch Event/Alarm Generation**

- Problem: Alarm proliferation, excessive events
- Impact: Increased noise, critical alarms buried
- Recommendation: Monitor only important events, consolidate alarms
- Check: Alarms are meaningful and actionable

### 17. Migration & Refactor (MIG)

**MIG-01: Use moved Block to Avoid Resource Recreation**

- Problem: Resource recreation during refactoring, downtime
- Impact: Service interruption, data loss, user impact
- Recommendation: Use `moved` block for state migration, avoid destructive changes
- Check: Refactors use moved blocks where appropriate

**MIG-02: Replace Deprecated Features**

- Problem: Using deprecated features, end-of-life APIs
- Impact: Future operation failures, security risks
- Recommendation: Replace with recommended alternatives, verify latest documentation
- Check: No deprecated features in use

**MIG-03: No Commented-Out Resources**

- Problem: Commented-out code, dead code
- Impact: Reduced readability, confusion
- Recommendation: Delete unnecessary code, use Git history, cleanup
- Check: No commented-out resource blocks

### 18. Dependency & Ordering (DEP)

**DEP-01: Minimal depends_on**

- Problem: Overuse of `depends_on`, excessive explicit dependencies
- Impact: Increased execution time, complex dependencies
- Recommendation: Prefer implicit dependencies, minimal depends_on
- Check: depends_on used only when necessary

**DEP-02: Avoid Circular References**

- Problem: Circular dependencies between resources, mutual references
- Impact: Apply errors, execution impossible
- Recommendation: Review design, resolve dependencies, split modules
- Check: No circular dependencies

**DEP-03: Make Implicit Dependencies Explicit When Needed**

- Problem: Missing dependencies, unconsidered implicit dependencies
- Impact: Apply errors, ordering issues
- Recommendation: Set explicit dependencies when needed, control ordering
- Check: Critical dependencies are explicit

### 19. Data Sources & Imports (DATA)

**Note**: Data sources are recommended when:

- Referencing existing resources is a requirement (integration with other modules/externally managed resources)
- Retrieving dynamically changing values (AMI IDs, availability zones, etc.)
- Prefer variables when static values are sufficient

**DATA-01: Reconsider data sources (Replace with Static Values)**

- Problem: Unnecessary data source references, replaceable with static values
- Impact: External dependencies, increased execution time
- Recommendation: Consider static value replacement, use data sources only when needed
- Check: Data sources are justified

**DATA-02: Document import Procedures**

- Problem: Unclear import background, undocumented procedures
- Impact: Management difficulties, non-reproducible
- Recommendation: Document procedures, record in comments, manage change history
- Check: Import operations are documented

**DATA-03: Externalize IDs/ARNs as Variables**

- Problem: Hardcoded IDs/ARNs, environment dependence
- Impact: Difficult environment portability, multi-account incompatibility
- Recommendation: Define as variables, separate tfvars, environment-independent design
- Check: Cross-environment references use variables

**DATA-04: Remove Unused data sources**

- Problem: Unused data sources, dead code
- Impact: Wasted API calls, increased execution time
- Recommendation: Remove unused data sources, periodic cleanup
- Check: All data sources are referenced

## Output Format

Review results must be output in the following structured format:

### Output Elements

1. **Checks** (Review items checklist)
   - Display judgment results for all review items
   - Format: `ItemID ItemName: ✅ Pass` or `ItemID ItemName: ❌ Fail`
   - Purpose: List status of all items

2. **Issues** (Detected problems)
   - Display details only for items marked ❌ Fail
   - Numbered list format for each problem
   - Each issue includes:
     - Item ID + Item Name
     - File: file path and line number
     - Problem: Description of the issue
     - Impact: Scope and severity
     - Recommendation: Specific fix suggestion

### Output Format Examples

#### ✅ All Pass (No Issues)

```markdown
# Terraform Code Review Result

## Checks

- G-01 Variables/Outputs/Module Usage: ✅ Pass
- G-02 Secret Hardcoding Prohibition: ✅ Pass
- SEC-01 KMS Encryption: ✅ Pass
- V-01 Concrete Types: ✅ Pass
  ...
  (all items listed)

## Issues

None ✅

All checks passed. Code is ready for merge.
```

#### ❌ Issues Found

````markdown
# Terraform Code Review Result

## Checks

- G-01 Variables/Outputs/Module Usage: ✅ Pass
- G-05 for_each with Post-Apply Values: ❌ Fail
- G-06 Prefer for_each over count: ✅ Pass
- SEC-03 Resource Policy with Condition: ❌ Fail
- V-01 Concrete Types: ❌ Fail
  ...
  (all items listed)

## Issues

Found 3 issues that need to be addressed:

### 1. G-05: for_each with Post-Apply Values

**File**: `modules/storage/main.tf:15`

**Problem**: Using `for_each = aws_s3_bucket.example.tags` where tags are determined after apply

**Impact**: Plan diff instability, parallel apply risks, "value depends on resource attributes..." errors

**Recommendation**: Replace with pre-determined map like `for_each = var.enabled_buckets` where keys are known at plan time

---

### 2. SEC-03: Resource Policy with Condition

**File**: `modules/events/sns.tf:42`

**Problem**: SNS topic policy allows `sns:Publish` without SourceArn Condition

**Impact**: Other accounts or unexpected events can publish to this topic, security risk

**Recommendation**: Add Condition block:

```hcl
condition {
  test     = "StringEquals"
  variable = "aws:SourceArn"
  values   = [aws_cloudwatch_event_rule.example.arn]
}
```
````

---

### 3. V-01: Concrete Types

**File**: `variables.tf:23`

**Problem**: Variable `config` declared as `map(any)` instead of concrete object type

**Impact**: Type safety loss, runtime type errors, difficult debugging

**Recommendation**: Replace with:

```hcl
variable "config" {
  type = object({
    bucket_name = string
    retention   = number
    enabled     = bool
  })
  description = "Configuration object (Required)"
}
```

```

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

Review each category systematically:

1. **Global checks** (G-01 to G-09)
2. **Module structure** (M-01 to M-04)
3. **Variables** (V-01 to V-05)
4. **Outputs** (O-01 to O-03)
5. **tfvars** (T-01 to T-04)
6. **Security** (SEC-01 to SEC-05)
7. **Tagging** (TAG-01 to TAG-02)
8. **Events & Observability** (E-01 to E-04)
9. **Versioning** (VERS-01 to VERS-03)
10. **Naming & Documentation** (N-01 to N-03)
11. **CI & Lint** (CI-01 to CI-02)
12. **Patterns** (P-01 to P-03)
13. **State & Backend** (STATE-01 to STATE-04)
14. **Compliance** (COMP-01 to COMP-04)
15. **Cost** (COST-01 to COST-03)
16. **Performance** (PERF-01 to PERF-03)
17. **Migration** (MIG-01 to MIG-03)
18. **Dependency** (DEP-01 to DEP-03)
19. **Data Sources** (DATA-01 to DATA-04)

### Step 4: Generate Review Report

Output the review result in the structured format specified above:
- Complete Checks section with all items
- Issues section with detailed findings
- Include file paths and line numbers
- Provide specific, actionable recommendations

### Step 5: Prioritize Issues

When multiple issues are found:
- **Critical**: Security issues (SEC-*), credential exposure (G-02, T-01, SEC-04)
- **High**: Breaking changes (G-05, DEP-02), compliance violations (COMP-*)
- **Medium**: Best practice violations, maintainability issues
- **Low**: Documentation improvements, minor optimizations

## Best Practices

### For Reviewers

- Be constructive and specific
- Provide code examples in recommendations
- Link to official documentation when relevant
- Consider context and trade-offs
- Distinguish between "must fix" and "nice to have"

### For Review Efficiency

- Use MCP tools to verify module documentation (context7, fetch_webpage)
- Check GitHub releases for module versions
- Verify AWS documentation for resource configurations
- Use grep_search to find patterns across the codebase

### Common Pitfalls to Avoid

- Nitpicking on personal preferences
- Ignoring the PR context and requirements
- Over-focusing on auto-checkable items
- Missing security issues
- Not providing actionable recommendations

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 19 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples

Use this skill to ensure Terraform code meets quality, security, and maintainability standards before merge.
```
