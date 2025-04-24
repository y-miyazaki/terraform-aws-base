<!-- omit in toc -->
# How do we fix monitor tfvars?

The example is [terraform.example.tfvars](terraform/monitor/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.
If you need to adjust the parameters, you can do so by yourself by searching TODO.

<!-- omit in toc -->
# Table of Contents

- [Initial setting](#initial-setting)
- [Required](#required)
  - [deploy\_user](#deploy_user)
  - [region](#region)
- [Not Required](#not-required)
  - [tags](#tags)
  - [Slack](#slack)
  - [is\_enabled](#is_enabled)

# Initial setting

This section describes the initial settings for running [monitor's Terraform](./terraform/monitor/). If an item has already been addressed, please skip to the next section.

- Remove the access key from the root account  
  Since this is a security issue, let's remove the access key from the root account from the management console.

- Manual creation of IAM user and IAM group to run Terraform  
  Create an IAM user and an IAM group from the management console in order to run Terraform.
  Create an IAM group (pseudonym: deploy). Attach AdministratorAccess as the policy.
  Create an IAM user (pseudonym: terraform), giving it only Programmatic access for Access Type, and add it to the IAM group (pseudonym: deploy).

- Create an S3 to store the Terraform State  
  Create an S3 from the management console to manage the Terraform State.
  However, if you have an environment where you can run the aws command and profile already configured, you can create an S3 by running the following command.
  <https://github.com/y-miyazaki/cloud-commands/blob/master/cmd/awstfinitstate>

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
  You need to rename the linked file [terraform.example.tfvars](terraform/monitor/terraform.example.tfvars) and change each variable for your environment. The variables that need to be changed are marked with TODO comments; search for them in TODO.
- main_provider.tf file to set for each environment  
  Rename the linked file [main_provider.tf.example](terraform/monitor/main_provider.tf.example) to main_provider.tf. After that, you need to change each parameter. The variables that need to be changed are marked with TODO comments, search for them in TODO.

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
module.aws_s3_bucket_log_id.this: Creation complete after 0s [id=wiatHg]
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

- Log:Application

```terraform
#--------------------------------------------------------------
# Log:Application
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Application.
#--------------------------------------------------------------
metric_log_application = {
  # TODO: need to set is_enabled for settings of application log.
  is_enabled = false
```

- Log:Postgres

```terraform
#--------------------------------------------------------------
# Log:Postgres
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Postgres.
#--------------------------------------------------------------
metric_log_postgres = {
  # TODO: need to set is_enabled for settings of postgres log.
  is_enabled = false
```

- Metrics:ALB

```terraform
#--------------------------------------------------------------
# Metrics:ALB
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about ALB will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------
metric_resource_alb = {
  # TODO: need to set is_enabled for Metric of ALB.
  is_enabled = false
```

- Metrics:API Gateway

```terraform
#--------------------------------------------------------------
# Metrics:API Gateway
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about API Gateway will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html
#--------------------------------------------------------------
metric_resource_api_gateway = {
  # TODO: need to set is_enabled for Metric of API Gateway.
  is_enabled = false
```

- Metrics:CloudFront

```terraform
#--------------------------------------------------------------
# Metrics:CloudFront
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about CloudFront will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/monitoring-using-cloudwatch.html
#--------------------------------------------------------------
metric_resource_cloudfront = {
  # TODO: need to set is_enabled for Metric of CloudFront.
  is_enabled = false
```

- Metrics:EC2

```terraform
#--------------------------------------------------------------
# Metrics:EC2
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about EC2 will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html
#--------------------------------------------------------------
metric_resource_ec2 = {
  # TODO: need to set is_enabled for Metric of EC2.
  is_enabled = false
```

- Metrics:ElastiCache

```terraform
#--------------------------------------------------------------
# Metrics:ElastiCache
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about ElastiCache will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.html
#--------------------------------------------------------------
metric_resource_elasticache = {
  # TODO: need to set is_enabled for Metric of ElastiCache.
  is_enabled = false
```

- Metrics:Lambda

```terraform
#--------------------------------------------------------------
# Metrics:Lambda
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about Lambda will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html
#--------------------------------------------------------------
metric_resource_lambda = {
  # TODO: need to set is_enabled for monitor of Lambda.
  is_enabled = false
```

- Metrics:RDS

```terraform
#--------------------------------------------------------------
# Metrics:RDS
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about RDS will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html
#--------------------------------------------------------------
metric_resource_rds_cluster = {
  # TODO: need to set is_enabled for monitor of RDS.
  is_enabled = false
```

- Metrics:SES

```terraform
#--------------------------------------------------------------
# Metrics:SES
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about SES will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/ses/latest/dg/event-publishing-retrieving-cloudwatch.html
#--------------------------------------------------------------
metric_resource_ses = {
  # TODO: need to set is_enabled for monitor of SES.
  is_enabled = false
```

- CloudWatch Events:EC2

```terraform
#--------------------------------------------------------------
# CloudWatch Events:EC2
# The following events are monitored.
# - EC2 Instance Rebalance Recommendation
# - EC2 Spot Instance Interruption Warning
#--------------------------------------------------------------
cloudwatch_event_ec2 = {
  # TODO: need to set is_enabled for settings of EC2.
  is_enabled = false
```

- Metrics:Synthetics Canary

```terraform
#--------------------------------------------------------------
# Metrics: Synthetics Canary
# You can use Amazon CloudWatch Synthetics to create canaries,
# configurable scripts that run on a schedule, to monitor your endpoints and APIs.
# Canaries follow the same routes and perform the same actions as a customer,
# which makes it possible for you to continually verify your customer experience even
# when you don't have any customer traffic on your applications. By using canaries,
# you can discover issues before your customers do.
#
# Using Synthetics Canary, the status code is checked against the specified URL,
# and if an unexpected status code is returned, the user is notified via Slack.
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html
#--------------------------------------------------------------
metric_synthetics_canary = {
  # TODO: need to set is_enabled for Metric of Synthetics Canary.
  is_enabled = false
```

- Athena

```terraform
#--------------------------------------------------------------
# Athena
# Amazon Athena is an interactive query service that makes it easy to 
# analyze data directly in Amazon Simple Storage Service (Amazon S3) using standard SQL.
# With a few actions in the AWS Management Console, you can point Athena at your data stored in
# Amazon S3 and begin using standard SQL to run ad-hoc queries and get results in seconds.
#
# With this configuration, CloudFront and SES logs can be viewed in Athena.
#--------------------------------------------------------------
athena = {
  # TODO: need to set is_enabled for Athena.
  is_enabled     = false
  .
  .
  .
  # TODO: To check CloudFront logs with Athena, specify true.
  enabled_cloudfront    = false
  # TODO: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
  cloudfront_log_bucket = "s3://{bucket name}/{bucket prefix}"
  # TODO: To check SES logs with Athena, specify true.
  enabled_ses = false
  # TODO: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
  ses_log_bucket = "s3://{bucket name}/{bucket prefix}"  
```
