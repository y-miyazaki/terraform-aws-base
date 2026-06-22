# ADR-0001: Multi-Region Terraform Architecture Using AWS Provider v6 Region Attribute

## Status

✅ **ACCEPTED** (2026-06-18)  
📝 **UPDATED** (2026-06-19) — Consolidated region variables into single `region` object; removed all provider aliases.

## Context

### Problem Statement

Previously, the Terraform configuration in `terraform/base` used a dual-file pattern (`main_<service>.tf` + `main_<service>_us_east_1.tf`) with provider aliases. This approach had:

1. **Code Duplication**: Separate files for each service per region
2. **Poor Scalability**: Adding regions required duplicating files
3. **Fragile Provider Routing**: Provider alias mismatches caused silent misplacement
4. **Multiple Region Variables**: `region`, `target_regions`, `global_resource_region` created confusion

### Constraints

- **AWS Provider v6+**: Supports `region` attribute on individual resources
- **Business Need**: Multiple AWS regions for security services
- **Safety**: Misconfigured region must fail safely

## Decision

**Use AWS Provider v6's resource-level `region` attribute with a unified `region` object variable.**

### Region Variable Design

```hcl
variable "region" {
  type = object({
    global  = string       # CloudFront, WAF, ACM — us-east-1 (AWS constraint)
    primary = string       # Development base, provider fallback, log aggregation
    targets = list(string) # All regions for regional resource deployment
  })
}
```

Validations enforce:
- `primary` must be included in `targets`
- `targets` must have at least one region

### Provider Configuration

Single provider, no aliases. The provider region is a safety fallback only:

```hcl
provider "aws" {
  region = var.region.primary
  default_tags { tags = var.tags }
}
```

### File Naming Convention

| Pattern | Region Source | Example |
|---------|-------------|---------|
| `main_regional_*.tf` | `for_each = toset(var.region.targets)` | GuardDuty, Config, KMS |
| `main_central_*.tf` | `region = var.region.global` | Budgets Lambda, CloudTrail |
| `main_common_*.tf` | `region = var.region.primary` | S3 log buckets |
| `main_central_iam*.tf` | (none — regionless) | IAM roles, OIDC |

### Implementation Pattern

```hcl
# Regional service
module "aws_security_guardduty" {
  for_each = toset(var.region.targets)
  source   = "../../modules/aws/security/guardduty"
  region   = each.value
}

# Global service with regional components (Lambda, Scheduler)
module "lambda_function_budgets" {
  source = "terraform-aws-modules/lambda/aws"
  region = var.region.global
}

# Common shared resource
module "s3_log" {
  source = "terraform-aws-modules/s3-bucket/aws"
  region = var.region.primary
}
```

## Consequences

### Positive

- **Single source of truth**: One `region` object replaces three separate variables
- **Explicit over implicit**: Every resource declares its region — no silent fallback
- **No provider aliases**: Eliminates `provider = aws.global` misrouting risk
- **Scalable**: Adding a region is a one-line change to `region.targets`
- **Safe fallback**: Provider defaults to `primary` if `region` is accidentally omitted

### Negative

- **All modules must accept `region`**: External modules need `region` variable support (terraform-aws-modules already supports this in v6+)
- **Verbosity**: Every resource/module call includes `region =` (acceptable trade-off for explicitness)

## Migration from Previous Design

| Before | After |
|--------|-------|
| `var.region` | `var.region.primary` |
| `var.target_regions` | `var.region.targets` |
| `var.global_resource_region` | `var.region.global` |
| `provider = aws.global` | `region = var.region.global` |
| `provider = aws.us-east-1` | `region = var.region.global` |
| `main_<service>_us_east_1.tf` | Deleted (merged into `main_regional_*.tf`) |
| `locals.is_default_region_us_east_1` | Deleted (no longer needed) |
| `locals.regional_providers` | Deleted (no longer needed) |

## Variable Configuration

```hcl
# terraform.dev.tfvars
region = {
  global  = "us-east-1"
  primary = "ap-northeast-1"
  targets = ["ap-northeast-1", "us-east-1"]
}
```

## References

- [AWS Provider v6 Release Notes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ADR-0002: Global vs Regional Resource Classification](./0002-global-vs-regional-resource-classification.md) — Global vs Regional Resource Classification

---

**Document Version**: 2.0  
**Last Updated**: 2026-06-19  
**Status**: ACCEPTED
