<!-- omit in toc -->
# How do we fix base tfvars?

The example is [terraform.example.tfvars](terraform/base/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.
If you need to adjust the parameters, you can do so by yourself by searching TODO.

<!-- omit in toc -->
# Table of Contents

- [Initial setting](#initial-setting)
- [Required](#required)
  - [deploy\_user](#deploy_user)
  - [region](#region)
  - [support\_iam\_role\_principal\_arns](#support_iam_role_principal_arns)
  - [subscriber\_email\_addresses](#subscriber_email_addresses)
- [Not Required](#not-required)
  - [tags](#tags)
  - [Slack](#slack)
  - [is\_enabled](#is_enabled)
  - [use\_control\_tower](#use_control_tower)

# Initial setting

This section describes the initial settings for running [Base's Terraform](./terraform/base/). If an item has already been addressed, please skip to the next section.

- Remove the access key from the root account  
  Since this is a security issue, let's remove the access key from the root account from the management console.

- Manual creation of IAM user and IAM group to run Terraform  
  Create an IAM user and an IAM group from the management console in order to run Terraform.
  Create an IAM group (pseudonym: deploy). Attach AdministratorAccess as the policy.
  Create an IAM user (pseudonym: terraform), giving it only Programmatic access for Access Type, and add it to the IAM group (pseudonym: deploy).

- Create an S3 to store the Terraform State  
  Create an S3 from the management console to manage the Terraform State.
  However, if you have an environment where you can run the aws command and profile already configured, you can create an S3 by running the following command.

```sh
$ ./scripts/terraform/init_state.sh -h

This command creates a S3 Bucket for Terraform State.
You can also add random hash to bucket name suffix.

Usage:
    init_state.sh -r {region} -b {bucket name} -p {profile}[<options>]
    init_state.sh -r ap-northeast-1 -b terraform-state
    init_state.sh -r ap-northeast-1 -b terraform-state -p default -s

Options:
    -b {bucket name}          S3 bucket name
    -p {aws profile name}     Name of AWS profile
    -r {region}               S3 region
    -s                        If set, a random hash will suffix bucket name.
    -h                        Usage init_state.sh

$ ./scripts/terraform/init_state.sh -r ap-northeast-1 -b base-terraform-state- -p default -s
~
~
~
~
~
~
~
~
~
~
~
~
~
--------------------------------------------------------------
bucket_name: base-terraform-state-xxxxxxxxxx
region: ap-northeast-1
--------------------------------------------------------------
```

- terraform.{environment}.tfvars file to configure for each environment  
  You need to rename the linked file [terraform.example.tfvars](terraform/base/terraform.example.tfvars) and change each variable for your environment. The variables that need to be changed are marked with TODO comments; search for them in TODO.
- main_provider.tf file to set for each environment  
  Rename the linked file [main_provider.tf.example](terraform/base/main_provider.tf.example) to main_provider.tf. After that, you need to change each parameter. The variables that need to be changed are marked with TODO comments, search for them in TODO.

```terraform
#--------------------------------------------------------------
# Terraform Provider
#--------------------------------------------------------------
terraform {
  required_version = "~>1.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  backend "s3" {
  }
}

#--------------------------------------------------------------
# AWS Provider
# access key and secret key should not use.
#--------------------------------------------------------------
provider "aws" {
  # TODO: need to change region.
  region = "ap-northeast-1"
  #   default_tags {
  #     tags = var.tags
  #   }
}
# Need to add aws provider(us-east-1) for CloudFront Metric.
provider "aws" {
    region = "us-east-1"
    alias  = "us-east-1"
  #   default_tags {
  #     tags = var.tags
  #   }
}
```

- Running Terraform  
  Run the terraform command: terraform init followed by terraform apply.
  You may find that terraform apply fails due to conflicts or other problems, so run it again and it will succeed.

```sh
bash-5.1# terraform init
There are some problems with the CLI configuration:

Error: The specified plugin cache dir /root/.terraform.d/plugin-cache cannot be opened: stat /root/.terraform.d/plugin-cache: no such file or directory


As a result of the above problems, Terraform may not behave as intended.


Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/template from the dependency lock file
- Installing hashicorp/aws v3.29.1...
- Installed hashicorp/aws v3.29.1 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```sh
bash-5.1# terraform apply --auto-approve -var-file=terraform.example.tfvars
module.aws_s3_bucket_log_log.random_id.this: Creating...
random_id.this: Creating...
module.aws_s3_bucket_log_logdom_id.this: Creation complete after 0s [id=wiatHg]
random_id.this: Creation complete after 0s [id=uqe0bU7J]
module.aws_security_default_vpc.aws_default_subnet.this[1]: Creating...

...
...
...

Apply complete! resources: x added, x changed, 0 destroyed.
```

# Required

The following items must be modified; terraform apply will fail if you run it as an example.

## deploy_user

**In recent years, deployment using IAM roles is considered better from a security standpoint, so you can usually leave this value as null.
**  
Specify a user to deploy Terraform that has been registered as an IAM user.  
Of course, you can narrow down the permissions, but due to the large number of permissions required, give the user `Administrator Access` to deploy Terraform.

```terraform
#--------------------------------------------------------------
# Deploy IAM user
#--------------------------------------------------------------
# TODO: need to change deploy IAM user.
# This is the IAM user that will be used to deploy the resources. However, if you are not deploying using an IAM user, you can leave it as null.
deploy_user = null
```

## region

Select the region where you want to create the resource.

```terraform
#--------------------------------------------------------------
# Default Region for Resources
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"
```

## support_iam_role_principal_arns

The following are the supporting IAM roles. If you are not sure, please specify your AWS Account ID once. For detailed documentation, please see

<https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation>

```terraform
  # TODO: need to set principal role arn for Support IAM Role.
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation
  support_iam_role_principal_arns = [
    # example)
    # "arn:aws:iam::{account id}:{iam user}"
    "arn:aws:iam::123456789012:root"
  ]
```

## subscriber_email_addresses

The following are the supporting Budgets. If you want to receive Budgets notifications, you must set the email address for Budgets notifications to subscriber_email_addresses.

```terraform
budgets = {
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
  # Provides a budgets budget resource. Budgets use the cost visualisation provided
  # by Cost Explorer to show you the status of your budgets, to provide forecasts of
  # your estimated costs, and to track your AWS usage, including your free tier usage.
  aws_budgets_budget = {
    name = "budgets-monthly"
    # TODO: need to change limit_amount for Service
    limit_amount = "100.0"
    time_unit    = "MONTHLY"
    notification = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = "80"
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
        # TODO: need to change subscriber_email_addresses.
        # If the threshold is exceeded, you will be notified to the email address provided.
        # At least one must set an email address.
        subscriber_email_addresses = [
          # example)
          # "youremail@yourtest.test.hogehoge.com"
        ]
        subscriber_sns_topic_arns = null
      }
    ]
  }
```

# Not Required

Although terraform apply will succeed without fixing the following items, the following is a list of things that should be changed for each environment.

## tags

You can leave the following as it is without any problem. However, if you want to add TAGs to the resources according to your environment, please modify the following.

```terraform
# TODO: need to change tags.
tags = {
# TODO: need to change env.
env = "dev"
# TODO: need to change service.
# service is project name or job name or product name.
service = "base"
}
```

## Slack

Basically, for notifications, you need an oauth access token from Slack and a specified channel ID.
If you can get it, please modify all of the following If there is no normal token and channel ID, you will not be notified, but the deployment itself will succeed.

```terraform
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
      SLACK_OAUTH_ACCESS_TOKEN = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
```

## is_enabled

The variable for each function has is_enabled. If you do not want to use it as a function, you can disable it by specifying false.

- IAM OIDC for GitHub Actions

```terraform
#--------------------------------------------------------------
# IAM OIDC for GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#--------------------------------------------------------------
oidc_github = {
  # TODO: need to set is_enabled for settings of IAM OIDC for GitHub Actions.
  is_enabled = true
```

- Budgets

```terraform
#--------------------------------------------------------------
# Budgets
#--------------------------------------------------------------
budgets = {
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
```

- IAM

```terraform
#--------------------------------------------------------------
# IAM: Users
#--------------------------------------------------------------
iam = {
  # TODO: need to set is_enabled for settings of IAM.
  is_enabled = true
```

- Compute Optimizer

```terraform
#--------------------------------------------------------------
# Compute Optimizer
# AWS Compute Optimizer recommends optimal AWS resources for your workloads to reduce
# costs and improve performance by using machine learning to analyze historical utilization metrics.
# Over-provisioning resources can lead to unnecessary infrastructure cost, and under-provisioning resources
# can lead to poor application performance. Compute Optimizer helps you choose optimal configurations
# for three types of AWS resources: Amazon EC2 instances, Amazon EBS volumes, and AWS Lambda functions,
# based on your utilization data.
#--------------------------------------------------------------
compute_optimizer = {
# TODO: need to set is_enabled for settings of Compute Optimizer.
is_enabled = true
}
```

- Health

```terraform
#--------------------------------------------------------------
# Health
#--------------------------------------------------------------
health = {
  # TODO: need to set is_enabled for settings of AWS Health.
  is_enabled = true
```

- Trusted Advisor

```terraform
#--------------------------------------------------------------
# Trusted Advisor
#--------------------------------------------------------------
trusted_advisor = {
  # TODO: need to set is_enabled for settings of Trusted Advisor.
  // If you are not in a business or enterprise plan with a support plan, set is_enable to false as notifications will fail. If not, set it to true.
  is_enabled = false
```

- IAM password expired

```terraform
#--------------------------------------------------------------
# IAM password expired
# A list of target users will be automatically notified in Slack 10 days before the IAM password expires.
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
iam_password_expired = {
  # TODO: need to set is_enabled for settings of IAM password expired.
  is_enabled = false
```

- Security:Access Analyzer

```terraform
#--------------------------------------------------------------
# Security:Access Analyzer
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
```

- Security:CloudTrail

```terraform
#--------------------------------------------------------------
# Security:CloudTrail
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = true
```

- Security:AWS Config

```terraform
#--------------------------------------------------------------
# Security:AWS Config
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security_config = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = true
```

- Security:AWS Config(us-east-1(CloudFront))

```terraform
#--------------------------------------------------------------
# Security:AWS Config(us-east-1(CloudFront))
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security_config_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
```

- Security: Default VPC

```terraform
#--------------------------------------------------------------
# Security:Default VPC
#--------------------------------------------------------------
security_default_vpc = {
  # TODO: need to set is_enabled for settings of default VPC security.
  is_enabled           = true
```

- Security: EBS

```terraform
#--------------------------------------------------------------
# Security:EBS
#--------------------------------------------------------------
security_ebs = {
  # TODO: need to set is_enabled for settings of EBS.
```

- Security:GuardDuty

```terraform
#--------------------------------------------------------------
# Security:GuardDuty
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security_guardduty = {
  # TODO: need to set is_enabled for settings of GuardDuty.
  is_enabled = true
```

- Security:IAM

```terraform
#--------------------------------------------------------------
# Security:IAM
#--------------------------------------------------------------
security_iam = {
  # TODO: need to set is_enabled for settings of IAM security.
  is_enabled = true
```

- Security:S3

```terraform
#--------------------------------------------------------------
# Security:S3
#--------------------------------------------------------------
security_s3 = {
  # TODO: need to set is_enabled for settings of S3 security.
  is_enabled = true
```

- Security:SecurityHub

```terraform
#--------------------------------------------------------------
# Security:SecurityHub
# Notice: This option is automatically disabled if use_control_tower=true.
#--------------------------------------------------------------
security_securityhub = {
  # TODO: need to set is_enabled for settings of SecurityHub.
  is_enabled = true
```

## use_control_tower

If you are using AWS Control Tower to manage your AWS Organization, you should set this option to `true`. When enabled, several security services will be automatically disabled as they are already managed by Control Tower.

```terraform
#--------------------------------------------------------------
# Check use Control Tower
# If you are using Control Tower, set use_control_tower to true. If you set it to true, some options will be ignored.
#--------------------------------------------------------------
# TODO: need to change use Control Tower.
use_control_tower = false
```

Setting `use_control_tower=true` will automatically disable the following services to avoid conflicts:

- CloudTrail
- GuardDuty
- SecurityHub
- AWS Config (both regional and us-east-1)
- IAM password expiration notifications

This helps prevent duplicate configurations and potential conflicts between your Terraform-managed resources and those managed by AWS Control Tower.
