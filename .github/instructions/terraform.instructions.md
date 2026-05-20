---
applyTo: "**/*.tf,**/*.tfvars,**/*.hcl"
description: "AI Assistant Instructions for Terraform"
---

# AI Assistant Instructions for Terraform

## Scope

- Scope is limited to designing, updating, and validating Terraform definitions (`*.tf`, `*.tfvars`, `*.hcl`).

## Standards

### Naming Conventions

- All components (resource, variable, output, local, module): snake_case
- File names: snake_case (for example, `main_vpc.tf`, `variables.tf`)

### Versioning

- **VERS-01 (MUST)**: Align `required_version` with project standards - version mismatch can risk state corruption.
- **VERS-02 (MUST)**: Use provider version ranges (`>= lower, < upper`) - unconstrained versions can introduce unexpected plan diffs from breaking changes.

## Guidelines

### CI & Lint (CI)
- CI-01 (SHOULD): plan Diff Intentional (No Unintended Changes)
  - Check: Are all plan diffs intentional and documented?
- CI-02 (SHOULD): New Resources Clearly Justified
  - Check: Do new resources have clear business justification?

### Compliance & Policy (COMP)
- COMP-01 (SHOULD): Organization/Security Hub Governance Alignment
  - Check: Does configuration align with organizational policies?
- COMP-02 (SHOULD): trivy Results in Pipeline
  - Check: Is trivy scan part of CI/CD?
- COMP-03 (SHOULD): No Default VPC/Open SG/Public S3
  - Check: Is there no use of default VPC, are security groups restrictive, are S3 buckets private?
- COMP-04 (SHOULD): IAM Policy with jsonencode or aws_iam_policy_document
  - Check: Do IAM policies use structured approaches?

### Cost Optimization (COST)
- COST-01 (SHOULD): Avoid High-Cost Metrics/Long Retention
  - Check: Are retention periods and metric collection justified?
- COST-02 (SHOULD): Mass Resource Creation Cost Justification
  - Check: Does large-scale resource creation have cost analysis?
- COST-03 (SHOULD): Minimize Optional Defaults (monitoring/xray/retention)
  - Check: Are optional features explicitly enabled with justification?

### Data Sources & Imports (DATA)
- DATA-01 (SHOULD): Reconsider data sources (Replace with Static Values)
  - Check: Are data sources justified?
- DATA-02 (SHOULD): Document import Procedures
  - Check: Are import operations documented?
- DATA-03 (SHOULD): Externalize IDs/ARNs as Variables
  - Check: Do cross-environment references use variables?
- DATA-04 (SHOULD): Remove Unused data sources
  - Check: Are all data sources referenced?

### Dependency & Ordering (DEP)
- DEP-01 (SHOULD): Minimal depends_on
  - Check: Is depends_on used only when necessary?
- DEP-02 (SHOULD): Avoid Circular References
  - Check: Are there no circular dependencies?
- DEP-03 (SHOULD): Make Implicit Dependencies Explicit When Needed
  - Check: Are critical dependencies explicit?

### Events & Observability (E)
- E-01 (SHOULD): EventBridge event_pattern Precision
  - Check: Are event patterns specific and targeted?
- E-02 (SHOULD): CloudWatch Log Group Retention
  - Check: Do log groups have explicit retention periods?
- E-03 (SHOULD): Alarm/Metrics/Dashboard Consistency
  - Check: Do alarms match deployed resources?
- E-04 (SHOULD): Step Functions Log Level Appropriateness
  - Check: Do log levels match environment requirements?

### Global / Base (G)
- G-01 (SHOULD): Variables/Outputs/Module Usage
  - Check: Do external modules reference latest documentation?
- G-02 (SHOULD): Secret Hardcoding Prohibition
  - Check: Are there no plaintext secrets in .tf files?
- G-03 (SHOULD): External Module Versioning
  - Check: Do all external modules have explicit version constraints?
- G-04 (SHOULD): Provider Version Constraints
  - Check: Are provider versions explicitly constrained?
- G-05 (SHOULD): for_each/count with Post-Apply Values
  - Check: Are for_each/count keys known at plan time?
- G-06 (SHOULD): Prefer for_each over count
  - Check: Is for_each used instead of count except for enable/disable flags?
- G-07 (SHOULD): Module Argument Validity
  - Check: Are all required module arguments provided correctly?
- G-08 (SHOULD): Module Output Usage
  - Check: Do outputs match actual usage patterns?
- G-09 (SHOULD): tfsec → trivy Migration
  - Check: Are there no tfsec references; is trivy in use?

### Migration & Refactor (MIG)
- MIG-01 (SHOULD): Use moved Block to Avoid Resource Recreation
  - Check: Do refactors use moved blocks where appropriate?
- MIG-02 (SHOULD): Replace Deprecated Features
  - Check: Are there no deprecated features in use?
- MIG-03 (SHOULD): No Commented-Out Resources
  - Check: Are there no commented-out resource blocks?

### Modules (M)
- M-01 (SHOULD): Review All .tf Files in Module
  - Check: Are all module files reviewed?
- M-02 (SHOULD): Provider Version Appropriateness
  - Check: Do provider versions align with project standards?
- M-03 (SHOULD): Clear Responsibility for locals/variables/outputs
  - Check: Is there clear separation of variables, locals, and outputs?
- M-04 (SHOULD): Unified Tags and Naming Prefixes
  - Check: Are tagging and naming conventions consistent?

