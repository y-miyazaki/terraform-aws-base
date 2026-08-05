# Initial Setup (Common)

Common prerequisites before running any Terraform stack (`base`, `management/audit`, `management/root`, `monitor`).

## Prerequisites

| Step | Action                                     | Notes                                                                                                                |
| ---- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| 1    | Remove root account access key             | Security requirement — do this via AWS Console                                                                       |
| 2    | Create IAM user/group for Terraform        | Create group (e.g., `deploy`) with `AdministratorAccess`, add user (e.g., `terraform`) with programmatic access only |
| 3    | Create S3 bucket for Terraform state       | See [script usage](#create-state-bucket) below                                                                       |
| 4    | Copy and rename `terraform.example.tfvars` | Search for `CUSTOMIZE` comments to identify required changes                                                         |
| 5    | Run `terraform init && terraform apply`    | May need a second `apply` if conflicts occur                                                                         |

## Create State Bucket

Use the provided script to create an S3 bucket with optional random suffix:

```bash
./scripts/terraform/aws_init_state.sh -r {region} -b {bucket-name} -p {profile} [-s]
```

| Flag | Description                              |
| ---- | ---------------------------------------- |
| `-r` | AWS region (e.g., `ap-northeast-1`)      |
| `-b` | S3 bucket name                           |
| `-p` | AWS CLI profile name                     |
| `-s` | Append random hash suffix to bucket name |

**Example:**

```bash
./scripts/terraform/aws_init_state.sh -r ap-northeast-1 -b base-terraform-state- -p default -s
# Output: bucket_name: base-terraform-state-xxxxxxxxxx
```

## Run Terraform

```bash
terraform -chdir=terraform/{stack} init
terraform -chdir=terraform/{stack} apply -var-file=terraform.tfvars
```

> **Note:** The first `apply` may fail due to eventual consistency or dependency ordering. Run it again if this occurs.

## Next Steps

- [Base Terraform Configuration Guide](./configure-base-tfvars.md)
- [Monitor Terraform Configuration Guide](./configure-monitor-tfvars.md)
- [Management Audit Terraform Configuration Guide](./configure-management-audit-tfvars.md)
- [Management Root Terraform Configuration Guide](./configure-management-root-tfvars.md)
