# Design Document — Terraform Modules and Root Configurations

This document describes the structural conventions, variable design patterns, and naming rules used across the Terraform modules and root configurations in this repository.

## Module Architecture

### Root Module Directory Structure

Each Terraform root module (`terraform/base/`, `terraform/management/audit/`, `terraform/management/root/`, `terraform/monitor/`) follows a consistent layout:

```text
terraform/<layer>/
├── main_provider.tf              # Terraform and provider version constraints
├── main_common_data.tf           # Shared data sources (caller identity, region)
├── main_common_log.tf            # Common CloudWatch Log Group configuration
├── main_<service>.tf             # One file per AWS service/module call
├── main_<service>_us_east_1.tf   # us-east-1 regional counterpart (when needed)
├── locals.tf                     # Derived values and flag computation
├── variables.tf                  # All input variable declarations
├── terraform.<env>.tfvars        # Environment-specific variable values
├── terraform.<env>.tfbackend     # Environment-specific S3 backend config
└── .tflint.hcl                   # TFLint configuration
```

**File naming rule**: One `main_<service>.tf` file per logical service group. Cross-region resources append `_us_east_1` suffix rather than duplicating the primary file.

### Module Directory Structure

Reusable modules under `modules/aws/` follow a flat structure:

```text
modules/aws/<category>/<module_name>/
├── main.tf         # Resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
└── scripts/        # External data source scripts (when needed)
```

## Design Policies

### is_enabled Toggle Pattern

Every module and every resource within a root configuration exposes an `is_enabled` boolean. This allows selective activation per environment without removing code.

```hcl
module "aws_security_guardduty" {
  source     = "../../modules/aws/security/guardduty"
  is_enabled = var.security_guardduty.is_enabled && !local.control_tower_managed_services.guardduty
  # ...
}
```

When `is_enabled = false`, the module creates zero resources. This is preferred over `count`/`for_each` at the root level to keep diffs minimal.

### Control Tower Managed Services Override

The `control_tower` variable in `terraform/base/` describes whether Control Tower or Organizations centrally manages each security service. When a service is centrally managed, the corresponding module skips local resource creation to avoid conflicts.

```hcl
locals {
  control_tower_managed_services = {
    guardduty = coalesce(try(var.control_tower.managed_services.guardduty, null), local.is_control_tower_enabled)
    # ... other services
  }
}
```

If `managed_services.<service>` is omitted in the tfvars, it falls back to the top-level `is_enabled` flag.

### Multi-Region Pattern (us-east-1)

Several AWS services require resources in `us-east-1` regardless of the primary region (e.g., CloudFront metrics, WAF global, ACM for CloudFront). The convention is:

- Primary region resources: `main_<service>.tf` using `provider "aws" {}`
- us-east-1 resources: `main_<service>_us_east_1.tf` using `provider "aws" { alias = "us-east-1" }`
- Guard to avoid duplication when primary region is already `us-east-1`:

```hcl
locals {
  is_default_region_us_east_1 = var.region == "us-east-1"
  is_enabled_us_east_1        = !local.is_default_region_us_east_1 && var.us_east_1.is_enabled
}
```

## Variable Design

### Nested Object Variables

Variables representing a single service's configuration are grouped into a typed object. Required boolean `is_enabled` is always the first field:

```hcl
variable "security_guardduty" {
  type = object({
    is_enabled = bool
    aws_guardduty_detector = object({
      # ...
    })
  })
}
```

### Optional Fields with Fallback

Use `optional()` with a default for fields that can be omitted in tfvars. Use `coalesce(try(..., null), default_value)` in `locals.tf` to resolve priority chains:

```hcl
variable "cloudwatch_log_group" {
  type = object({
    retention_in_days = number
    override = optional(object({
      # per-service overrides
    }))
  })
}
```

### Common Variables Across Root Modules

| Variable        | Type                          | Description                                                     |
| --------------- | ----------------------------- | --------------------------------------------------------------- |
| `name_prefix`   | `string`                      | Short prefix applied to all resource names (e.g., `"myco-dev"`) |
| `region`        | `string`                      | Primary AWS region (e.g., `"ap-northeast-1"`)                   |
| `tags`          | `map(any)`                    | Tags applied to all resources via provider `default_tags`       |
| `control_tower` | `object`                      | Control Tower enablement and per-service managed-service flags  |
| `us_east_1`     | `object({is_enabled = bool})` | Whether to create us-east-1 counterpart resources               |

## Naming Conventions

### Resource Naming

All resource names use `name_prefix` as a prefix to namespace resources per environment:

```hcl
name = "${var.name_prefix}-guardduty-detector"
```

Recommended `name_prefix` format: `<org>-<env>` (e.g., `acme-dev`, `acme-prd`).

### Terraform State Keys

S3 state keys follow the pattern `terraform.<layer>.tfstate`:

| Root Module                   | State Key                            |
| ----------------------------- | ------------------------------------ |
| `terraform/base/`             | `terraform.base.tfstate`             |
| `terraform/management/audit/` | `terraform.management.audit.tfstate` |
| `terraform/management/root/`  | `terraform.management.root.tfstate`  |
| `terraform/monitor/`          | `terraform.monitor.tfstate`          |

### Module Source Paths

Internal modules use relative paths from the root module. Third-party modules use the Terraform Registry with a pinned `version`:

```hcl
# Internal
source = "../../modules/aws/security/guardduty"

# External (always pin version)
source  = "terraform-aws-modules/kms/aws"
version = "4.2.0"
```

## State Management

Each root module uses an S3 backend configured via a per-environment `.tfbackend` file:

```hcl
# terraform/base/terraform.example.tfbackend
bucket  = "base-terraform-state-example"
key     = "terraform.base.tfstate"
region  = "ap-northeast-1"
```

Initialize with an environment-specific backend:

```sh
terraform init -backend-config=terraform.<env>.tfbackend
```

Apply with a matching tfvars file:

```sh
terraform apply -var-file=terraform.<env>.tfvars
```

## Provider Configuration

All root modules declare `required_version = ">=1.12"` and pin the AWS provider to `~>6.0`. Tags are injected globally via `default_tags` on the provider to avoid per-resource tag repetition:

```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}
```

## Cross-References

- [architecture.md](./architecture.md) — Account structure and Terraform directory layout
- [module_catalog.md](./module_catalog.md) — Index of all reusable modules with purpose and inputs
- [design_decisions.md](./design_decisions.md) — Specific decisions: KMS key policy, external data sources, Access Analyzer patterns
