# How do we fix tfvars?

The example is [terraform.example.tfvars](terraform/base/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.  
If you need to adjust the parameters, you can do so by yourself by searching TODO.

- [Required](#required)
  - [deploy_user](#deployuser)
  - [region](#region)
  - [support_iam_role_principal_arns](#supportiamroleprincipalarns)
- [Not Required](#not-required)
  - [tags](#tags)
  - [Slack](#slack)
  - [is_enabled](#isenabled)

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
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
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