### Naming & Documentation (N)
- N-01 (SHOULD): English Comments
  - Check: Are all comments in English?
- N-02 (SHOULD): Module Header (Purpose/Overview)
  - Check: Do module files have descriptive headers?
- N-03 (SHOULD): Important Resource Explanation Comments
  - Check: Are complex configurations well-commented?

### outputs.tf (O)
- O-01 (SHOULD): All Outputs Require description
  - Check: Does every output have a description?
- O-02 (SHOULD): No Sensitive Information in Outputs
  - Check: Are sensitive values marked or not exposed?
- O-03 (SHOULD): Remove Unreferenced Outputs
  - Check: Are all outputs consumed somewhere?

### Patterns (P)
- P-01 (SHOULD): Avoid Excessive dynamic Blocks
  - Check: Are dynamic blocks used only when necessary?
- P-02 (SHOULD): Stable for_each Keys
  - Check: Are for_each keys stable identifiers?
- P-03 (SHOULD): Avoid count = 0/1 Toggle Chains
  - Check: Is conditional logic straightforward?

### Performance & Limits (PERF)
- PERF-01 (SHOULD): Avoid Excessive for_each/count Plan Time
  - Check: Does plan complete in reasonable time?
- PERF-02 (SHOULD): Reduce Provider Calls
  - Check: Are data sources not duplicated unnecessarily?
- PERF-03 (SHOULD): Monitor CloudWatch Event/Alarm Generation
  - Check: Are alarms meaningful and actionable?

### Security (SEC)
- SEC-01 (SHOULD): KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]
  - Check: Is encryption enabled for sensitive resources?
- SEC-02 (SHOULD): IAM Least Privilege
  - Check: Do IAM policies follow least privilege; are wildcards justified?
- SEC-03 (SHOULD): Resource Policy with Condition
  - Check: Do resource policies (SNS, SQS) include appropriate conditions?
- SEC-04 (SHOULD): No Plaintext Secrets
  - Check: Are all secrets retrieved from secure stores?
- SEC-05 (SHOULD): Appropriate Logging Configuration
  - Check: Are CloudTrail and CloudWatch Logs properly configured?

### State & Backend (STATE)
- STATE-01 (SHOULD): Remote Backend with Encryption (SSE) + DynamoDB Lock
  - Check: Is backend configured with encryption and locking?
- STATE-02 (SHOULD): No Credentials in Backend Configuration
  - Check: Are there no hardcoded credentials in backend blocks?
- STATE-03 (SHOULD): No Workspace (Unless Documented)
  - Check: Are workspaces not used or is policy documented?
- STATE-04 (SHOULD): terraform state Manual Operations Documented
  - Check: Are state modifications documented?

### Tagging (TAG)
- TAG-01 (SHOULD): Name Tag with merge(local.tags, {Name = "..."})
  - Check: Do tags use merge pattern with common tags?
- TAG-02 (SHOULD): Remove Redundant Manual Tags
  - Check: Are there no duplicate tag keys; is tag management centralized?

### tfvars (T)
- T-01 (SHOULD): No Secrets in tfvars
  - Check: Are there no hardcoded secrets in tfvars files?
- T-02 (SHOULD): Environment-Specific File Separation
  - Check: Is there clear environment-specific file separation?
- T-03 (SHOULD): No Cross-Environment Identifiers
  - Check: Are there no foreign environment IDs (account IDs, VPC IDs, etc.)?
- T-04 (SHOULD): No Environment Prefix Mixing
  - Check: Are environment prefixes consistent throughout?

### variables.tf (V)
- V-01 (SHOULD): Concrete Types (Avoid Excessive map(any)/any)
  - Check: Is use of `any` and `map(any)` minimal?
- V-02 (SHOULD): Default Value Validity
  - Check: Are there no sentinel values; are defaults meaningful or absent?
- V-03 (SHOULD): Description Comments + (Required)/(Optional)
  - Check: Do all variables have descriptions with required/optional markers?
- V-04 (SHOULD): Validation Pattern Restrictions
  - Check: Are validation rules reasonable and necessary?
- V-05 (SHOULD): No Unused Variables
  - Check: Are all variables referenced?

### Versioning (VERS)
- VERS-01 (MUST): required_version Aligns with Project Standards
  - Check: Does required_version match project standards?
- VERS-02 (MUST): Provider Version Range (>= lower, < upper)
  - Check: Do provider versions have both lower and upper bounds?
- VERS-03 (SHOULD): External Module Pinning (Avoid SHA/pseudo version)
  - Check: Do modules use tagged versions, not SHA or branch refs?

### Code Modification Guidelines

- After changes, prioritize running validate.sh from [terraform-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/terraform/.apm/skills/terraform-validation/SKILL.md).
- Use individual commands only for debugging.


## Testing and Validation

**Entry point (recommended)**:

```bash
bash <agent-root>/skills/terraform-validation/scripts/validate.sh
```

**Individual execution (debugging)**:

```bash
terraform fmt -check -recursive
terraform validate
tflint --recursive
trivy config .
```

**Detailed guide**: See [terraform-validation Skill](../../apm_modules/y-miyazaki/config/.apm/packages/terraform/.apm/skills/terraform-validation/SKILL.md).

## Security Guidelines

- Do not place secrets directly in tfvars/code; use Secret Manager or SSM Parameter Store.
- Keep IAM permissions at least privilege and document the rationale for wildcard usage.
- Keep defaults on the safe side for encryption, audit logging, and public exposure settings.
