# Base Features Detail

Detailed descriptions for features managed by `terraform/base/`. For configuration, see [Base Terraform Configuration Guide](../how-to/configure-base-tfvars.md).

## Security

### Access Analyzer

AWS IAM Access Analyzer helps you identify resources in your organization and accounts that are shared with an external entity. This enables you to identify unintended access to your resources and data.

### Athena (Security)

Creates an Athena workgroup dedicated to security queries, enabling SQL-based analysis of security-related logs stored in S3 (e.g., CloudTrail logs).

### CloudTrail

AWS CloudTrail is a service for governance, compliance, operational and risk auditing of AWS accounts. CloudTrail enables you to log, continuously monitor and retain account activity across your AWS infrastructure.

After configuring the Slack channel, adding the Slack app, and setting the OAuthToken, Slack notifications will be sent.

![CloudTrail](../image/slack_cloudtrail.png)

### Config

AWS Config is a service that allows you to evaluate, audit, and review the configuration of AWS resources. Config continuously monitors and records the configuration of AWS resources and automatically evaluates the recorded configuration against the desired settings.

After configuring the Slack channel, adding the Slack app, and setting the OAuthToken, Slack notifications will be sent.

![Config](../image/slack_config.png)

### Default VPC

Default VPC hardening ensures that the default VPC in each region is secured by removing default rules and applying restrictive configurations. This includes disabling default security group rules and enabling VPC Flow Logs for monitoring.

### EBS

Manages EBS account-level security defaults including EBS Encryption by Default and public snapshot access blocking. This ensures all new EBS volumes are encrypted and prevents accidental public exposure of snapshots.

### EC2 Metadata (IMDSv2)

Enforces Instance Metadata Service Version 2 (IMDSv2) at the account level via `aws_ec2_instance_metadata_defaults`. This sets `http_tokens = "required"` so all new EC2 instances default to IMDSv2 without needing per-instance configuration. (Security Hub: EC2.8)

### ECR

Configures ECR account-level security defaults by setting the basic scan type to `AWS_NATIVE`, which uses AWS's native scanning technology for container image vulnerability scanning.

### GuardDuty

Amazon GuardDuty is a threat detection service that continuously monitors for malicious or unauthorized activity in order to protect AWS accounts, workloads, and data stored in Amazon S3.

After configuring the Slack channel, adding the Slack app, and setting the OAuthToken, Slack notifications will be sent.

![GuardDuty](../image/slack_guardduty.png)

### Inspector2

Amazon Inspector is an automated vulnerability management service that continually scans AWS workloads for software vulnerabilities and unintended network exposure. Inspector2 supports scanning for EC2 instances, container images in ECR, and Lambda functions.

### Macie

Amazon Macie is a data security service that uses machine learning and pattern matching to discover and help protect your sensitive data stored in Amazon S3. Macie automatically detects sensitive data such as personally identifiable information (PII) and financial data.

### Security Hub

The AWS Security Hub provides a comprehensive view of security alerts and security status across all your AWS accounts.

The three security standards addressed:

- AWS Foundational Security Best Practices
- CIS AWS Foundations Benchmark
- PCI DSS v3.2.1

The following is the security score when only this Terraform is applied.

![SecurityHub Score](../image/security_hub_security_score.png)

For a detailed mapping of Security Hub controls, see [Security Hub Controls Compliance Matrix](./security-hub-controls.md).
For security service coverage, see [AWS Security Services Coverage](./security-coverage.md).

### SSM Automation

Configures AWS Systems Manager Automation documents for automated remediation of security findings. This enables automatic response to specific security issues detected by Config rules and Security Hub.

## Other

### AWS Support App

Creates the IAM role and policy required for AWS Support App integration. This role enables AWS Support App to access support cases and provide notifications through Slack.

### Budgets

AWS Budgets provides the ability to set up custom budgets and be alerted when costs or usage exceed (or are expected to exceed) the budgeted amount.

After configuring the Slack channel, adding the Slack app, and setting the OAuthToken, you will receive Slack notifications at the specified time (default is 18:00 JST daily). An email will also be sent if the specified cost limit is exceeded.

![Budgets](../image/slack_budgets.png)
![Budgets All](../image/slack_budgets_all.png)

### Compute Optimizer

AWS Compute Optimizer recommends optimal AWS resources for your workloads to reduce costs and improve performance by using machine learning to analyze historical utilization metrics.

### Health Events

Configures EventBridge to monitor AWS Health events and send notifications to Slack. AWS Health provides alerts about AWS service events that may affect your resources.

### IAM Group Policy

You can set the policy to assign to IAM groups. You can also make the virtual MFA setting mandatory as a base policy. You can also configure the IAM Switch Role.

![IAM Group Policy](../image/iam_group_policy.png)

### IAM Password Expired

Configures EventBridge Scheduler to check for expired or expiring IAM user passwords and send notifications to Slack.

![IAM Password Expired](../image/slack_iam_password_expired.png)

### IAM User and Group

You can create an IAM User and Group.

![IAM User](../image/iam_user.png)
![IAM Group](../image/iam_group.png)

### OIDC GitHub

Configures GitHub Actions as an IAM OIDC identity provider in AWS. This allows GitHub Actions workflows to authenticate with AWS without storing long-lived credentials, using OpenID Connect federation.

### Resource Groups

All resources created in Terraform will have the same TAG, and Resource Groups will be filtered by that TAG.

![Resource Groups](../image/resource_groups.png)

### Trusted Advisor

AWS Trusted Advisor provides guidance on how to follow AWS best practices. After configuring Slack, you will receive notifications at the specified time (default is 9:00 JST daily). Requires the Business or Enterprise support plan (default setting is false).

![Trusted Advisor](../image/slack_trusted_advisor.png)
