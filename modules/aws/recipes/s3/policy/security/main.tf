#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  temp_resource_config = []
  resource_config = flatten([
    for v in var.config_role_names : concat(local.temp_resource_config, ["arn:aws:sts::${var.account_id}:assumed-role/${v}/AWSConfig-BucketConfigCheck"])
    ]
  )
  statement = [
    # For Security
    {
      sid    = "AllowSSLRequestsOnly"
      effect = "Deny"
      principals = [
        {
          type        = "*"
          identifiers = ["*"]
        }
      ]
      actions = [
        "s3:*"
      ]
      resources = [
        var.bucket_arn,
        "${var.bucket_arn}/*"
      ]
      condition = [
        {
          test     = "Bool"
          variable = "aws:SecureTransport"
          values   = ["false"]
        }
      ]
    },
    # For CloudTrail
    {
      sid    = "AWSCloudTrailAclCheck"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions = [
        "s3:GetBucketAcl"
      ]
      resources = [
        var.bucket_arn
      ]
    },
    # For CloudTrail
    {
      sid    = "AWSCloudTrailWrite"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${var.bucket_arn}/AWSLogs/${var.account_id}/*"
      ]
      condition = [
        {
          test     = "StringEquals"
          variable = "s3:x-amz-acl"
          values   = ["bucket-owner-full-control"]
        }
      ]
    },

    # For AWS Config
    {
      sid    = "AWSConfigBucketPermissionsCheck"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["config.amazonaws.com"]
        }
      ]
      actions = [
        "s3:GetBucketAcl"
      ]
      resources = [
        var.bucket_arn
      ]
    },
    {
      sid    = "AWSConfigBucketExistenceCheck"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["config.amazonaws.com"]
        }
      ]
      actions = [
        "s3:ListBucket"
      ]
      resources = [
        var.bucket_arn
      ]
    },
    # For AWS Config
    {
      sid    = "AWSConfigBucketDelivery"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["config.amazonaws.com"]
        }
      ]
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${var.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
      ]
    },
    {
      sid    = "AWSConfigBucketDelivery2"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = local.resource_config
        }
      ]
      actions = [
        "s3:PutObject"
      ]
      resources = [
        "${var.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
      ]
    }
  ]
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
# Policy for CloudTrail and Config.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = local.statement
    content {
      sid           = lookup(statement.value, "sid", null)
      effect        = lookup(statement.value, "effect", null)
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)
      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = lookup(principals.value, "type", null)
          identifiers = lookup(principals.value, "identifiers", null)
        }
      }
      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          type        = lookup(not_principals.value, "type", null)
          identifiers = lookup(not_principals.value, "identifiers", null)
        }
      }
      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = lookup(condition.value, "test", null)
          variable = lookup(condition.value, "variable", null)
          values   = lookup(condition.value, "values", null)
        }
      }
    }
  }
  version = "2012-10-17"
}

#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket
  policy = data.aws_iam_policy_document.this.json
}
