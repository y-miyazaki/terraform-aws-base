#--------------------------------------------------------------
# Module: aws/security/config/create
# Purpose: Provision AWS Config recorder, delivery channel (optional S3 bucket), status management, and EventBridge rule/target for non-compliance alerts.
# Notes: Assumes optional creation of dedicated S3 bucket; future improvement: granular toggles for EventBridge rule and recorder components.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region        = coalesce(var.region, data.aws_region.current.region)
  is_s3_enabled = var.is_enabled && var.is_s3_enabled
  bucket_id     = local.is_s3_enabled ? module.s3[0].s3_bucket_id : try(var.aws_s3_bucket_existing.bucket_id, null)
  #   bucket_arn    = local.is_s3_enabled ? module.s3[0].s3_bucket_arn : try(var.aws_s3_bucket_existing.bucket_arn, null)
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "config" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
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
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "config" {
  count = var.is_enabled ? 1 : 0

  role = aws_iam_role.config[0].name
  # https://docs.aws.amazon.com/ja_jp/config/latest/developerguide/security-iam-awsmanpol.html
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

#--------------------------------------------------------------
# Provides an AWS Config Configuration Recorder. Please note that this resource does not start the created recorder automatically.
#--------------------------------------------------------------
resource "aws_config_configuration_recorder" "this" {
  count = var.is_enabled ? 1 : 0

  region   = local.region
  name     = var.aws_config_configuration_recorder.name
  role_arn = aws_iam_role.config[0].arn
  dynamic "recording_group" {
    for_each = try(var.aws_config_configuration_recorder.recording_group, [])

    content {
      all_supported                 = try(recording_group.value.all_supported, null)
      include_global_resource_types = try(recording_group.value.include_global_resource_types, null)
      resource_types                = try(recording_group.value.resource_types, null)
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
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.15.1"

  create_bucket = local.is_s3_enabled
  region        = local.region

  attach_access_log_delivery_policy         = true
  attach_analytics_destination_policy       = false
  attach_cloudtrail_log_delivery_policy     = false
  attach_deny_incorrect_encryption_headers  = false
  attach_deny_incorrect_kms_key_sse         = false
  attach_deny_insecure_transport_policy     = true
  attach_deny_unencrypted_object_uploads    = false
  attach_deny_ssec_encrypted_object_uploads = false
  attach_elb_log_delivery_policy            = false
  attach_inventory_destination_policy       = false
  attach_lb_log_delivery_policy             = false
  attach_policy                             = false
  attach_public_policy                      = true
  attach_require_latest_tls_policy          = true
  attach_waf_log_delivery_policy            = false
  block_public_acls                         = true
  block_public_policy                       = true
  bucket                                    = var.s3_bucket.bucket
  control_object_ownership                  = true
  force_destroy                             = true
  ignore_public_acls                        = true
  lifecycle_rule                            = var.s3_bucket.lifecycle_rule
  logging                                   = var.s3_bucket.logging
  object_ownership                          = "ObjectWriter"
  restrict_public_buckets                   = true
  server_side_encryption_configuration      = var.s3_bucket.server_side_encryption_configuration
  versioning                                = var.s3_bucket.versioning
  website                                   = {}

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an AWS Config Delivery Channel.
#--------------------------------------------------------------
resource "aws_config_delivery_channel" "this" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = var.aws_config_delivery_channel.name
  s3_bucket_name = local.bucket_id
  sns_topic_arn  = try(var.aws_config_delivery_channel.sns_topic_arn, null)
  dynamic "snapshot_delivery_properties" {
    for_each = try(var.aws_config_delivery_channel.snapshot_delivery_properties, [])

    content {
      delivery_frequency = try(snapshot_delivery_properties.value.delivery_frequency, null)
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
  count = var.is_enabled ? 1 : 0

  region     = local.region
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = var.aws_config_configuration_recorder_status.is_enabled

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

  region      = local.region
  description = var.aws_cloudwatch_event_rule.description
  # event_pattern: https://aws.amazon.com/jp/premiumsupport/knowledge-center/config-resource-non-compliant/
  event_pattern = jsonencode({
    source = [
      "aws.config"
    ]
    detail-type = [
      "Config Rules Compliance Change"
    ]
    detail = {
      messageType = [
        "ComplianceChangeNotification"
      ]
      newEvaluationResult = {
        complianceType = [
          "NON_COMPLIANT"
        ]
      }
    }
  })
  name  = var.aws_cloudwatch_event_rule.name
  state = "ENABLED"

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  rule   = aws_cloudwatch_event_rule.this[0].name
  arn    = var.aws_cloudwatch_event_target.arn

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
