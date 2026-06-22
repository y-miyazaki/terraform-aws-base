# Security Hub Controls Compliance Matrix

> Last reviewed: 2026-06-22 | Based on AWS Security Hub consolidated control IDs

This document maps Security Hub controls to this repository's Terraform implementation status. The primary axis is **Security Hub Control ID**. CIS AWS Foundations Benchmark v5.0.0 requirement numbers are shown as a reference where applicable.

For AWS security service coverage (GuardDuty, Inspector, Macie, etc.), see [AWS Security Services Coverage](./security-coverage.md).

## Legend

| Status | Description |
| --- | --- |
| ✅ | Implemented and enabled by default |
| ⚠️ | Implemented but requires manual configuration or has conditions |
| ❌ | Not implemented in this repository |
| — | Not this repository's scope (Workload or Manual) |

## Scope

| Scope | Description | Decision Criteria |
| --- | --- | --- |
| Base | This repository's responsibility | **Account-level or organization-level settings** that apply globally without per-resource configuration (e.g., password policy, EBS default encryption, IMDSv2 default, CloudTrail, Config recorder, Security Hub enablement, CIS metric filters) |
| Workload | Workload repository's responsibility | **Per-resource configuration** that depends on individual resource creation or per-resource settings (e.g., RDS encryption, S3 bucket logging, security group rules, tagging, IAM policy content) |
| Manual | Requires manual or organizational action | **Cannot be automated via Terraform** (e.g., root MFA setup, access key rotation, organizational processes) |

Decision flow:

1. Can it be automated via Terraform? → No → `Manual`
2. Is it an account-level or organization-level setting (applies once, globally)? → Yes → `Base`
3. Does it require per-resource configuration at resource creation time? → Yes → `Workload`

> Status is only evaluated for `Base` scope. Workload and Manual items show `—` in the Status column.

## Account Controls

