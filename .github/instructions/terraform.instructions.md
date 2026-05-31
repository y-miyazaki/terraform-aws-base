---
applyTo: "**/*.tf,**/*.tfvars,**/*.hcl"
description: "AI Assistant Instructions for Terraform"
---

# AI Assistant Instructions for Terraform

## Scope

- Scope is limited to designing, updating, and validating Terraform definitions (`*.tf`, `*.tfvars`, `*.hcl`).

## Standards

### Naming Conventions

| Component | Rule       | Example        |
| --------- | ---------- | -------------- |
| Resource  | snake_case | aws_s3_bucket  |
| Variable  | snake_case | vpc_cidr_block |
| Output    | snake_case | instance_id    |
| Local     | snake_case | common_tags    |
| Module    | snake_case | vpc_module     |
| File name | snake_case | main_vpc.tf    |

### Versioning

- **VERS-01 (MUST)**: Align `required_version` with project standards - version mismatch can risk state corruption.
- **VERS-02 (MUST)**: Use provider version ranges (`>= lower, < upper`) - unconstrained versions can introduce unexpected plan diffs from breaking changes.

### Key Coding Rules

- **G-05 (MUST)**: Ensure `for_each`/`count` keys are known at plan time — post-apply values cause `terraform plan` failures.
- **G-06 (MUST)**: Prefer `for_each` over `count` — count index shifts cause unintended resource recreation on removal.
- **TAG-01 (MUST)**: Use `merge(local.tags, { Name = "..." })` pattern for tags — this ensures consistent tagging across all resources.
- **COMP-04 (MUST)**: Write IAM policies with `jsonencode()` or `aws_iam_policy_document` — never use inline heredoc JSON strings.
- **G-02 (MUST)**: Never hardcode secrets in `.tf` or `.tfvars` files — use SSM Parameter Store or Secrets Manager references.

### Key Ordering

- **ORD-01 (MUST)**: Within each resource/module/data block, keep argument keys in alphabetical order (A-Z) — inconsistent ordering adds diff noise and makes change detection harder.

## Guidelines

### CI & Lint (CI)
- CI-01 (SHOULD): Minimize Unintended Plan Diffs
  - Check: Does the code avoid patterns that cause unnecessary plan diffs (e.g., unsorted keys, unstable JSON, computed defaults)?
- CI-02 (SHOULD): New Resources Clearly Justified
  - Check: Do new resources have clear business justification?

### Compliance & Policy (COMP)
- COMP-03 (MUST): No Default VPC/Open SG/Public S3
  - Check: Is there no use of default VPC, are security groups restrictive, and are S3 buckets private by default?
- COMP-04 (MUST): IAM Policy with jsonencode or aws_iam_policy_document
  - Check: Do IAM policies use jsonencode() or aws_iam_policy_document data source?

### Cost Optimization (COST)
- COST-01 (SHOULD): Avoid High-Cost Metrics/Long Retention
  - Check: Are retention periods and metric collection explicitly set rather than left at expensive defaults?
- COST-02 (SHOULD): Minimize Optional Defaults (monitoring/xray/retention)
  - Check: Are optional features (X-Ray tracing, enhanced monitoring, detailed metrics) explicitly enabled only when needed?

### Data Sources & Imports (DATA)
- DATA-01 (SHOULD): Justify Each Data Source
  - Check: Is each data source necessary, or can the value be passed as a variable?
- DATA-02 (SHOULD): Externalize IDs/ARNs as Variables
  - Check: Do cross-environment references use variables rather than hardcoded IDs?
- DATA-03 (SHOULD): Remove Unused data sources
  - Check: Are all data sources referenced in at least one resource or output?

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
- G-02 (MUST): Secret Hardcoding Prohibition
  - Check: Are there no plaintext secrets in .tf files?
- G-03 (SHOULD): External Module Versioning
  - Check: Do all external modules have explicit version constraints?
- G-04 (SHOULD): Provider Version Constraints
  - Check: Are provider versions explicitly constrained?
- G-05 (MUST): for_each/count with Post-Apply Values
  - Check: Are for_each/count keys known at plan time?
- G-06 (MUST): Prefer for_each over count
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
- PERF-01 (SHOULD): Avoid Unbounded for_each/count
  - Check: Are for_each/count driven by bounded, plan-time-known collections rather than unbounded dynamic data?
- PERF-02 (SHOULD): Reduce Provider Calls
  - Check: Are data sources not duplicated unnecessarily across files or modules?
- PERF-03 (SHOULD): Meaningful Alarms Only
  - Check: Does each alarm have a clear action owner and response procedure?

### Security (SEC)
- SEC-01 (SHOULD): KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]
  - Check: Is encryption enabled for sensitive resources?
- SEC-02 (SHOULD): IAM Least Privilege
  - Check: Do IAM policies follow least privilege; are wildcards justified?
- SEC-03 (SHOULD): Resource Policy with Condition
  - Check: Do resource policies (SNS, SQS) include appropriate conditions?
- SEC-04 (MUST): No Plaintext Secrets
  - Check: Are all secrets retrieved from secure stores?
- SEC-05 (SHOULD): Appropriate Logging Configuration
  - Check: Are CloudTrail and CloudWatch Logs properly configured?

### State & Backend (STATE)
- STATE-01 (SHOULD): Remote Backend with Encryption (SSE) + DynamoDB Lock
  - Check: Is backend configured with encryption and locking?
- STATE-02 (SHOULD): No Credentials in Backend Configuration
  - Check: Are there no hardcoded credentials in backend blocks?
- STATE-03 (SHOULD): No Workspace (Unless Documented)
  - Check: Are workspaces not used, or is workspace usage policy documented in comments?

### Tagging (TAG)
- TAG-01 (MUST): Name Tag with merge(local.tags, {Name = "..."})
  - Check: Do tags use merge pattern with common tags?
- TAG-02 (SHOULD): Remove Redundant Manual Tags
  - Check: Are there no duplicate tag keys; is tag management centralized?

### tfvars (T)
- T-01 (MUST): No Secrets in tfvars
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

- After changes, prioritize running validate.sh from terraform-validation skill.
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

**Detailed guide**: See terraform-validation skill SKILL.md.

## Security Guidelines

- Do not place secrets directly in tfvars/code; use Secret Manager or SSM Parameter Store.
- Keep IAM permissions at least privilege and document the rationale for wildcard usage.
- Keep defaults on the safe side for encryption, audit logging, and public exposure settings.
