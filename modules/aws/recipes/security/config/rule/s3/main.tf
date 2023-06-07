#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  name_prefix = var.name_prefix == "" ? "" : "${trimsuffix(var.name_prefix, "-")}-"
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "cloudtrail-s3-dataevents-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}cloudtrail-s3-dataevents-enabled"
  description = "Checks whether at least one AWS CloudTrail trail is logging Amazon S3 data events for all S3 buckets. The rule is NON_COMPLIANT if trails log data events for S3 buckets is not configured."
  source {
    owner             = "AWS"
    source_identifier = "CLOUDTRAIL_S3_DATAEVENTS_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-account-level-public-access-blocks" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-account-level-public-access-blocks"
  description = "Checks whether the required public access block settings are configured from account level. The rule is NON_COMPLIANT when the public access block settings are not configured from account level."
  source {
    owner             = "AWS"
    source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-account-level-public-access-blocks" {
  count            = var.is_enabled && var.is_configure_s3_bucket_public_access_block ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-account-level-public-access-blocks[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-block-public-s3.html
  target_id = "AWSConfigRemediation-ConfigureS3PublicAccessBlock"
  parameter {
    name           = "AccountId"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name         = "BlockPublicAcls"
    static_value = var.configure_s3_bucket_public_access_block.block_public_acls
  }
  parameter {
    name         = "BlockPublicPolicy"
    static_value = var.configure_s3_bucket_public_access_block.block_public_policy
  }
  parameter {
    name         = "IgnorePublicAcls"
    static_value = var.configure_s3_bucket_public_access_block.ignore_public_acls
  }
  parameter {
    name         = "RestrictPublicBuckets"
    static_value = var.configure_s3_bucket_public_access_block.restrict_public_buckets
  }
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-blacklisted-actions-prohibited" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-blacklisted-actions-prohibited"
#   description = "Checks that the S3 bucket policy does not allow blacklisted bucket-level and object-level actions for principals from other AWS Accounts. The rule is non-compliant if any blacklisted actions are allowed by the S3 bucket policy."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_BLACKLISTED_ACTIONS_PROHIBITED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-default-lock-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-default-lock-enabled"
#   description = "Checks whether Amazon S3 bucket has lock enabled, by default. The rule is NON_COMPLIANT if the lock is not enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_DEFAULT_LOCK_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-level-public-access-prohibited" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-level-public-access-prohibited"
  description = "Checks if Amazon Simple Storage Service (Amazon S3) buckets are publicly accessible. This rule is NON_COMPLIANT if an Amazon S3 bucket is not listed in the excludedPublicBuckets parameter and bucket level settings are public."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LEVEL_PUBLIC_ACCESS_PROHIBITED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-level-public-access-prohibited" {
  count            = var.is_enabled && var.is_configure_s3_bucket_public_access_block ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-level-public-access-prohibited[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-block-public-s3-bucket.html
  target_id = "AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name         = "BlockPublicAcls"
    static_value = var.configure_s3_bucket_public_access_block.block_public_acls
  }
  parameter {
    name         = "BlockPublicPolicy"
    static_value = var.configure_s3_bucket_public_access_block.block_public_policy
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "IgnorePublicAcls"
    static_value = var.configure_s3_bucket_public_access_block.ignore_public_acls
  }
  parameter {
    name         = "RestrictPublicBuckets"
    static_value = var.configure_s3_bucket_public_access_block.restrict_public_buckets
  }
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-logging-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-logging-enabled"
#   description = "Checks whether logging is enabled for your S3 buckets."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_LOGGING_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-policy-grantee-check" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-policy-grantee-check"
#   description = "Checks that the access granted by the Amazon S3 bucket is restricted to any of the AWS principals, federated users, service principals, IP addresses, or VPCs that you provide. The rule is COMPLIANT if a bucket policy is not present."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_POLICY_GRANTEE_CHECK"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-policy-not-more-permissive" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-policy-not-more-permissive"
#   description = "Verifies that your Amazon S3 bucket policies do not allow other inter-account permissions than the control S3 bucket policy that you provide."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_POLICY_NOT_MORE_PERMISSIVE"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-public-read-prohibited"
  description = "Checks that your Amazon S3 buckets do not allow public read access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-public-read-prohibited" {
  count            = var.is_enabled && var.is_disable_s3_bucket_public_read_write ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-public-read-prohibited[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-disables3bucketpublicreadwrite.html
  target_id = "AWS-DisableS3BucketPublicReadWrite"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-public-write-prohibited"
  description = "Checks that your Amazon S3 buckets do not allow public write access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-public-write-prohibited" {
  count            = var.is_enabled && var.is_disable_s3_bucket_public_read_write ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-public-write-prohibited[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-disables3bucketpublicreadwrite.html
  target_id = "AWS-DisableS3BucketPublicReadWrite"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }
  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-bucket-replication-enabled" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-bucket-replication-enabled"
#   description = "Checks whether the Amazon S3 buckets have cross-region replication enabled."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_BUCKET_REPLICATION_ENABLED"
#   }
#   tags = local.tags
# }
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-server-side-encryption-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-server-side-encryption-enabled"
  description = "Checks that your Amazon S3 bucket either has S3 default encryption enabled or that the S3 bucket policy explicitly denies put-object requests without server side encryption."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-server-side-encryption-enabled" {
  count            = var.is_enabled && var.is_enabled_s3_bucket_encryption ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-server-side-encryption-enabled[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-enableS3bucketencryption.html
  target_id = "AWS-EnableS3BucketEncryption"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "SSEAlgorithm"
    static_value = var.enabled_s3_bucket_encryption_sse_algorithm
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}
#--------------------------------------------------------------
# Provides an AWS Config Rule.
# SecurityHub: enabled
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-ssl-requests-only" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-ssl-requests-only"
  description = "Checks whether S3 buckets have policies that require requests to use Secure Socket Layer (SSL)."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SSL_REQUESTS_ONLY"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-ssl-requests-only" {
  count            = var.is_enabled && var.is_restrict_bucket_ssl_requests_only ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-ssl-requests-only[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-s3-deny-http.html
  target_id = "AWSConfigRemediation-RestrictBucketSSLRequestsOnly"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
resource "aws_config_config_rule" "s3-bucket-versioning-enabled" {
  count       = var.is_enabled ? 1 : 0
  name        = "${local.name_prefix}s3-bucket-versioning-enabled"
  description = "Checks that none of the specified applications are installed on the instance. Optionally, specify the version. Newer versions will not be blacklisted. Optionally, specify the platform to apply the rule only to instances running that platform."
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  tags = local.tags
}
#--------------------------------------------------------------
# Provides an AWS Config Remediation Configuration.
#--------------------------------------------------------------
resource "aws_config_remediation_configuration" "s3-bucket-versioning-enabled" {
  count            = var.is_enabled && var.is_configure_s3_bucket_versioning ? 1 : 0
  config_rule_name = aws_config_config_rule.s3-bucket-versioning-enabled[0].name
  target_type      = "SSM_DOCUMENT"
  # https://docs.aws.amazon.com/systems-manager-automation-runbooks/latest/userguide/automation-aws-configures3bucketversioning.html
  target_id = "AWS-ConfigureS3BucketVersioning"
  parameter {
    name         = "AutomationAssumeRole"
    static_value = var.ssm_automation_assume_role_arn
  }
  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }
  parameter {
    name         = "VersioningState"
    static_value = "Enabled"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 60
}

#--------------------------------------------------------------
# Provides an AWS Config Rule.
#--------------------------------------------------------------
# resource "aws_config_config_rule" "s3-default-encryption-kms" {
#   count       = var.is_enabled ? 1 : 0
#   name        = "${local.name_prefix}s3-default-encryption-kms"
#   description = "Checks whether the Amazon S3 buckets are encrypted with AWS Key Management Service(AWS KMS). The rule is NON_COMPLIANT if the Amazon S3 bucket is not encrypted with AWS KMS key."
#   source {
#     owner             = "AWS"
#     source_identifier = "S3_DEFAULT_ENCRYPTION_KMS"
#   }
#   tags = local.tags
# }
