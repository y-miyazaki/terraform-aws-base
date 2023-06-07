#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  is_s3_enabled = var.is_enabled && var.is_s3_enabled
  bucket_id     = local.is_s3_enabled ? module.s3.s3_bucket_id : var.aws_s3_bucket_existing.bucket_id
  #   bucket_arn    = local.is_s3_enabled ? module.s3.s3_bucket_arn : var.aws_s3_bucket_existing.bucket_arn
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "config" {
  count                 = var.is_enabled ? 1 : 0
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path                  = lookup(var.aws_iam_role, "path", "/")
  force_detach_policies = true
  tags                  = local.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "config" {
  count = var.is_enabled ? 1 : 0
  role  = aws_iam_role.config[0].name
  # https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/security-iam-awsmanpol.html
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
#--------------------------------------------------------------
# Provides an AWS Config Configuration Recorder. Please note that this resource does not start the created recorder automatically.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  count    = var.is_enabled ? 1 : 0
  name     = lookup(var.aws_config_configuration_recorder, "name")
  role_arn = aws_iam_role.config[0].arn
  dynamic "recording_group" {
    for_each = lookup(var.aws_config_configuration_recorder, "recording_group", [])
    content {
      all_supported                 = lookup(recording_group.value, "all_supported", null)
      include_global_resource_types = lookup(recording_group.value, "include_global_resource_types", null)
      resource_types                = lookup(recording_group.value, "resource_types", null)
    }
  }
  depends_on = [
    aws_iam_role.config
  ]
}

#--------------------------------------------------------------
# S3
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
module "s3" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.6.0"
  create_bucket = local.is_s3_enabled

  acl                                   = "log-delivery-write"
  attach_deny_insecure_transport_policy = false
  attach_elb_log_delivery_policy        = false
  attach_lb_log_delivery_policy         = false
  attach_policy                         = false
  attach_public_policy                  = true
  attach_require_latest_tls_policy      = false
  block_public_acls                     = true
  block_public_policy                   = true
  bucket                                = var.s3_bucket.bucket
  force_destroy                         = true
  ignore_public_acls                    = true
  lifecycle_rule                        = var.s3_bucket.lifecycle_rule
  logging                               = var.s3_bucket.logging
  restrict_public_buckets               = true
  server_side_encryption_configuration  = var.s3_bucket.server_side_encryption_configuration
  tags                                  = local.tags
  versioning                            = var.s3_bucket.versioning
}

#--------------------------------------------------------------
# Provides an AWS Config Delivery Channel.
#--------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  count          = var.is_enabled ? 1 : 0
  name           = lookup(var.aws_config_delivery_channel, "name")
  s3_bucket_name = local.bucket_id
  sns_topic_arn  = lookup(var.aws_config_delivery_channel, "sns_topic_arn", null)
  dynamic "snapshot_delivery_properties" {
    for_each = lookup(var.aws_config_delivery_channel, "snapshot_delivery_properties", [])
    content {
      delivery_frequency = lookup(snapshot_delivery_properties.value, "delivery_frequency", null)
    }
  }
  depends_on = [
    aws_config_configuration_recorder.this
  ]
}

#--------------------------------------------------------------
# Manages status (recording / stopped) of an AWS Config Configuration Recorder.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder_status" "this" {
  count      = var.is_enabled ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = lookup(var.aws_config_configuration_recorder_status, "is_enabled", true)
  depends_on = [
    aws_config_delivery_channel.this,
    aws_config_configuration_recorder.this
  ]
}

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0
  name  = lookup(var.aws_cloudwatch_event_rule, "name")
  # event_pattern: https://aws.amazon.com/jp/premiumsupport/knowledge-center/config-resource-non-compliant/
  event_pattern = <<EVENT_PATTERN
{
    "source": [
        "aws.config"
    ],
    "detail-type": [
        "Config Rules Compliance Change"
    ],
    "detail": {
        "messageType": [
            "ComplianceChangeNotification"
        ],
        "newEvaluationResult": {
            "complianceType": [
                "NON_COMPLIANT"
            ]
        }
    }
}
EVENT_PATTERN
  description   = lookup(var.aws_cloudwatch_event_rule, "description")
  is_enabled    = true
  tags          = local.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.this[0].name
  arn   = lookup(var.aws_cloudwatch_event_target, "arn")
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
