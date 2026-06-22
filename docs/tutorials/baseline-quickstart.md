# Bootstrap the Base Terraform Stack

This tutorial walks through the shortest reliable path to get a Terraform stack initialized in a new environment. It covers the `base` stack as the primary example. The other stacks (`monitor`, `management/audit`, `management/root`) follow the same init → plan → apply workflow — only the directory, backend file, and tfvars differ.

> **Scope:** This guide applies to all four stacks. Differences are noted in the [Other Stacks](#other-stacks) section.

## Prerequisites

| Requirement | How to verify |
|-------------|--------------|
| Terraform CLI installed | `terraform version` |
| AWS CLI profile configured | `aws sts get-caller-identity --profile <profile>` |
| S3 state bucket created | See [Initial Setup (Common)](../how-to/initial-setup.md) |
| Backend file prepared (`terraform.<env>.tfbackend`) | Copy from `terraform.example.tfbackend`, fill in bucket name and region |
| Repository cloned locally | `git clone` the repo |

If the S3 state bucket does not yet exist, complete [Initial Setup (Common)](../how-to/initial-setup.md) first.

## Goal

After completing this guide, you will have:

- an environment-specific tfvars file configured for one AWS account
- a successful `terraform init` with remote state
- a reviewed `terraform plan` with the expected resource set
- a first `terraform apply` that establishes the baseline

## Step 1: Prepare the backend file

Copy the example backend file and fill in environment-specific values:

```bash
cd terraform/base
cp terraform.example.tfbackend terraform.dev.tfbackend
```

Edit `terraform.dev.tfbackend`:

```ini
bucket  = "your-state-bucket-name"
key     = "terraform.base.tfstate"
region  = "ap-northeast-1"
```

The bucket name must match the S3 bucket created during [Initial Setup (Common)](../how-to/initial-setup.md).

## Step 2: Prepare the tfvars file

Copy the example tfvars and customize for the target environment:

```bash
cp terraform.example.tfvars terraform.dev.tfvars
```

Open the file and search for `TODO` comments — these mark values that require environment-specific changes. Key settings:

- `region` — target AWS region
- `cloudwatch_log_group` — log group retention and configuration
- `support_iam_role_principal_arns` — ARNs allowed to assume support roles
- `subscriber_email_addresses` — notification recipients

For a full explanation of each variable, see [Base Terraform Configuration Guide](../how-to/configure-base-tfvars.md).

## Step 3: Initialize the stack

```bash
terraform init -backend-config=terraform.dev.tfbackend
```

**Expected output:**

```text
Terraform has been successfully initialized!
```

If initialization fails with an S3 access error, verify:

1. The AWS CLI profile has `s3:GetObject` and `s3:PutObject` on the state bucket
2. The bucket name in the backend file is correct
3. The region matches the bucket's actual region

## Step 4: Review the plan

```bash
terraform plan -var-file=terraform.dev.tfvars
```

Review the plan output. For the base stack, expect resources for:

- CloudTrail, Config, GuardDuty, Security Hub, Inspector, Macie
- IAM groups, roles, and password policies
- CloudWatch log groups and budget alerts
- Default VPC hardening and EBS encryption defaults

Compare against [Terraform Specification](../reference/specification.md) for the full expected resource set.

## Step 5: Apply

```bash
terraform apply -var-file=terraform.dev.tfvars
```

**Expected output:**

```text
Apply complete! Resources: <N> added, 0 changed, 0 destroyed.
```

> **Note:** The first apply may partially fail due to AWS eventual consistency (e.g., IAM propagation delays). If this occurs, run `terraform apply` again. A second apply typically succeeds.

## Verification

Run plan again to confirm a stable state:

```bash
terraform plan -var-file=terraform.dev.tfvars
```

A successful baseline shows `No changes. Your infrastructure matches the configuration.` or only expected deferred changes.

If the plan shows destructive replacements, compare with the lifecycle-sensitive resources described in [Terraform Specification](../reference/specification.md) and [Architecture Overview](../explanation/architecture.md).

## Other Stacks

All stacks follow the same workflow. The only differences are the directory, state key, and configuration guide:

| Stack | Directory | State key | Configuration guide |
|-------|-----------|-----------|-------------------|
| base | `terraform/base` | `terraform.base.tfstate` | [Base Terraform Configuration Guide](../how-to/configure-base-tfvars.md) |
| monitor | `terraform/monitor` | `terraform.monitor.tfstate` | [Monitor Terraform Configuration Guide](../how-to/configure-monitor-tfvars.md) |
| management/audit | `terraform/management/audit` | `terraform.audit.tfstate` | [Management Audit Terraform Configuration Guide](../how-to/configure-management-audit-tfvars.md) |
| management/root | `terraform/management/root` | `terraform.root.tfstate` | [Management Root Terraform Configuration Guide](../how-to/configure-management-root-tfvars.md) |

**Recommended apply order:**

1. `base` — foundational security and IAM (no dependencies)
2. `management/audit` — organization-level security delegation (requires Organizations setup)
3. `management/root` — root account governance, SCPs, OIDC (requires Organizations setup)
4. `monitor` — CloudWatch metrics, logs, events (can reference resources created by base)

> `management/audit` and `management/root` require AWS Organizations to be configured. If you are setting up a single standalone account without Organizations, only `base` and `monitor` are needed.

## Troubleshooting

| Symptom | Cause | Resolution |
|---------|-------|------------|
| `Error: No valid credential sources found` | AWS profile not configured or expired | Run `aws sso login --profile <profile>` or check `~/.aws/credentials` |
| `Error: Failed to get existing workspaces` | S3 bucket doesn't exist or wrong region | Verify bucket name and region in tfbackend file |
| `Error: Error acquiring the state lock` | Another process holds the lock | Wait or force-unlock with `terraform force-unlock <ID>` |
| Partial apply failure on first run | AWS eventual consistency | Run `terraform apply` again |

For more details, see [Troubleshooting](../how-to/troubleshooting.md).

## Next Steps

- [Terraform Specification](../reference/specification.md) — Repository-level behavior and lifecycle rules
- [Architecture Overview](../explanation/architecture.md) — Account structure and stack layout
- [Troubleshooting](../how-to/troubleshooting.md) — Diagnose init, provider, or multi-region issues
