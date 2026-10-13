---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---

# Terraform AWS Instructions

## Scope

- Scope covers AWS-specific rules for Terraform definitions; extends the companion Terraform rules (stem `terraform`) and does not replace them.

## Standards

## Guidelines

### AWS Rules (AWS)

- AWS-01 (MUST): No default VPC, open security group (0.0.0.0/0 on sensitive ports), or public S3 bucket by default; set `block_public_access` on S3
- AWS-02 (MUST): IAM policy via jsonencode or aws_iam_policy_document, never raw JSON strings
- AWS-03 (SHOULD): Keep EventBridge patterns narrow (source/detail-type)
- AWS-04 (SHOULD): Set CloudWatch log group `retention_in_days` explicitly
- AWS-05 (SHOULD): Enable KMS encryption for SNS/S3/CloudWatch Logs/Step Functions and set `kms_key_id`
- AWS-06 (SHOULD): IAM policies follow least privilege; document the reason for each `*`
- AWS-07 (SHOULD): SNS/SQS resource policies include `SourceArn`/`SourceAccount` Condition guards
- AWS-08 (SHOULD): Enable CloudTrail and access logging for sensitive resources
- AWS-09 (SHOULD): S3 backend uses encryption, versioning, and a lock table; no embedded credentials
- AWS-10 (MUST): Read secrets from Secrets Manager or SSM Parameter Store via data sources; never hardcode
- AWS-11 (SHOULD): Select the region per resource with the `region` argument set from a variable (e.g. `region = var.region`) instead of provider aliases (`provider = aws.xxx`); requires AWS provider >= 6.0. Resources that are not region-aware keep the provider-level region

## Security Guidelines

- Keep defaults on the safe side for encryption, audit logging, and public exposure settings.
