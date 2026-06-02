# Bootstrap the Base Terraform Stack

This tutorial walks through the shortest reliable path to get the base Terraform stack initialized in a new environment. It is for operators who already have an AWS profile and a Terraform backend bucket available and want a first successful plan and apply without choosing between multiple paths.

## Prerequisites

- Terraform installed locally
- An AWS CLI profile with permissions to read and create the base stack resources
- A prepared backend configuration file such as `terraform.dev.tfbackend`
- A writable working copy of this repository

## Goal

After completing this guide, you will have:

- a base environment-specific tfvars file configured for one AWS account
- a successful `terraform init` for `terraform/base`
- a reviewed `terraform plan` with the expected resource set
- a first `terraform apply` that establishes the base security and logging baseline

## Step 1: Set the base environment values

Open [README-base-tfvars.md](../how-to/configure-base-tfvars.md) and choose the values for the target environment, especially `region`, `cloudwatch_log_group`, `support_iam_role_principal_arns`, and `subscriber_email_addresses`.

If you are starting from the repository example, use `terraform/base/terraform.example.tfvars` as the source of truth for the initial values.

**Expected Output:**
```text
The target region and environment-specific settings are selected.
```

## Step 2: Initialize the base stack

Change into the base Terraform directory and initialize it with the environment backend file.

```sh
cd terraform/base
terraform init -backend-config=terraform.dev.tfbackend
```

**Expected Output:**
```text
Terraform has been successfully initialized!
```

## Step 3: Review the first plan

Run a plan against the same tfvars file you configured in the first step.

```sh
terraform plan -var-file=terraform.example.tfvars
```

Review the plan for the expected baseline services described in [docs/specification.md](../reference/specification.md): security controls, logging, IAM guardrails, and default VPC hardening.

## Step 4: Apply the baseline

Apply the reviewed plan when the resource set matches the intended environment.

```sh
terraform apply -var-file=terraform.example.tfvars
```

**Expected Output:**
```text
Apply complete! resources: <count> added, <count> changed, 0 destroyed.
```

## Verification

Run the plan again with the same backend and tfvars file. A stable environment should show no unexpected changes other than any intentionally delayed resources.

```sh
terraform plan -var-file=terraform.example.tfvars
```

If the plan still shows destructive replacement, compare it with the lifecycle-sensitive resources called out in [docs/specification.md](../reference/specification.md) and [docs/architecture.md](../explanation/architecture.md).

## Next Steps

- [specification.md](../reference/specification.md) - Review the repository-level behavior and lifecycle rules.
- [architecture.md](../explanation/architecture.md) - Understand the account structure and stack layout.
- [troubleshooting.md](../how-to/troubleshooting.md) - Diagnose init, provider, or multi-region issues.
