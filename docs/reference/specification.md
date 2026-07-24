# Terraform Specification

This document defines repository behavior, infrastructure intent, environment-specific configuration, and operational expectations for Terraform-managed resources in this AWS baseline repository.

## Scope

| Item           | Detail                                                              |
| -------------- | ------------------------------------------------------------------- |
| Stacks         | base/, management/audit/, management/root/, monitor/                |
| Environments   | dev, qa, stg, prd, audit, root                                      |
| Cloud Provider | AWS                                                                 |
| Exclusions     | Application-specific infra, networking beyond default VPC hardening |

Out-of-scope items:

- Module input/output variable documentation (maintained by terraform-docs)
- Application-specific infrastructure (deployed separately per project)
- Networking beyond default VPC hardening
- Container orchestration and compute workloads
- Provider usage tutorials
- Basic Terraform language explanations

## Infrastructure Intent

This repository provides a reusable AWS baseline configuration that covers security, monitoring, cost management, and IAM governance. Each stack serves a distinct purpose:

- **base/** — Per-account security baseline (GuardDuty, Config, Security Hub, IAM, EBS encryption, IMDSv2, default VPC hardening)
- **management/audit/** — Delegated admin for organization-wide security services (Security Hub, GuardDuty, Access Analyzer, Inspector2, Macie)
- **management/root/** — Organization root account resources (CloudTrail, Budgets, SCPs, OIDC GitHub)
- **monitor/** — CloudWatch metrics, log filters, EventBridge events, and Athena queries for operational observability

Stacks are environment-specific (applied per-account with account-specific tfvars), not reusable across accounts without configuration changes.

External dependencies:

- Slack workspace with app configured (OAuthToken + ChannelID) for notifications
- S3 bucket and DynamoDB table for Terraform state backend
- AWS Organizations with delegated admin configured for audit account

## Resource and Lifecycle Design

Lifecycle-sensitive resources requiring extra care:

| Resource                 | Risk                                          | Mitigation                                  |
| ------------------------ | --------------------------------------------- | ------------------------------------------- |
| KMS keys (CloudTrail)    | Deletion causes permanent data loss           | `prevent_destroy` lifecycle rule            |
| GuardDuty detector       | Recreation loses finding history              | External data source checks before creation |
| Access Analyzer          | Organization analyzer conflicts with existing | Shell script idempotency check              |
| CloudTrail               | Recreation causes audit gap                   | Import existing resources                   |
| S3 buckets (log storage) | Deletion loses audit logs                     | Bucket policy + versioning                  |

Destructive replacement risks:

- Changing KMS key policy forces key recreation — use `lifecycle { prevent_destroy = true }`
- Changing Lambda runtime forces replacement — plan carefully
- GuardDuty/Security Hub organization settings affect all member accounts

Import expectations:

- Resources created by Control Tower or AWS Console should be imported before Terraform management
- `control_tower.managed_services` flags skip creation when services are externally managed

## Environment Strategy

- **Isolation**: Each environment has its own AWS account, state file, and tfvars
- **Naming**: `{org}-{env}` prefix (e.g., `acme-dev`, `acme-prd`) via `name_prefix` variable
- **Backend separation**: Per-environment `.tfbackend` files with separate S3 keys
- **Feature toggles**: `is_enabled` flags in tfvars allow per-environment feature activation without code changes
- **Control Tower integration**: `control_tower.managed_services` flags prevent conflicts with organization-managed services

Promotion workflow: Changes are applied to dev → qa → stg → prd sequentially. Each environment uses the same module code with different tfvars.

## Security Considerations

- **IAM boundaries**: Group-based policies with mandatory MFA enforcement
- **Least privilege**: Lambda functions use scoped IAM roles; no wildcard permissions
- **Encryption**: EBS encryption by default; KMS keys for CloudTrail and Config logs
- **Network**: Default VPC hardened (empty security group rules); IMDSv2 enforced account-wide
- **Cross-account access**: Delegated admin model for security services; switch roles for human access
- **Auditability**: CloudTrail organization trail; Config recorder; Security Hub aggregation
- **Public exposure**: S3 account-level public access block; EBS snapshot public access block; ECR scan type enforcement

## Operational Characteristics

- **Monitoring**: All alarms route through SNS → Lambda → Slack; daily report aggregations via EventBridge Scheduler
- **Failure recovery**: Feature toggles allow disabling problematic services without code changes; state-driven rollback via tfvars revert
- **Scaling**: Monitor stack supports per-resource alarm definitions; no auto-scaling of baseline resources
- **Cost-sensitive resources**: Trusted Advisor (requires Business/Enterprise support plan, default disabled); Inspector2 (per-scan pricing); Macie (per-GB pricing)
- **Deployment frequency**: Base/management stacks change infrequently; monitor stack changes with each new workload

## Validation and Safety Checks

Required validation commands:

```sh
terraform fmt -check
terraform validate
tflint --init
tflint --recursive
trivy config .
gitleaks detect
```

CI/CD validation flow:

1. Pre-commit hooks: format, validate, docs, lint
2. PR pipeline: `terraform plan` with output review
3. Apply requires explicit approval for production environments

## Change Management

All changes follow this workflow:

1. Modify `terraform.example.tfvars` or module code
2. Run `terraform plan` against target environment
3. Review plan output for unexpected resource changes (especially destroys/replacements)
4. Apply with approval — production requires explicit confirmation
5. Rollback: revert tfvars change and re-apply (state-driven, no manual cleanup needed)

Resources requiring extra review before apply:

- KMS keys (irreversible deletion)
- Organization-level settings (affects all member accounts)
- IAM policies (privilege escalation risk)
- CloudTrail configuration (audit gap risk)

## Related Documentation

- [Architecture Overview](../explanation/architecture.md) — Account structure and Terraform directory layout
- [Design Document — Terraform Modules and Root Configurations](../explanation/design.md) — Module conventions, variable patterns, and naming rules
- [Design Decisions](../explanation/design-decisions.md) — Rationale for major patterns and rejected alternatives
- [Module Catalog](./module-catalog.md) — Full module index with purpose and location
- [AWS Security Services Coverage](./security-coverage.md) — Security service coverage matrix
- [Monitoring](./monitoring.md) — Alert configuration and operational runbooks
- [Troubleshooting](../how-to/troubleshooting.md) — Common issues and recovery steps
