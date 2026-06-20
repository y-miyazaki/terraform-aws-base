# ADR-0002: Global vs Regional Resource Classification

## Status

✅ **ACCEPTED** (2026-06-18)  
📝 **UPDATED** (2026-06-19) — Aligned with ADR-0001 v2.0 (unified `region` object, no provider aliases).

## Context

During implementation of multi-region Terraform architecture (ADR-0001), a design decision arose regarding which resources should be deployed to multiple regions versus a single location.

### Problem Statement

1. **Ambiguous Classification**: Some resources could theoretically be multi-region, but the business case wasn't clear
2. **Data Duplication Risk**: Account-level resources deployed to multiple regions cause duplicate reports
3. **Regional Components of Global Services**: Lambda/Scheduler supporting global services must still be placed in a specific region

## Decision

**Classify resources into three tiers based on AWS service behavior:**

| Tier | File Pattern | Region Source | Criteria |
|------|-------------|---------------|----------|
| Regional | `main_regional_*.tf` | `var.region.targets` | Resource has independent per-region state |
| Global | `main_central_*.tf` | `var.region.global` | AWS-constrained to us-east-1, or account-wide with regional components |
| Common | `main_central_log.tf` | `var.region.primary` | Shared infrastructure (logs, buckets) placed at development base |
| Regionless | `main_central_iam*.tf` | (none) | IAM, OIDC, S3 account settings — truly global |

### Classification Method

For each AWS resource, check Terraform documentation:
- Has `region` attribute and independent per-region state → **Regional**
- AWS-constrained to us-east-1 or account-wide data → **Global**
- IAM/OIDC/account-level settings with no region concept → **Regionless**

## Resource Classification

### Regional Services (`for_each = toset(var.region.targets)`)

| Resource | File |
|----------|------|
| GuardDuty (`aws_guardduty_detector`) | `main_regional_guardduty.tf` |
| Config (`aws_config_configuration_recorder`) | `main_regional_config.tf` |
| Inspector2 (`aws_inspector2_enabler`) | `main_regional_inspector2.tf` |
| Macie (`aws_macie2_account`) | `main_regional_macie.tf` |
| KMS (`aws_kms_key`) | `main_regional_kms.tf` |
| EBS (`aws_ebs_encryption_by_default`) | `main_regional_ebs.tf` |
| EC2 Metadata (`aws_ec2_instance_metadata_defaults`) | `main_regional_ec2_metadata.tf` |
| Access Analyzer (`aws_accessanalyzer_analyzer`) | `main_regional_security_access_analyzer.tf` |
| Security Hub (`aws_securityhub_account`) | `main_regional_security_securityhub.tf` |
| Resource Groups (`aws_resourcegroups_group`) | `main_regional_resource_groups.tf` |
| SSM Automation (`aws_ssm_service_setting`) | `main_regional_ssm_automation.tf` |
| Default VPC hardening | `main_regional_security_default_vpc.tf` |

### Global Services (`region = var.region.global`)

| Resource | File | Why Global |
|----------|------|-----------|
| Budgets + Lambda + Scheduler | `main_central_budgets.tf` | Account-wide cost data; one report suffices |
| CloudTrail + Lambda | `main_central_cloudtrail.tf` | Organization trail is account-wide |
| Trusted Advisor + Lambda + Scheduler | `main_central_trusted_advisor.tf` | Account-wide recommendations |
| IAM Password Expired + Lambda + Scheduler | `main_central_iam_password_expired.tf` | IAM is global; one check suffices |
| Lambda VPC | `main_central_lambda_vpc.tf` | Shared VPC for global Lambda functions |

### Common Services (`region = var.region.primary`)

| Resource | File | Why Primary |
|----------|------|------------|
| S3 log bucket | `main_central_log.tf` | Centralized log aggregation at development base |
| S3 CloudTrail bucket | `main_central_log.tf` | Paired with log bucket |

### Regionless Services (no `region` attribute needed)

| Resource | File | Why Regionless |
|----------|------|---------------|
| IAM roles/policies | `main_central_iam*.tf` | IAM is a global service |
| OIDC GitHub | `main_central_oidc_github.tf` | IAM identity provider |
| S3 account public access | `main_central_s3.tf` | Account-level setting |
| Compute Optimizer | `main_central_compute_optimizer.tf` | Account-level opt-in |

## Data Duplication Prevention

Account-wide services (Budgets, Trusted Advisor, IAM Password) must NOT use `for_each` over targets:

```hcl
# ❌ WRONG: Reports same account-wide data N times
module "lambda_function_budgets" {
  for_each = toset(var.region.targets)
  region   = each.value
}

# ✅ CORRECT: Reports once from global region
module "lambda_function_budgets" {
  region = var.region.global
}
```

## Consequences

### Positive

- Clear decision framework for new resources
- No duplicate data collection
- Explicit region placement for all resources

### Negative

- Developers must check classification before adding new resources
- Some services span tiers (e.g., CloudTrail is global but its Lambda is regional) — the file is named by the primary service

## References

- [ADR-0001](./0001-multi-region-terraform-architecture.md) — Multi-Region Architecture
- [AWS Provider v6 Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Document Version**: 2.0  
**Last Updated**: 2026-06-19  
**Status**: ACCEPTED