Reference: [Security Hub controls for AWS accounts](https://docs.aws.amazon.com/securityhub/latest/userguide/account-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Account.1 | 1.2 | Security contact information should be provided | Base | ❌ | — | **TODO**: Add `aws_account_alternate_contact` resource. |
| Account.2 | — | AWS account should be part of an AWS Organizations organization | Base | ✅ | `management/root` | Organization structure managed. |

## CloudTrail Controls

Reference: [Security Hub controls for AWS CloudTrail](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CloudTrail.1 | 3.1 | CloudTrail should be enabled with at least one multi-Region trail | Base | ✅ | `modules/aws/security/cloudtrail/cloudtrail` | `is_multi_region_trail = true`. |
| CloudTrail.2 | 3.5 | CloudTrail should have encryption at-rest enabled | Base | ✅ | `modules/aws/security/cloudtrail/cloudtrail` | `kms_key_id` configurable. |
| CloudTrail.3 | — | CloudTrail should be enabled | Base | ✅ | `modules/aws/security/cloudtrail/cloudtrail` | Covered by CloudTrail.1 configuration. |
| CloudTrail.4 | 3.2 | CloudTrail log file validation should be enabled | Base | ✅ | `modules/aws/security/cloudtrail/cloudtrail` | `enable_log_file_validation = true` (default). |
| CloudTrail.5 | — | CloudTrail trails should be integrated with Amazon CloudWatch Logs | Base | ✅ | `modules/aws/security/cloudtrail/cloudtrail` | CloudWatch Logs group configured. |
| CloudTrail.6 | — | S3 bucket used to store CloudTrail logs should not be publicly accessible | Base | ✅ | S3 account-level module | Account-level public access block. |
| CloudTrail.7 | 3.4 | S3 bucket access logging is enabled on the CloudTrail S3 bucket | Workload | — | — | S3 bucket settings. Per-bucket configuration. |
| CloudTrail.9 | — | CloudTrail trails should be tagged | Workload | — | — | Tagging control. |

## CloudWatch Controls

Reference: [Security Hub controls for Amazon CloudWatch](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html)

These controls are from CIS v1.2/v1.4 Section 4. They were removed from CIS v3.0+ automated checks but remain as best-practice recommendations. Implemented in `modules/aws/security/cloudtrail/cloudtrail/main.tf`.

| Control ID | Description | Scope | Status | Metric Filter | Notes |
| --- | --- | --- | --- | --- | --- |
| CloudWatch.1 | Log metric filter and alarm for usage of 'root' user | Base | ✅ | `cis_3_3` | |
| CloudWatch.2 | Log metric filter and alarm for unauthorized API calls | Base | ✅ | `cis_3_1` | |
| CloudWatch.3 | Log metric filter and alarm for Console sign-in without MFA | Base | ⚠️ | `cis_3_2` | Disabled (`count = 0`). Enable if not using SSO. |
| CloudWatch.4 | Log metric filter and alarm for IAM policy changes | Base | ✅ | `cis_3_4` | |
| CloudWatch.5 | Log metric filter and alarm for CloudTrail configuration changes | Base | ✅ | `cis_3_5` | |
| CloudWatch.6 | Log metric filter and alarm for Console authentication failures | Base | ✅ | `cis_3_6` | |
| CloudWatch.7 | Log metric filter and alarm for disabling/deletion of CMKs | Base | ✅ | `cis_3_7` | |
| CloudWatch.8 | Log metric filter and alarm for S3 bucket policy changes | Base | ✅ | `cis_3_8` | |
| CloudWatch.9 | Log metric filter and alarm for AWS Config configuration changes | Base | ✅ | `cis_3_9` | |
| CloudWatch.10 | Log metric filter and alarm for security group changes | Base | ✅ | `cis_3_10` | |
| CloudWatch.11 | Log metric filter and alarm for NACL changes | Base | ✅ | `cis_3_11` | |
| CloudWatch.12 | Log metric filter and alarm for network gateway changes | Base | ✅ | `cis_3_12` | |
| CloudWatch.13 | Log metric filter and alarm for route table changes | Base | ✅ | `cis_3_13` | |
| CloudWatch.14 | Log metric filter and alarm for VPC changes | Base | ✅ | `cis_3_14` | |
| CloudWatch.15 | CloudWatch alarms should have specified actions configured | Workload | — | — | Per-alarm configuration. |
| CloudWatch.16 | CloudWatch log groups should be retained for at least 1 year | Workload | — | — | Per-log-group configuration. |
| CloudWatch.17 | CloudWatch alarm actions should be activated | Workload | — | — | Per-alarm configuration. |

## Config Controls

Reference: [Security Hub controls for AWS Config](https://docs.aws.amazon.com/securityhub/latest/userguide/config-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| Config.1 | 3.9 | AWS Config should be enabled and use the service-linked role for resource recording | Base | ✅ | `modules/aws/security/config/create` | Config recorder in primary region + us-east-1. |

## EC2 Controls

Reference: [Security Hub controls for Amazon EC2](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html)

Only controls relevant to this repository's scope (default VPC, EBS, security groups, metadata) are listed. For the full list of EC2 controls, see the reference link above.

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EC2.1 | — | Amazon EBS snapshots should not be publicly restorable | Workload | — | — | Per-snapshot configuration. |
| EC2.2 | 5.3 | VPC default security groups should not allow inbound or outbound traffic | Base | ✅ | `modules/aws/security/default_vpc` | Default SG rules removed. |
| EC2.3 | — | Attached Amazon EBS volumes should be encrypted at-rest | Base | ✅ | `modules/aws/security/ebs` | EBS default encryption enabled. |
| EC2.4 | — | Stopped EC2 instances should be removed after a specified time period | Workload | — | — | Per-instance lifecycle. |
| EC2.6 | 3.7 | VPC flow logging should be enabled in all VPCs | Base | ⚠️ | `modules/aws/security/default_vpc` | Default VPC only. User-created VPCs are Workload responsibility. |
| EC2.7 | 2.2.1 | EBS default encryption should be enabled | Base | ✅ | `modules/aws/security/ebs` | `aws_ebs_encryption_by_default`. |
| EC2.8 | 5.7 | EC2 instances should use IMDSv2 | Base | ✅ | `modules/aws/security/ec2_metadata` | Account-level `http_tokens = required`. |
| EC2.9 | — | EC2 instances should not have a public IPv4 address | Workload | — | — | Per-instance configuration. |
| EC2.10 | — | Amazon EC2 should be configured to use VPC endpoints | Workload | — | — | Per-VPC configuration. |
| EC2.13 | — | Security groups should not allow ingress from 0.0.0.0/0 to port 22 | Workload | — | — | Per-SG configuration. |
| EC2.14 | — | Security groups should not allow ingress from 0.0.0.0/0 to port 3389 | Workload | — | — | Per-SG configuration. |
| EC2.15 | — | EC2 subnets should not automatically assign public IP addresses | Workload | — | — | Per-subnet configuration. |
| EC2.16 | — | Unused Network Access Control Lists should be removed | Workload | — | — | Per-VPC lifecycle. |
| EC2.17 | — | EC2 instances should not use multiple ENIs | Workload | — | — | Per-instance configuration. |
| EC2.18 | — | Security groups should only allow unrestricted incoming traffic for authorized ports | Workload | — | — | Per-SG configuration. |
| EC2.19 | — | Security groups should not allow unrestricted access to ports with high risk | Workload | — | — | Per-SG configuration. |
| EC2.21 | 5.2 | Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or 3389 | Workload | — | — | Per-NACL configuration. |
| EC2.23 | — | EC2 Transit Gateways should not automatically accept VPC attachment requests | Workload | — | — | Per-TGW configuration. |
| EC2.24 | — | EC2 paravirtual instance types should not be used | Workload | — | — | Per-instance configuration. |
| EC2.25 | — | EC2 launch templates should not assign public IPs to network interfaces | Workload | — | — | Per-template configuration. |
| EC2.28 | — | EBS volumes should be covered by a backup plan | Workload | — | — | Per-volume configuration. |
| EC2.51 | — | EC2 Client VPN endpoints should have client connection logging enabled | Workload | — | — | Per-VPN configuration. |
| EC2.53 | 5.3 | EC2 security groups should not allow ingress from 0.0.0.0/0 to remote admin ports | Workload | — | — | Per-SG configuration. |
| EC2.54 | 5.4 | EC2 security groups should not allow ingress from ::/0 to remote admin ports | Workload | — | — | Per-SG configuration. |

## EFS Controls

Reference: [Security Hub controls for Amazon EFS](https://docs.aws.amazon.com/securityhub/latest/userguide/efs-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| EFS.1 | 2.4.1 | EFS should be configured to encrypt file data at-rest using AWS KMS | Workload | — | — | Per-filesystem configuration. |
| EFS.2 | — | Amazon EFS volumes should be in backup plans | Workload | — | — | Per-filesystem configuration. |
| EFS.3 | — | EFS access points should enforce a root directory | Workload | — | — | Per-access-point configuration. |
| EFS.4 | — | EFS access points should enforce a user identity | Workload | — | — | Per-access-point configuration. |
| EFS.6 | — | EFS mount targets should not be associated with a public subnet | Workload | — | — | Per-mount-target configuration. |
| EFS.7 | — | EFS file systems should have automatic backups enabled | Workload | — | — | Per-filesystem configuration. |
| EFS.8 | 2.4.1 | EFS file systems should be encrypted at rest | Workload | — | — | Per-filesystem configuration. |

## IAM Controls

Reference: [Security Hub controls for IAM](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| IAM.1 | 1.17 | IAM policies should not allow full "*" administrative privileges | Workload | — | — | Per-policy configuration. |
| IAM.2 | 1.14 | IAM users should not have IAM policies attached | Base | ⚠️ | `base` IAM group policy | IAM group structure provided. Enforcement is organizational. |
| IAM.3 | 1.13 | IAM users' access keys should be rotated every 90 days or less | Manual | — | — | No automated rotation. |
| IAM.4 | 1.3 | IAM root user access key should not exist | Manual | — | — | Manual check required. |
| IAM.5 | 1.9 | MFA should be enabled for all IAM users that have a console password | Base | ⚠️ | `base` IAM group policy | MFA enforced via IAM group policy (`is_enabled_mfa`). |
| IAM.6 | 1.5 | Hardware MFA should be enabled for the root user | Manual | — | — | Manual setup required. |
| IAM.7 | — | Password policy for IAM users should have strong configurations | Base | ✅ | `modules/aws/security/iam` | `aws_iam_account_password_policy`. |
| IAM.8 | — | Unused IAM user credentials should be removed | Base | ⚠️ | `base` IAM password expired | Lambda checks for expiring passwords. |
| IAM.9 | 1.4 | MFA should be enabled for the root user | Manual | — | — | Manual setup required. |
| IAM.10 | — | Password policy for IAM users should have strong configurations | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.11 | — | Ensure IAM password policy requires at least one uppercase letter | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.12 | — | Ensure IAM password policy requires at least one lowercase letter | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.13 | — | Ensure IAM password policy requires at least one symbol | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.14 | — | Ensure IAM password policy requires at least one number | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.15 | 1.7 | IAM password policy requires minimum length of 14 or greater | Base | ✅ | `modules/aws/security/iam` | `aws_iam_account_password_policy`. |
| IAM.16 | 1.8 | IAM password policy prevents password reuse | Base | ✅ | `modules/aws/security/iam` | `password_reuse_prevention` configured. |
| IAM.17 | — | Ensure IAM password policy expires passwords within 90 days or less | Base | ✅ | `modules/aws/security/iam` | Covered by password policy resource. |
| IAM.18 | 1.16 | A support role has been created to manage incidents with AWS Support | Base | ✅ | `modules/aws/security/iam` | IAM role with `AWSSupportAccess` policy. |
| IAM.19 | — | MFA should be enabled for all IAM users | Base | ⚠️ | `base` IAM group policy | MFA enforced via group policy. |
| IAM.20 | — | Avoid the use of the root user | Manual | — | — | Organizational process. Detection via CloudWatch.1. |
| IAM.21 | — | IAM customer managed policies should not allow wildcard actions for services | Workload | — | — | Per-policy configuration. |
| IAM.22 | 1.11 | IAM user credentials unused for 45 days should be removed | Base | ⚠️ | `base` IAM password expired | Lambda checks for expiring passwords. |
| IAM.23 | — | IAM Access Analyzer analyzers should be tagged | Workload | — | — | Tagging control. |
| IAM.24 | — | IAM roles should be tagged | Workload | — | — | Tagging control. |
| IAM.25 | — | IAM users should be tagged | Workload | — | — | Tagging control. |
| IAM.26 | 1.18 | Expired SSL/TLS certificates managed in IAM should be removed | Manual | — | — | Manual check required. |
| IAM.27 | 1.21 | IAM identities should not have the AWSCloudShellFullAccess policy attached | Workload | — | — | Per-identity configuration. |
| IAM.28 | 1.19 | IAM Access Analyzer external access analyzer should be enabled | Base | ✅ | `modules/aws/security/access_analyzer` | Organization-level via `management/audit`. |

## KMS Controls

Reference: [Security Hub controls for AWS KMS](https://docs.aws.amazon.com/securityhub/latest/userguide/kms-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| KMS.1 | — | IAM customer managed policies should not allow decryption actions on all KMS keys | Workload | — | — | Per-policy configuration. |
| KMS.2 | — | IAM principals should not have IAM inline policies that allow decryption actions on all KMS keys | Workload | — | — | Per-policy configuration. |
| KMS.3 | — | AWS KMS keys should not be deleted unintentionally | Workload | — | — | Per-key configuration. |
| KMS.4 | 3.6 | AWS KMS key rotation should be enabled | Workload | — | — | Per-key configuration. |

## RDS Controls

Reference: [Security Hub controls for Amazon RDS](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| RDS.1 | — | RDS snapshot should be private | Workload | — | — | Per-snapshot configuration. |
| RDS.2 | 2.2.3 | RDS DB Instances should prohibit public access | Workload | — | — | Per-instance configuration. |
| RDS.3 | 2.2.1 | RDS DB instances should have encryption at-rest enabled | Workload | — | — | Per-instance configuration. |
| RDS.4 | — | RDS cluster snapshots and database snapshots should be encrypted at rest | Workload | — | — | Per-snapshot configuration. |
| RDS.5 | 2.2.4 | RDS DB instances should be configured with multiple Availability Zones | Workload | — | — | Per-instance configuration. |
| RDS.6 | — | Enhanced monitoring should be configured for RDS DB instances | Workload | — | — | Per-instance configuration. |
| RDS.7 | — | RDS clusters should have deletion protection enabled | Workload | — | — | Per-cluster configuration. |
| RDS.8 | — | RDS DB instances should have deletion protection enabled | Workload | — | — | Per-instance configuration. |
| RDS.9 | — | RDS DB instances should publish logs to CloudWatch Logs | Workload | — | — | Per-instance configuration. |
| RDS.10 | — | IAM authentication should be configured for RDS instances | Workload | — | — | Per-instance configuration. |
| RDS.11 | — | RDS instances should have automatic backups enabled | Workload | — | — | Per-instance configuration. |
| RDS.12 | — | IAM authentication should be configured for RDS clusters | Workload | — | — | Per-cluster configuration. |
| RDS.13 | 2.2.2 | RDS automatic minor version upgrades should be enabled | Base | ✅ | Config rules | `RDS_AUTOMATIC_MINOR_VERSION_UPGRADE_ENABLED`. |
| RDS.14 | — | Amazon Aurora clusters should have backtracking enabled | Workload | — | — | Per-cluster configuration. |
| RDS.15 | 2.2.4 | RDS DB clusters should be configured for multiple Availability Zones | Workload | — | — | Per-cluster configuration. |
| RDS.16 | — | RDS DB clusters should be configured to copy tags to snapshots | Workload | — | — | Per-cluster configuration. |
| RDS.17 | — | RDS DB instances should be configured to copy tags to snapshots | Workload | — | — | Per-instance configuration. |
| RDS.18 | — | RDS instances should be deployed in a VPC | Workload | — | — | Per-instance configuration. |
| RDS.19 | — | RDS event notifications subscriptions should be configured for critical cluster events | Workload | — | — | Per-subscription configuration. |
| RDS.20 | — | RDS event notifications subscriptions should be configured for critical database instance events | Workload | — | — | Per-subscription configuration. |
| RDS.21 | — | RDS event notifications subscriptions should be configured for critical database parameter group events | Workload | — | — | Per-subscription configuration. |
| RDS.22 | — | RDS event notifications subscriptions should be configured for critical database security group events | Workload | — | — | Per-subscription configuration. |
| RDS.23 | — | RDS instances should not use a database engine default port | Workload | — | — | Per-instance configuration. |
| RDS.24 | — | RDS Database clusters should use a custom administrator username | Workload | — | — | Per-cluster configuration. |
| RDS.25 | — | RDS database instances should use a custom administrator username | Workload | — | — | Per-instance configuration. |
| RDS.26 | — | RDS DB instances should be covered by a backup plan | Workload | — | — | Per-instance configuration. |
| RDS.27 | — | RDS DB clusters should be encrypted at rest | Workload | — | — | Per-cluster configuration. |
| RDS.34 | — | Aurora MySQL DB clusters should publish audit logs to CloudWatch Logs | Workload | — | — | Per-cluster configuration. |
| RDS.35 | — | RDS DB clusters should have automatic minor version upgrade enabled | Workload | — | — | Per-cluster configuration. |

## S3 Controls

Reference: [Security Hub controls for Amazon S3](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html)

| Control ID | CIS v5.0 | Description | Scope | Status | Module / Configuration | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| S3.1 | 2.1.4 | S3 general purpose buckets should have block public access settings enabled | Base | ✅ | S3 account-level module | Account-level S3 public access block. |
| S3.2 | — | S3 general purpose buckets should block public read access | Base | ✅ | S3 account-level module | Covered by account-level block. |
| S3.3 | — | S3 general purpose buckets should block public write access | Base | ✅ | S3 account-level module | Covered by account-level block. |
| S3.5 | 2.1.1 | S3 general purpose buckets should require requests to use SSL | Workload | — | — | Per-bucket policy. |
| S3.6 | — | S3 general purpose bucket policies should restrict access to other AWS accounts | Workload | — | — | Per-bucket policy. |
| S3.7 | — | S3 general purpose buckets should use cross-Region replication | Workload | — | — | Per-bucket configuration. |
| S3.8 | 2.1.4 | S3 general purpose buckets should block public access | Base | ✅ | S3 account-level module | Account-level S3 public access block. Same as S3.1. |
| S3.9 | — | S3 general purpose buckets should have server access logging enabled | Workload | — | — | Per-bucket configuration. |
| S3.10 | — | S3 buckets with versioning enabled should have Lifecycle configurations | Workload | — | — | Per-bucket configuration. |
| S3.11 | — | S3 general purpose buckets should have event notifications enabled | Workload | — | — | Per-bucket configuration. |
| S3.12 | — | ACLs should not be used to manage user access to S3 general purpose buckets | Workload | — | — | Per-bucket configuration. |
| S3.13 | — | S3 general purpose buckets should have Lifecycle configurations | Workload | — | — | Per-bucket configuration. |
| S3.14 | — | S3 general purpose buckets should have versioning enabled | Workload | — | — | Per-bucket configuration. |
| S3.15 | — | S3 general purpose buckets should have Object Lock enabled | Workload | — | — | Per-bucket configuration. |
| S3.17 | — | S3 general purpose buckets should be encrypted at rest with AWS KMS keys | Workload | — | — | Per-bucket configuration. SSE-S3 is default. |
| S3.19 | — | S3 access points should have block public access settings enabled | Workload | — | — | Per-access-point configuration. |
| S3.20 | 2.1.2 | S3 general purpose buckets should have MFA delete enabled | Manual | — | — | MFA Delete requires root account to enable. |
| S3.22 | 3.3 | S3 general purpose buckets should log object-level write events | Workload | — | — | CloudTrail data event. Per-bucket decision (cost). |
| S3.23 | 3.3 | S3 general purpose buckets should log object-level read events | Workload | — | — | CloudTrail data event. Per-bucket decision (cost). |
| S3.24 | — | S3 Multi-Region Access Points should have block public access settings enabled | Workload | — | — | Per-access-point configuration. |
| S3.25 | — | S3 directory buckets should have lifecycle configurations | Workload | — | — | Per-bucket configuration. |

## Other CIS Controls (Manual / Not Automated by Security Hub)

| CIS v5.0 | Description | Scope | Status | Notes |
| --- | --- | --- | --- | --- |
| 1.1 | Maintain current contact details | Manual | — | Manual. |
| 1.6 | Eliminate use of the 'root' user for administrative tasks | Manual | — | Detection via CloudWatch.1 metric filter. |
| 1.10 | Do not setup access keys during initial user setup | Manual | — | Organizational process. |
| 1.15 | Ensure IAM Users receive permissions only through groups | Base | ⚠️ | IAM group structure provided. |
| 1.20 | Ensure IAM users are managed centrally via identity federation | Base | ⚠️ | OIDC for GitHub Actions provided. |
| 2.1.3 | Ensure all data in S3 has been discovered and classified | Base | ⚠️ | Macie enabled for S3 sensitive data discovery. |
| 3.8 | Ensure that Object-level logging for S3 is enabled | Workload | — | Covered by S3.22/S3.23. |
| 5.1 | Ensure routing tables for VPC peering are "least access" | Workload | — | Per-VPC configuration. |
| 5.5 | Ensure that VPC Endpoints are utilized for S3 access | Workload | — | Per-VPC configuration. Cost trade-off. |
| 5.6 | Ensure that EC2 Metadata Service only allows IMDSv2 | Base | ✅ | Covered by EC2.8. |

## Coverage Summary (Base Scope Only)

| Section | ✅ | ⚠️ | ❌ |
| --- | --- | --- | --- |
| Account | 1 | 0 | 1 |
| CloudTrail | 6 | 0 | 0 |
| CloudWatch | 13 | 1 | 0 |
| Config | 1 | 0 | 0 |
| EC2 | 4 | 1 | 0 |
| IAM | 12 | 4 | 0 |
| RDS | 1 | 0 | 0 |
| S3 | 4 | 0 | 0 |
| Other CIS | 1 | 3 | 0 |
| **Total** | **43** | **9** | **1** |

> **Note**: This summary counts only Base scope controls. Workload and Manual items are excluded because they are not this repository's responsibility.

## Security Hub Standards

When `security_securityhub` is enabled, the following standards are subscribed:

| Standard | Version | Reference |
| --- | --- | --- |
| CIS AWS Foundations Benchmark | v5.0.0 | [CIS AWS Foundations Benchmark](https://docs.aws.amazon.com/securityhub/latest/userguide/cis-aws-foundations-benchmark.html) |
| PCI DSS | v4.0.1 | [PCI DSS v4.0.1](https://docs.aws.amazon.com/securityhub/latest/userguide/pcidss-v4-0-1-controls.html) |
