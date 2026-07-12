# Terraform Review Checklist

## CI & Lint (CI)

- CI-01 (SHOULD): Minimize Unintended Plan Diffs
- CI-02 (SHOULD): New Resources Clearly Justified

## Compliance & Policy (COMP)

- COMP-03 (MUST): No Default VPC/Open SG/Public S3
- COMP-04 (MUST): IAM Policy with jsonencode or aws_iam_policy_document

## Cost Optimization (COST)

- COST-01 (SHOULD): Avoid High-Cost Metrics/Long Retention
- COST-02 (SHOULD): Minimize Optional Defaults (monitoring/xray/retention)

## Data Sources & Imports (DATA)

- DATA-01 (SHOULD): Justify Each Data Source
- DATA-02 (SHOULD): Externalize IDs/ARNs as Variables
- DATA-03 (SHOULD): Remove Unused data sources

## Dependency & Ordering (DEP)

- DEP-01 (SHOULD): Minimal depends_on
- DEP-02 (SHOULD): Avoid Circular References
- DEP-03 (SHOULD): Make Implicit Dependencies Explicit When Needed

## Events & Observability (E)

- E-01 (SHOULD): EventBridge event_pattern Precision
- E-02 (SHOULD): CloudWatch Log Group Retention
- E-03 (SHOULD): Alarm/Metrics/Dashboard Consistency
- E-04 (SHOULD): Step Functions Log Level Appropriateness

## Global / Base (G)

- G-01 (SHOULD): Variables/Outputs/Module Usage
- G-02 (MUST): Secret Hardcoding Prohibition
- G-03 (SHOULD): External Module Versioning
- G-04 (SHOULD): Provider Version Constraints
- G-05 (MUST): for_each/count with Post-Apply Values
- G-06 (MUST): Prefer for_each over count
- G-07 (SHOULD): Module Argument Validity
- G-08 (SHOULD): Module Output Usage
- G-09 (SHOULD): tfsec → trivy Migration

## Migration & Refactor (MIG)

- MIG-01 (SHOULD): Use moved Block to Avoid Resource Recreation
- MIG-02 (SHOULD): Replace Deprecated Features
- MIG-03 (SHOULD): No Commented-Out Resources

## Modules (M)

- M-01 (SHOULD): Review All .tf Files in Module
- M-02 (SHOULD): Provider Version Appropriateness
- M-03 (SHOULD): Clear Responsibility for locals/variables/outputs
- M-04 (SHOULD): Unified Tags and Naming Prefixes

## Naming & Documentation (N)

- N-01 (SHOULD): English Comments
- N-02 (SHOULD): Module Header (Purpose/Overview)
- N-03 (SHOULD): Important Resource Explanation Comments

## outputs.tf (O)

- O-01 (SHOULD): All Outputs Require description
- O-02 (SHOULD): No Sensitive Information in Outputs
- O-03 (SHOULD): Remove Unreferenced Outputs

## Patterns (P)

- P-01 (SHOULD): Avoid Excessive dynamic Blocks
- P-02 (SHOULD): Stable for_each Keys
- P-03 (SHOULD): Avoid count = 0/1 Toggle Chains

## Performance & Limits (PERF)

- PERF-01 (SHOULD): Avoid Unbounded for_each/count
- PERF-02 (SHOULD): Reduce Provider Calls
- PERF-03 (SHOULD): Meaningful Alarms Only

## Security (SEC)

- SEC-01 (SHOULD): KMS Encryption (SNS/S3/Logs/StateMachines) [AWS-specific]
- SEC-02 (SHOULD): IAM Least Privilege
- SEC-03 (SHOULD): Resource Policy with Condition
- SEC-04 (MUST): No Plaintext Secrets
- SEC-05 (SHOULD): Appropriate Logging Configuration

## State & Backend (STATE)

- STATE-01 (SHOULD): Remote Backend with Encryption (SSE) + DynamoDB Lock
- STATE-02 (SHOULD): No Credentials in Backend Configuration
- STATE-03 (SHOULD): No Workspace (Unless Documented)

## Tagging (TAG)

- TAG-01 (MUST): Name Tag with merge(local.tags, {Name = "..."})
- TAG-02 (SHOULD): Remove Redundant Manual Tags

## tfvars (T)

- T-01 (MUST): No Secrets in tfvars
- T-02 (SHOULD): Environment-Specific File Separation
- T-03 (SHOULD): No Cross-Environment Identifiers
- T-04 (SHOULD): No Environment Prefix Mixing

## variables.tf (V)

- V-01 (SHOULD): Concrete Types (Avoid Excessive map(any)/any)
- V-02 (SHOULD): Default Value Validity
- V-03 (SHOULD): Description Comments + (Required)/(Optional)
- V-04 (SHOULD): Validation Pattern Restrictions
- V-05 (SHOULD): No Unused Variables

## Versioning (VERS)

- VERS-01 (MUST): required_version Aligns with Project Standards
- VERS-02 (MUST): Provider Version Range (>= lower, < upper)
- VERS-03 (SHOULD): External Module Pinning (Avoid SHA/pseudo version)
