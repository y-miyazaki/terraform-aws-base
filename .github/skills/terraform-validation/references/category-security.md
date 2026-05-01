## Terraform Validation - Security Remediation Guide

Use this guide when `trivy config` reports security findings.

## Severity Handling Policy

- **CRITICAL**: Must be fixed before merge.
- **HIGH**: Must be fixed before production deployment.
- **MEDIUM**: Fix in the current or next planned change window.
- **LOW**: Fix when practical and track in backlog if deferred.

## Common trivy Findings and Fixes

### Public S3 Bucket Access

**Typical finding**:
- Bucket policy allows public principals (`"Principal": "*"`)
- Public access block is not fully enabled

**Fix**:

```hcl
resource "aws_s3_bucket_public_access_block" "this" {
	bucket                  = aws_s3_bucket.this.id
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}
```

### Missing Encryption at Rest

**Typical finding**:
- S3/EBS/RDS/log targets missing encryption settings

**Fix**:

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
	bucket = aws_s3_bucket.this.id

	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm     = "aws:kms"
			kms_master_key_id = aws_kms_key.this.arn
		}
	}
}
```

### Overly Permissive IAM Policies

**Typical finding**:
- Wildcards in `Action` or `Resource` without strict conditions

**Fix**:

```hcl
data "aws_iam_policy_document" "least_privilege" {
	statement {
		sid     = "ReadSpecificBucket"
		effect  = "Allow"
		actions = ["s3:GetObject"]
		resources = [
			"${aws_s3_bucket.this.arn}/*"
		]
	}
}
```

### Security Group Open to Internet

**Typical finding**:
- Inbound rules expose sensitive ports to `0.0.0.0/0`

**Fix**:

```hcl
ingress {
	from_port   = 443
	to_port     = 443
	protocol    = "tcp"
	cidr_blocks = ["10.0.0.0/16"]
}
```

Avoid unrestricted inbound SSH/RDP unless explicitly required and documented.

## Revalidation Commands

After applying fixes, rerun validation with the standard script:

```bash
bash terraform-validation/scripts/validate.sh
```

For faster feedback on specific directories:

```bash
bash terraform-validation/scripts/validate.sh ./terraform/base/ ./terraform/management/
```

## Escalation Rule

- If a finding cannot be fixed immediately (for operational reasons), add documented justification and compensating controls in code review.
- Do not suppress CRITICAL or HIGH findings without explicit approval.
