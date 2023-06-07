#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  temp_resource_config = []
  resource_config = flatten([
    for v in var.config_role_names : concat(local.temp_resource_config, [
      "arn:aws:sts::${var.account_id}:assumed-role/${v}/AWSConfig-BucketConfigCheck",
      "arn:aws:iam::${var.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
      ]
    )
    ]
  )
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  count   = length(local.resource_config) > 0 ? 1 : 0
  version = "2012-10-17"

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      var.bucket_arn
    ]
  }
  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      var.bucket_arn
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery2"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.resource_config
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.bucket_arn}/AWSLogs/${var.account_id}/Config/*"
    ]
  }
}
#--------------------------------------------------------------
# Attaches a policy to an S3 bucket resource.
#--------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  count  = length(local.resource_config) > 1 && var.attach_bucket_policy ? 1 : 0
  bucket = var.bucket
  policy = data.aws_iam_policy_document.this[0].json
}
