#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  set_canary_run_config_command = "aws synthetics update-canary --name ${var.aws_synthetics_canary.name} --run-config '${jsonencode({ TimeoutInSeconds : var.aws_synthetics_canary.run_config[0].timeout_in_seconds, MemoryInMB : var.aws_synthetics_canary.run_config[0].memory_in_mb, ActiveTracing : var.aws_synthetics_canary.run_config[0].active_tracing, EnvironmentVariables : var.aws_synthetics_canary.env })}'"
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count                 = var.is_enabled && var.aws_synthetics_canary.execution_role_arn == null ? 1 : 0
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role, "path", "/")
  tags                  = local.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
data "aws_iam_policy_document" "this" {
  count = var.is_enabled && var.aws_synthetics_canary.execution_role_arn == null ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "${var.s3_bucket_arn}/canary/${var.region}/${var.aws_synthetics_canary.name}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
    ]
    resources = [
      var.s3_bucket_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "s3:ListAllMyBuckets",
      "xray:PutTraceSegments",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CloudWatchSynthetics"]
    }
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  count       = var.is_enabled && var.aws_synthetics_canary.execution_role_arn == null ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = data.aws_iam_policy_document.this[0].json
  tags        = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = var.is_enabled && var.aws_synthetics_canary.execution_role_arn == null ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
#--------------------------------------------------------------
#️ Provides a Synthetics Canary resource.
#--------------------------------------------------------------
resource "aws_synthetics_canary" "this" {
  count                = var.is_enabled ? 1 : 0
  artifact_s3_location = lookup(var.aws_synthetics_canary, "artifact_s3_location")
  execution_role_arn   = var.aws_synthetics_canary.execution_role_arn == null ? aws_iam_role.this[0].arn : var.aws_synthetics_canary.execution_role_arn
  handler              = lookup(var.aws_synthetics_canary, "handler")
  name                 = lookup(var.aws_synthetics_canary, "name")
  runtime_version      = lookup(var.aws_synthetics_canary, "runtime_version")
  dynamic "schedule" {
    for_each = lookup(var.aws_synthetics_canary, "schedule", [])
    content {
      expression          = lookup(schedule.value, "expression", null)
      duration_in_seconds = lookup(schedule.value, "duration_in_seconds", null)
    }
  }
  dynamic "vpc_config" {
    for_each = lookup(var.aws_synthetics_canary, "vpc_config", [])
    content {
      subnet_ids         = lookup(vpc_config.value, "subnet_ids", null)
      security_group_ids = lookup(vpc_config.value, "security_group_ids", null)
    }
  }
  failure_retention_period = lookup(var.aws_synthetics_canary, "failure_retention_period", null)
  dynamic "run_config" {
    for_each = lookup(var.aws_synthetics_canary, "run_config", [])
    content {
      timeout_in_seconds = lookup(run_config.value, "timeout_in_seconds", null)
      memory_in_mb       = lookup(run_config.value, "memory_in_mb", null)
      active_tracing     = lookup(run_config.value, "active_tracing", null)
    }
  }
  s3_bucket                = lookup(var.aws_synthetics_canary, "s3_bucket", null)
  s3_key                   = lookup(var.aws_synthetics_canary, "s3_key", null)
  s3_version               = lookup(var.aws_synthetics_canary, "s3_version", null)
  start_canary             = lookup(var.aws_synthetics_canary, "start_canary", null)
  success_retention_period = lookup(var.aws_synthetics_canary, "success_retention_period", null)
  #   dynamic "artifact_config" {
  #     for_each = lookup(var.aws_synthetics_canary, "artifact_config", [])
  #     content {
  #       dynamic "s3_encryption" {
  #         for_each = lookup(artifact_config.value, "s3_encryption", [])
  #         content {
  #           encryption_mode = lookup(s3_encryption.value, "encryption_mode", null)
  #           kms_key_arn     = lookup(s3_encryption.value, "kms_key_arn", null)
  #         }
  #       }
  #     }
  #   }
  zip_file = lookup(var.aws_synthetics_canary, "zip_file", null)
  tags     = local.tags
  depends_on = [
    aws_iam_role_policy_attachment.this
  ]
}
resource "null_resource" "add_environment_variables_to_canary" {
  count = var.is_enabled ? 1 : 0
  # Run this command again whenever any of the run-config parameters change
  triggers = {
    timeout_in_seconds = var.aws_synthetics_canary.run_config[0].timeout_in_seconds
    memory_in_mb       = var.aws_synthetics_canary.run_config[0].memory_in_mb
    active_tracing     = var.aws_synthetics_canary.run_config[0].active_tracing
    # Trigger values must be strings (or implicitly coerced into strings, like bools), so turn env vars into a string like FOO=bar,FIZZ=buzz
    env = join(",", [for key, value in var.aws_synthetics_canary.env : "${key}=${value}"])
  }
  provisioner "local-exec" {
    command = local.set_canary_run_config_command
  }

  depends_on = [aws_synthetics_canary.this]
}
