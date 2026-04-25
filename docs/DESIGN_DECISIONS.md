# Design Decisions

Key design decisions and patterns in this repository. Helps AI assistants understand why things are built a certain way and avoid re-investigating known decisions.

## External Data Sources for Idempotency

Several modules use `data "external"` with shell scripts to check existing AWS resources before creation. This prevents conflicts with resources created outside Terraform (console, Control Tower, etc.).

### Access Analyzer Check Script

`modules/aws/security/access_analyzer/scripts/check_organization_analyzer.sh`

- Receives `region` and `analyzer_name` via stdin JSON (Terraform external data source query)
- Queries `aws accessanalyzer list-analyzers --type ORGANIZATION --region <region>`
- Excludes the Terraform-managed analyzer name from the count to prevent false positives
- Returns `{"exists": "true/false"}` to control resource creation
- Without the name exclusion, Terraform's own analyzer would trigger the skip logic on subsequent plans

### GuardDuty Detector Check

GuardDuty uses `data "aws_guardduty_detector"` to detect existing detectors rather than external scripts, since the AWS provider supports this natively.

## KMS Key Policy — CloudTrail Pattern

CloudTrail KMS keys use the AWS-recommended policy with `Principal: {"AWS": "*"}` constrained by:

- `kms:CallerAccount` — restricts to the owning account only
- `kms:EncryptionContext:aws:cloudtrail:arn` — restricts to CloudTrail decryption only

Source: [AWS CloudTrail KMS documentation](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-kms-key-policy-for-cloudtrail.html)

This pattern triggers Access Analyzer findings (`isPublic: true`) but is safe. These findings should be archived, not remediated.

## Access Analyzer Findings — Expected External Access

The following categories of Access Analyzer findings are expected in a typical deployment and should be archived:

| Category | Reason |
| --- | --- |
| `AWSReservedSSO_*` roles | AWS SSO/Identity Center trusts external IdP by design |
| OIDC GitHub Actions roles | GitHub Actions OIDC federation — intentional |
| Cognito OpenID Connect roles | Cognito User Pool OIDC federation — intentional |
| SAML federation roles | External IdP (e.g., CloudGate UNO) federation — intentional |
| Cross-account S3 access roles | External service integration via AssumeRole — verify trust target |
| IP-restricted S3 buckets | `Principal: *` with `aws:SourceIp` condition — intentional external data receive |
| KMS keys (CloudTrail) | CloudTrail decrypt policy with `kms:CallerAccount` condition (see above) |

When investigating findings, check `~/.aws/config` or `aws organizations list-accounts` for account context.

## CloudWatch Log Group Centralization

Log retention is managed centrally via `cloudwatch_log_group` variable with per-service overrides, rather than per-Lambda configuration.

Priority order:
1. `cloudwatch_log_group.override.<service_name>.retention_in_days` (highest)
2. `cloudwatch_log_group.retention_in_days` (default)

## S3 Bucket Naming Convention

Receive buckets follow: `{env}-recieve-{account_id}` (note: "recieve" is a known typo of "receive", kept for backward compatibility).

## Terraform State Management

- Each root module has its own S3 backend with DynamoDB locking
- Backend config in `terraform.{env}.tfbackend` files
- State files are per-directory, not per-workspace (workspaces are not used)

## Security Service Deployment Model

```text
Organization Root Account
  └── Delegated Admin: Audit Account
        ├── SecurityHub Organization (config policy + finding aggregator)
        ├── GuardDuty Organization (detector + feature config)
        ├── Inspector2 Organization (member association + enabler)
        └── Access Analyzer Organization (ORGANIZATION type analyzer)

Each Member Account (via base/ terraform):
  ├── SecurityHub (member, managed by org policy)
  ├── GuardDuty (member detector, managed by org config)
  ├── Config (recorder + rules)
  ├── Default VPC hardening
  ├── EBS default encryption + snapshot public access block
  ├── EC2 IMDSv2 enforcement (account-level default)
  ├── ECR basic scan type (AWS native)
  └── IAM password policy
```

## IMDSv2 Enforcement

EC2 Instance Metadata Service v2 is enforced at the account level via `aws_ec2_instance_metadata_defaults`. This sets `http_tokens = "required"` so all new EC2 instances default to IMDSv2 without needing per-instance configuration.

- Security Hub: EC2.8
- Applied per-region (default region + us-east-1)
- Existing instances are not affected; only new launches

## ECR Basic Scan Type

ECR account setting `BASIC_SCAN_TYPE_VERSION` is set to `AWS_NATIVE` to use AWS's native scanning technology. This is an account-level setting applied once per account (not per-region).

## Default Security Group — Lambda VPC

Lambda VPC modules use `manage_default_security_group = true` with empty ingress/egress rules. This ensures the default security group created by AWS has no rules, complying with Security Hub EC2.2. Lambda functions use a dedicated security group instead.

## Scope Boundaries — What This Repository Does NOT Manage

The following are intentionally out of scope for this baseline repository:

| Item | Reason |
| --- | --- |
| WAF / Shield | Project-specific rules; managed in application repositories |
| VPC creation | Removed (`vpc/create` deleted); application repositories manage VPCs |
| Route 53 DNSSEC | Hosted Zone-specific; managed where Hosted Zones are defined |
| Macie | Cost-sensitive; enable per-project based on data classification needs |
| ECR repository settings (scan_on_push) | Per-repository; managed in application repositories |
