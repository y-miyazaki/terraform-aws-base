<!-- omit in toc -->
# How do we fix base tfvars?

The example is [terraform.example.tfvars](terraform/base/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.
If you need to adjust the parameters, you can do so by yourself by searching TODO.

<!-- omit in toc -->
# Table of Contents
- [Initial setting](#initial-setting)
- [Required](#required)
  - [deploy_user](#deploy_user)
  - [region](#region)
  - [support_iam_role_principal_arns](#support_iam_role_principal_arns)
  - [subscriber_email_addresses](#subscriber_email_addresses)
- [Not Required](#not-required)
  - [tags](#tags)
  - [Slack](#slack)
  - [is_enabled](#is_enabled)

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
  https://github.com/y-miyazaki/cloud-commands/blob/master/cmd/awstfinitstate

```sh
# awstfinitstate -h

This command creates a S3 Bucket for Terraform State.
You can also add random hash to bucket name suffix.

Usage:
    awstfinitstate -r {region} -b {bucket name} -p {profile}[<options>]
    awstfinitstate -r ap-northeast-1 -b terraform-state
    awstfinitstate -r ap-northeast-1 -b terraform-state -p default -s

Options:
    -b {bucket name}          S3 bucket name
    -p {aws profile name}     Name of AWS profile
    -r {region}               S3 region
    -s                        If set, a random hash will suffix bucket name.
    -h                        Usage awstfinitstate

# awstfinitstate -r ap-northeast-1 -b terraform-state -p default -s
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
bucket_name: terraform-state-xxxxxxxxxx
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
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
  backend "s3" {
    # TODO: need to change bucket for terraform state.
    bucket = "xxxxxxxxxxxxxxxx"
    # TODO: need to change bucket key for terraform state.
    key = "xxxxxxxxxx"
    # TODO: need to change profile for terraform state.
    profile = "default"
    # TODO: need to change region for terraform state.
    region = "ap-northeast-1"
  }
}

#--------------------------------------------------------------
# AWS Provider
# access key and secret key should not use.
#--------------------------------------------------------------
provider "aws" {
  # TODO: need to change profile.
  profile = "default"
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
module.aws_recipes_s3_bucket_log_log.random_id.this: Creating...
random_id.this: Creating...
module.aws_recipes_s3_bucket_log_logdom_id.this: Creation complete after 0s [id=wiatHg]
random_id.this: Creation complete after 0s [id=uqe0bU7J]
module.aws_recipes_security_default_vpc.aws_default_subnet.this[1]: Creating...

...
...
...

Apply complete! resources: x added, x changed, 0 destroyed.
```

# Required

The following items must be modified; terraform apply will fail if you run it as an example.

## deploy_user

Specify a user to deploy Terraform that has been registered as an IAM user.
Of course, you can narrow down the permissions, but due to the large number of permissions required, give the user `Administrator Access` to deploy Terraform.

```
#--------------------------------------------------------------
# Deploy IAM user
#--------------------------------------------------------------
# TODO: need to change deploy IAM user.
deploy_user = "terraform"
```

## region

Select the region where you want to create the resource.

```
# TODO: need to change region.
region = "ap-northeast-1"
```

## support_iam_role_principal_arns

The following are the supporting IAM roles. If you are not sure, please specify your AWS Account ID once. For detailed documentation, please see

https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation

```
  # TODO: need to set principal role arn for Support IAM Role.
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation
  support_iam_role_principal_arns = [
    # example)
    # "arn:aws:iam::{account id}:{iam user}"
    "arn:aws:iam::999999999999:root"
  ]
```

## subscriber_email_addresses

The following are the supporting Budgets. If you want to receive Budgets notifications, you must set the email address for Budgets notifications to subscriber_email_addresses.

```
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

```
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

```
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
      SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
```

## is_enabled

The variable for each function has is_enabled. If you do not want to use it as a function, you can disable it by specifying false.

- Budgets

```
#--------------------------------------------------------------
# Budgets
#--------------------------------------------------------------
budgets = {
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
```

- IAM

```
#--------------------------------------------------------------
# IAM: Users
#--------------------------------------------------------------
iam = {
  # TODO: need to set is_enabled for settings of IAM.
  is_enabled = true
```

- Compute Optimizer

```
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

```
#--------------------------------------------------------------
# Health
#--------------------------------------------------------------
health = {
  # TODO: need to set is_enabled for settings of AWS Health.
  is_enabled = true
```

- Trusted Advisor

```
#--------------------------------------------------------------
# Trusted Advisor
#--------------------------------------------------------------
trusted_advisor = {
  # TODO: need to set is_enabled for settings of Trusted Advisor.
  // If you are not in a business or enterprise plan with a support plan, set is_enable to false as notifications will fail. If not, set it to true.
  is_enabled = false
```

- Access Analyzer

```
#--------------------------------------------------------------
# Security:Access Analyzer
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
```

- Access Analyzer

```
#--------------------------------------------------------------
# Security:Access Analyzer
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
```

- CloudTrail

```
#--------------------------------------------------------------
# Security:CloudTrail
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = true
```

- AWS Config

```
#--------------------------------------------------------------
# Security:AWS Config
#--------------------------------------------------------------
security_config = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = true
```

- Security:AWS Config(us-east-1(CloudFront))

```
#--------------------------------------------------------------
# Security:AWS Config(us-east-1(CloudFront))
#--------------------------------------------------------------
security_config_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
```

- Security: Default VPC

```
#--------------------------------------------------------------
# Security:Default VPC
#--------------------------------------------------------------
security_default_vpc = {
  # TODO: need to set is_enabled for settings of default VPC security.
  is_enabled           = true
```

- Security: EBS

```
#--------------------------------------------------------------
# Security:EBS
#--------------------------------------------------------------
security_ebs = {
  # TODO: need to set is_enabled for settings of EBS.
```

- Security:GuardDuty

```
#--------------------------------------------------------------
# Security:GuardDuty
#--------------------------------------------------------------
security_guardduty = {
  # TODO: need to set is_enabled for settings of GuardDuty.
  is_enabled = true
```

- Security:IAM

```
#--------------------------------------------------------------
# Security:IAM
#--------------------------------------------------------------
security_iam = {
  # TODO: need to set is_enabled for settings of IAM security.
  is_enabled = true
```

- Security:S3

```
#--------------------------------------------------------------
# Security:S3
#--------------------------------------------------------------
security_s3 = {
  # TODO: need to set is_enabled for settings of S3 security.
  is_enabled = true
```

- Security:SecurityHub

```
#--------------------------------------------------------------
# Security:SecurityHub
#--------------------------------------------------------------
security_securityhub = {
  # TODO: need to set is_enabled for settings of SecurityHub.
  is_enabled = true
```
