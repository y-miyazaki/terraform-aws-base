# CIS AWS Foundations Benchmark Compliance Matrix

> Last reviewed: 2026-05-03 | CIS AWS Foundations Benchmark v5.0.0

This document maps Security Hub controls to CIS AWS Foundations Benchmark requirements and the corresponding Terraform modules in this repository.

The primary axis is **Security Hub Control ID** (stable across CIS versions). The CIS v5.0.0 requirement number is shown as a reference.
For the full version comparison table, see [Mapping of controls to CIS requirements in each version](https://docs.aws.amazon.com/securityhub/latest/userguide/cis-aws-foundations-benchmark.html).

Reference:
- [CIS AWS Foundations Benchmark - AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/cis-aws-foundations-benchmark.html)

For AWS security service coverage (GuardDuty, Inspector, Macie, etc.), see [security-coverage.md](./security-coverage.md).

## Legend

| Status | Description                                                     |
| ------ | --------------------------------------------------------------- |
| ✅      | Implemented and enabled by default                              |
| ⚠️      | Implemented but requires manual configuration or has conditions |
| ❌      | Not implemented in this repository                              |

## IAM and Account

| Security Hub Control                                                                                  | CIS v5.0 | Description                                                                | Status | Module / Configuration                 | Notes                                                               |
| ----------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------- | ------ | -------------------------------------- | ------------------------------------------------------------------- |
| [Account.1](https://docs.aws.amazon.com/securityhub/latest/userguide/account-controls.html#account-1) | 1.2      | Security contact information should be provided                            | ❌      | —                                      | Not implemented. Requires `aws_account_alternate_contact` resource. |
| [IAM.2](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-2)             | 1.14     | IAM users should not have IAM policies attached                            | ⚠️      | `base` IAM group policy                | IAM group structure provided. Enforcement is organizational.        |
| [IAM.3](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-3)             | 1.13     | IAM users' access keys should be rotated every 90 days or less             | ⚠️      | —                                      | Security Hub monitors this. No automated rotation.                  |
| [IAM.4](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-4)             | 1.3      | IAM root user access key should not exist                                  | ⚠️      | —                                      | Manual check required. Security Hub monitors this.                  |
| [IAM.5](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-5)             | 1.9      | MFA should be enabled for all IAM users that have a console password       | ⚠️      | `base` IAM group policy                | MFA enforced via IAM group policy (`is_enabled_mfa`).               |
| [IAM.6](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-6)             | 1.5      | Hardware MFA should be enabled for the root user                           | ⚠️      | —                                      | Manual setup required. Security Hub monitors this.                  |
| [IAM.9](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-9)             | 1.4      | MFA should be enabled for the root user                                    | ⚠️      | —                                      | Manual setup required. Security Hub monitors this.                  |
| [IAM.15](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-15)           | 1.7      | IAM password policy requires minimum length of 14 or greater               | ✅      | `modules/aws/security/iam`             | `aws_iam_account_password_policy`.                                  |
| [IAM.16](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-16)           | 1.8      | IAM password policy prevents password reuse                                | ✅      | `modules/aws/security/iam`             | `password_reuse_prevention` configured.                             |
| [IAM.18](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-18)           | 1.16     | A support role has been created to manage incidents with AWS Support       | ✅      | `modules/aws/security/iam`             | IAM role with `AWSSupportAccess` policy.                            |
| [IAM.22](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-22)           | 1.11     | IAM user credentials unused for 45 days should be removed                  | ⚠️      | `base` IAM password expired            | Lambda checks for expiring passwords.                               |
| [IAM.26](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-26)           | 1.18     | Expired SSL/TLS certificates managed in IAM should be removed              | ⚠️      | —                                      | Security Hub monitors this.                                         |
| [IAM.27](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-27)           | 1.21     | IAM identities should not have the AWSCloudShellFullAccess policy attached | ⚠️      | —                                      | Security Hub monitors this.                                         |
| [IAM.28](https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-28)           | 1.19     | IAM Access Analyzer external access analyzer should be enabled             | ✅      | `modules/aws/security/access_analyzer` | Organization-level via `management/audit`.                          |

## Storage

| Security Hub Control                                                                        | CIS v5.0 | Description                                                                 | Status | Module / Configuration     | Notes                                                                                                                             |
| ------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------- | ------ | -------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [S3.1](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-1)      | 2.1.4    | S3 general purpose buckets should have block public access settings enabled | ✅      | S3 account-level module    | Account-level S3 public access block. Same infrastructure as S3.8.                                                                |
| [S3.5](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-5)      | 2.1.1    | S3 general purpose buckets should require requests to use SSL               | ✅      | S3 module                  | S3 bucket policy enforces SSL.                                                                                                    |
| [S3.8](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-8)      | 2.1.4    | S3 general purpose buckets should block public access                       | ✅      | S3 account-level module    | Account-level S3 public access block. Shares CIS 2.1.4 mapping with S3.1; both satisfied by the same account-level block setting. |
| [S3.20](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-20)    | 2.1.2    | S3 general purpose buckets should have MFA delete enabled                   | ⚠️      | —                          | MFA Delete requires root account to enable.                                                                                       |
| [S3.22](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-22)    | 3.3      | S3 general purpose buckets should log object-level write events             | ⚠️      | —                          | Security Hub monitors this. Not configured by default.                                                                            |
| [S3.23](https://docs.aws.amazon.com/securityhub/latest/userguide/s3-controls.html#s3-23)    | 3.3      | S3 general purpose buckets should log object-level read events              | ⚠️      | —                          | Security Hub monitors this. Not configured by default.                                                                            |
| [EC2.7](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-7)   | 2.2.1    | EBS default encryption should be enabled                                    | ✅      | `modules/aws/security/ebs` | `aws_ebs_encryption_by_default`.                                                                                                  |
| [EFS.1](https://docs.aws.amazon.com/securityhub/latest/userguide/efs-controls.html#efs-1)   | 2.4.1    | EFS should be configured to encrypt file data at-rest using AWS KMS         | ⚠️      | —                          | Security Hub monitors this.                                                                                                       |
| [EFS.8](https://docs.aws.amazon.com/securityhub/latest/userguide/efs-controls.html#efs-8)   | 2.4.1    | EFS file systems should be encrypted at rest                                | ⚠️      | —                          | Security Hub monitors this. v5.0 only.                                                                                            |
| [RDS.2](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html#rds-2)   | 2.2.3    | RDS DB Instances should prohibit public access                              | ⚠️      | —                          | Security Hub monitors this.                                                                                                       |
| [RDS.3](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html#rds-3)   | 2.2.1    | RDS DB instances should have encryption at-rest enabled                     | ⚠️      | Config rules               | `RDS_STORAGE_ENCRYPTED` rule available.                                                                                           |
| [RDS.5](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html#rds-5)   | 2.2.4    | RDS DB instances should be configured with multiple Availability Zones      | ⚠️      | —                          | Security Hub monitors this. v5.0 only.                                                                                            |
| [RDS.13](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html#rds-13) | 2.2.2    | RDS automatic minor version upgrades should be enabled                      | ✅      | Config rules               | `RDS_AUTOMATIC_MINOR_VERSION_UPGRADE_ENABLED`.                                                                                    |
| [RDS.15](https://docs.aws.amazon.com/securityhub/latest/userguide/rds-controls.html#rds-15) | 2.2.4    | RDS DB clusters should be configured for multiple Availability Zones        | ⚠️      | —                          | Security Hub monitors this. v5.0 only.                                                                                            |

## Logging

| Security Hub Control                                                                                           | CIS v5.0 | Description                                                       | Status | Module / Configuration                          | Notes                                                                                                 |
| -------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------- | ------ | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [CloudTrail.1](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html#cloudtrail-1) | 3.1      | CloudTrail should be enabled with at least one multi-Region trail | ✅      | `modules/aws/security/cloudtrail/cloudtrail` | `is_multi_region_trail = true`.                                                                       |
| [CloudTrail.2](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html#cloudtrail-2) | 3.5      | CloudTrail should have encryption at-rest enabled                 | ✅      | `modules/aws/security/cloudtrail/cloudtrail` | `kms_key_id` configurable.                                                                            |
| [CloudTrail.4](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html#cloudtrail-4) | 3.2      | CloudTrail log file validation should be enabled                  | ✅      | `modules/aws/security/cloudtrail/cloudtrail` | `enable_log_file_validation = true` (default).                                                        |
| [CloudTrail.7](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudtrail-controls.html#cloudtrail-7) | 3.4      | S3 bucket access logging is enabled on the CloudTrail S3 bucket   | ⚠️      | S3 module                                       | Configurable via S3 bucket settings.                                                                  |
| [Config.1](https://docs.aws.amazon.com/securityhub/latest/userguide/config-controls.html#config-1)             | 3.9      | AWS Config should be enabled                                      | ✅      | `modules/aws/security/config/create`         | Config recorder in primary region + us-east-1.                                                        |
| [EC2.6](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-6)                      | 3.7      | VPC flow logging should be enabled in all VPCs                    | ⚠️      | `modules/aws/security/default_vpc`              | `is_enabled_flow_logs = true` for default VPC only. User-created VPCs require separate configuration. |
| [KMS.4](https://docs.aws.amazon.com/securityhub/latest/userguide/kms-controls.html#kms-4)                      | 3.6      | AWS KMS key rotation should be enabled                            | ⚠️      | —                                               | Security Hub monitors this. KMS key rotation not managed in this repo.                                |

## Networking

| Security Hub Control                                                                        | CIS v5.0 | Description                                                                       | Status | Module / Configuration              | Notes                                   |
| ------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------- | ------ | ----------------------------------- | --------------------------------------- |
| [EC2.2](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-2)   | 5.3      | VPC default security groups should not allow inbound or outbound traffic          | ✅      | `modules/aws/security/default_vpc`  | Default SG rules removed.               |
| [EC2.8](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-8)   | 5.7      | EC2 instances should use IMDSv2                                                   | ✅      | `modules/aws/security/ec2_metadata` | Account-level `http_tokens = required`. |
| [EC2.21](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-21) | 5.2      | Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or 3389           | ⚠️      | —                                   | Security Hub monitors this.             |
| [EC2.53](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-53) | 5.3      | EC2 security groups should not allow ingress from 0.0.0.0/0 to remote admin ports | ⚠️      | —                                   | Security Hub monitors this.             |
| [EC2.54](https://docs.aws.amazon.com/securityhub/latest/userguide/ec2-controls.html#ec2-54) | 5.4      | EC2 security groups should not allow ingress from ::/0 to remote admin ports      | ⚠️      | —                                   | Security Hub monitors this.             |

## Monitoring (CloudWatch Log Metric Filters)

These controls are from CIS v1.2/v1.4 Section 4. They were removed from CIS v3.0+ automated checks but remain as best-practice recommendations.
Implemented in `modules/aws/security/cloudtrail/cloudtrail/main.tf`.

| Security Hub Control                                                                                             | Description                                                      | Status | Metric Filter | Notes                                            |
| ---------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------ | ------------- | ------------------------------------------------ |
| [CloudWatch.1](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-1)   | Log metric filter and alarm for usage of 'root' user             | ✅      | `cis_3_3`     |                                                  |
| [CloudWatch.2](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-2)   | Log metric filter and alarm for unauthorized API calls           | ✅      | `cis_3_1`     |                                                  |
| [CloudWatch.3](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-3)   | Log metric filter and alarm for Console sign-in without MFA      | ⚠️      | `cis_3_2`     | Disabled (`count = 0`). Enable if not using SSO. |
| [CloudWatch.4](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-4)   | Log metric filter and alarm for IAM policy changes               | ✅      | `cis_3_4`     |                                                  |
| [CloudWatch.5](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-5)   | Log metric filter and alarm for CloudTrail configuration changes | ✅      | `cis_3_5`     |                                                  |
| [CloudWatch.6](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-6)   | Log metric filter and alarm for Console authentication failures  | ✅      | `cis_3_6`     |                                                  |
| [CloudWatch.7](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-7)   | Log metric filter and alarm for disabling/deletion of CMKs       | ✅      | `cis_3_7`     |                                                  |
| [CloudWatch.8](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-8)   | Log metric filter and alarm for S3 bucket policy changes         | ✅      | `cis_3_8`     |                                                  |
| [CloudWatch.9](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-9)   | Log metric filter and alarm for AWS Config configuration changes | ✅      | `cis_3_9`     |                                                  |
| [CloudWatch.10](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-10) | Log metric filter and alarm for security group changes           | ✅      | `cis_3_10`    |                                                  |
| [CloudWatch.11](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-11) | Log metric filter and alarm for NACL changes                     | ✅      | `cis_3_11`    |                                                  |
| [CloudWatch.12](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-12) | Log metric filter and alarm for network gateway changes          | ✅      | `cis_3_12`    |                                                  |
| [CloudWatch.13](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-13) | Log metric filter and alarm for route table changes              | ✅      | `cis_3_13`    |                                                  |
| [CloudWatch.14](https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-14) | Log metric filter and alarm for VPC changes                      | ✅      | `cis_3_14`    |                                                  |

## Other CIS Controls (Manual / Not Automated by Security Hub)

| CIS v5.0 | Description                                                             | Status | Notes                                                             |
| -------- | ----------------------------------------------------------------------- | ------ | ----------------------------------------------------------------- |
| 1.1      | Maintain current contact details                                        | ⚠️      | Manual.                                                           |
| 1.6      | Eliminate use of the 'root' user for administrative tasks               | ⚠️      | Root usage alarm via CloudWatch.1 metric filter.                  |
| 1.10     | Do not setup access keys during initial user setup                      | ⚠️      | Organizational process.                                           |
| 1.15     | Ensure IAM Users receive permissions only through groups                | ⚠️      | IAM group structure provided.                                     |
| 1.17     | Ensure IAM policies that allow full "\*:\*" privileges are not attached | ⚠️      | Security Hub monitors via IAM.1 (not CIS-mapped).                 |
| 1.20     | Ensure IAM users are managed centrally via identity federation          | ⚠️      | OIDC for GitHub Actions provided.                                 |
| 2.1.3    | Ensure all data in S3 has been discovered and classified                | ⚠️      | Macie enabled for S3 sensitive data discovery.                    |
| 3.8      | Ensure that Object-level logging for S3 is enabled                      | ⚠️      | Covered by S3.22/S3.23.                                           |
| 5.1      | Ensure routing tables for VPC peering are "least access"                | ⚠️      | Manual review required.                                           |
| 5.5      | Ensure that VPC Endpoints are utilized for S3 access                    | ⚠️      | `is_enabled_vpc_end_point` available. Disabled by default (cost). |
| 5.6      | Ensure that EC2 Metadata Service only allows IMDSv2                     | ✅      | Covered by EC2.8.                                                 |

## Coverage Summary

| Section                 | ✅      | ⚠️      | ❌     |
| ----------------------- | ------ | ------ | ----- |
| IAM and Account         | 4      | 9      | 1     |
| Storage                 | 5      | 9      | 0     |
| Logging                 | 4      | 3      | 0     |
| Networking              | 2      | 3      | 0     |
| Monitoring (CloudWatch) | 13     | 1      | 0     |
| **Total**               | **28** | **25** | **1** |

> **Note**: Many ⚠️ controls are monitored by Security Hub and generate findings automatically. "Partial" means this repository provides monitoring infrastructure but requires manual or organizational action for full compliance.
>
> The "Other CIS Controls (Manual / Not Automated by Security Hub)" section is excluded from this summary because those items are not Security Hub controls and cannot be automatically assessed.

## Security Hub Standards

When `security_securityhub` is enabled, the following standards are subscribed:

| Standard                      | Version | Reference                                                                                                                    |
| ----------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| CIS AWS Foundations Benchmark | v5.0.0  | [CIS AWS Foundations Benchmark](https://docs.aws.amazon.com/securityhub/latest/userguide/cis-aws-foundations-benchmark.html) |
| PCI DSS                       | v4.0.1  | [PCI DSS v4.0.1](https://docs.aws.amazon.com/securityhub/latest/userguide/pcidss-v4-0-1-controls.html)                       |
