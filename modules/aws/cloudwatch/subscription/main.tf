#--------------------------------------------------------------
# Module: aws/cloudwatch/subscription
# Purpose: Create CloudWatch Logs subscription filters forwarding log events to destinations (e.g., Kinesis Firehose) with supporting IAM role and policy.
# Notes: Uses unified tagging; role trust limited to logs service in specific region; future improvement: parameterize destination service types.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
  aws_cloudwatch_log_subscription_filter = {
    for k, v in var.aws_cloudwatch_log_subscription_filter : v.name => v
  }
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.name
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = [
      "arn:aws:firehose:${local.region}:${var.account_id}:deliverystream/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]
    resources = [
      "arn:aws:kms:${local.region}:${var.account_id}:key/*"
    ]
  }

}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  description = try(var.aws_iam_policy.description, null)
  name        = var.aws_iam_policy.name
  path        = try(var.aws_iam_policy.path, "/")
  policy      = data.aws_iam_policy_document.this.json

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = local.aws_cloudwatch_log_subscription_filter

  region          = local.region
  name            = each.value.name
  destination_arn = each.value.destination_arn
  filter_pattern  = try(each.value.filter_pattern, null)
  log_group_name  = each.value.log_group_name
  role_arn        = aws_iam_role.this.arn
  distribution    = try(each.value.distribution, "Random")
}
