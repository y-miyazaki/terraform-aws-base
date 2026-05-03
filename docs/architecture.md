# Architecture Overview

This document provides structural context for AI assistants. It describes the organization design, account structure, Terraform layout, and key design decisions.

## AWS Organization Structure

Multi-account AWS Organization with delegated administration for security services. The typical account structure is:

- **Root account** — Organization management, SCPs, billing
- **Audit account** — Delegated admin for security services (SecurityHub, GuardDuty, Access Analyzer, Inspector2)
- **Workload accounts** — Per-environment (dev/qa/stg/prd) or per-project
- **Log Archive account** — Centralized log storage

To check actual account IDs and profiles, refer to `~/.aws/config` or the credentials file specified in the project.

### Delegated Administration

The audit account is delegated admin for:

- `access-analyzer.amazonaws.com`
- `guardduty.amazonaws.com`
- `inspector2.amazonaws.com`
- `securityhub.amazonaws.com`

Terraform verifies delegation status at plan time via `module.delegated_services`. If the account is not delegated for a service, the corresponding resources are skipped automatically.

Verify delegation status manually:

```sh
aws organizations list-delegated-services-for-account --account-id <AUDIT_ACCOUNT_ID>
```

## Terraform Directory Layout

```text
terraform/
├── base/                    # Per-account baseline (security, IAM, VPC, KMS)
├── management/
│   ├── audit/               # Delegated admin: SecurityHub, GuardDuty, Access Analyzer, Inspector2
│   └── root/                # Org root: CloudTrail, Budgets, Lambda VPC, Organizations Policy
└── monitor/                 # CloudWatch metrics, logs, EventBridge, Athena
```

Each directory is an independent Terraform root module with its own state:

- `base/` — Runs per-account with account-specific tfvars (dev/qa/stg/prd)
- `management/audit/` — Runs in audit account only (profile: `audit`)
- `management/root/` — Runs in root account only (profile: `activecore`)
- `monitor/` — Runs per-account for monitoring setup

## Multi-Region Pattern

Services requiring us-east-1 coverage use a dual-module pattern:

```text
main_<service>.tf              → default region (var.region)
main_<service>_us_east_1.tf    → us-east-1 (provider alias: aws.us-east-1)
```

Controlled by `us_east_1.is_enabled` in tfvars. If default region is already us-east-1, the `_us_east_1` variant is automatically skipped via `locals.is_enabled_us_east_1`.

## Feature Toggle Pattern

All services use `is_enabled` flags in tfvars. Modules use `count` for the toggle:

```hcl
count = var.is_enabled ? 1 : 0
```

Organization-level services combine multiple conditions:

```hcl
is_enabled = var.<service>.is_enabled && local.is_delegated_admin.<service>
```
