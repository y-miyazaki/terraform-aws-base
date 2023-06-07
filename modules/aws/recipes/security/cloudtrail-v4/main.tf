
#--------------------------------------------------------------
# For CloudTrail
#--------------------------------------------------------------
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
# Provides a KMS customer master key.
#--------------------------------------------------------------
resource "aws_kms_key" "cloudtrail" {
  count                   = var.is_enabled ? 1 : 0
  description             = lookup(var.aws_kms_key.cloudtrail, "description", null)
  policy                  = <<POLICY
{
  "Version":"2012-10-17",
  "Id":"Key policy created by CloudTrail",
  "Statement":[
    {
      "Sid":"Enable IAM User Permissions",
      "Effect":"Allow",
      "Principal":{
        "AWS":[
          "arn:aws:iam::${var.account_id}:root",
          "arn:aws:iam::${var.account_id}:user/${var.user}"
        ]
      },
      "Action":"kms:*",
      "Resource":"*"
    },
    {
      "Sid":"Allow CloudTrail to encrypt logs",
      "Effect":"Allow",
      "Principal":{
        "Service":"cloudtrail.amazonaws.com"
      },
      "Action":"kms:GenerateDataKey*",
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "kms:EncryptionContext:aws:cloudtrail:arn":"arn:aws:cloudtrail:*:${var.account_id}:trail/*"
        }
      }
    },
    {
      "Sid":"Allow CloudTrail to describe key",
      "Effect":"Allow",
      "Principal":{
        "Service":"cloudtrail.amazonaws.com"
      },
      "Action":"kms:DescribeKey",
      "Resource":"*"
    },
    {
      "Sid":"Allow principals in the account to decrypt log files",
      "Effect":"Allow",
      "Principal":{
        "AWS":"*"
      },
      "Action":[
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource":"*",
      "Condition":{
        "StringEquals":{
          "kms:CallerAccount":"${var.account_id}"
        },
        "StringLike":{
          "kms:EncryptionContext:aws:cloudtrail:arn":"arn:aws:cloudtrail:*:${var.account_id}:trail/*"
        }
      }
    },
    {
      "Sid":"Allow alias creation during setup",
      "Effect":"Allow",
      "Principal":{
        "AWS":"*"
      },
      "Action":"kms:CreateAlias",
      "Resource":"*",
      "Condition":{
        "StringEquals":{
          "kms:CallerAccount":"${var.account_id}",
          "kms:ViaService":"ec2.${var.region}.amazonaws.com"
        }
      }
    },
    {
      "Sid":"Enable cross account log decryption",
      "Effect":"Allow",
      "Principal":{
        "AWS":"*"
      },
      "Action":[
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource":"*",
      "Condition":{
        "StringEquals":{
          "kms:CallerAccount":"${var.account_id}"
        },
        "StringLike":{
          "kms:EncryptionContext:aws:cloudtrail:arn":"arn:aws:cloudtrail:*:${var.account_id}:trail/*"
        }
      }
    }
  ]
}
POLICY
  deletion_window_in_days = lookup(var.aws_kms_key.cloudtrail, "deletion_window_in_days", 7)
  is_enabled              = lookup(var.aws_kms_key.cloudtrail, "is_enabled", true)
  enable_key_rotation     = lookup(var.aws_kms_key.cloudtrail, "enable_key_rotation", true)
  tags = merge(local.tags, {
    Name = lookup(var.aws_kms_key.cloudtrail, "alias_name")
    }
  )
}
#--------------------------------------------------------------
# Provides an alias for a KMS customer master key. AWS Console enforces 1-to-1 mapping between aliases & keys, but API (hence Terraform too) allows you to create as many aliases as the account limits allow you.
#--------------------------------------------------------------
resource "aws_kms_alias" "cloudtrail" {
  count         = var.is_enabled ? 1 : 0
  name          = lookup(var.aws_kms_key.cloudtrail, "alias_name")
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}
#--------------------------------------------------------------
# Provides a KMS customer master key.
#--------------------------------------------------------------
resource "aws_kms_key" "sns" {
  count                   = var.is_enabled ? 1 : 0
  description             = lookup(var.aws_kms_key.sns, "description", null)
  policy                  = <<POLICY
{
  "Version":"2012-10-17",
  "Id":"Key policy created by CloudTrail",
  "Statement":[
    {
      "Sid":"Enable IAM User Permissions",
      "Effect":"Allow",
      "Principal":{
        "AWS":[
          "arn:aws:iam::${var.account_id}:root",
          "arn:aws:iam::${var.account_id}:user/${var.user}"
        ]
      },
      "Action":"kms:*",
      "Resource":"*"
    },
    {
      "Sid":"Allow alias creation during setup",
      "Effect":"Allow",
      "Principal":{
        "AWS":"*"
      },
      "Action":"kms:CreateAlias",
      "Resource":"*",
      "Condition":{
        "StringEquals":{
          "kms:CallerAccount":"${var.account_id}",
          "kms:ViaService":"ec2.${var.region}.amazonaws.com"
        }
      }
    },
    {
      "Sid":"Allow_CloudWatch_for_CMK",
      "Effect":"Allow",
      "Principal":{
        "Service":[
          "cloudwatch.amazonaws.com"
        ]
      },
      "Action":[
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource":"*"
    }
  ]
}
POLICY
  deletion_window_in_days = lookup(var.aws_kms_key.sns, "deletion_window_in_days", 7)
  is_enabled              = lookup(var.aws_kms_key.sns, "is_enabled", true)
  enable_key_rotation     = lookup(var.aws_kms_key.sns, "enable_key_rotation", true)
  tags = merge(local.tags, {
    Name = lookup(var.aws_kms_key.sns, "alias_name")
    }
  )
}
#--------------------------------------------------------------
# Provides an alias for a KMS customer master key. AWS Console enforces 1-to-1 mapping between aliases & keys, but API (hence Terraform too) allows you to create as many aliases as the account limits allow you.
#--------------------------------------------------------------
resource "aws_kms_alias" "sns" {
  count         = var.is_enabled ? 1 : 0
  name          = lookup(var.aws_kms_key.sns, "alias_name")
  target_key_id = aws_kms_key.sns[0].key_id
}

#--------------------------------------------------------------
# Provides an SNS topic resource
#--------------------------------------------------------------
resource "aws_sns_topic" "this" {
  count                                    = var.is_enabled ? 1 : 0
  name                                     = lookup(var.aws_sns_topic, "name", null)
  name_prefix                              = lookup(var.aws_sns_topic, "name_prefix", null)
  display_name                             = lookup(var.aws_sns_topic, "display_name", null)
  policy                                   = lookup(var.aws_sns_topic, "policy", null)
  delivery_policy                          = lookup(var.aws_sns_topic, "delivery_policy", null)
  application_success_feedback_role_arn    = lookup(var.aws_sns_topic, "application_success_feedback_role_arn", null)
  application_success_feedback_sample_rate = lookup(var.aws_sns_topic, "application_success_feedback_sample_rate", null)
  application_failure_feedback_role_arn    = lookup(var.aws_sns_topic, "application_failure_feedback_role_arn", null)
  http_success_feedback_role_arn           = lookup(var.aws_sns_topic, "http_success_feedback_role_arn", null)
  http_success_feedback_sample_rate        = lookup(var.aws_sns_topic, "http_success_feedback_sample_rate", null)
  http_failure_feedback_role_arn           = lookup(var.aws_sns_topic, "http_failure_feedback_role_arn", null)
  kms_master_key_id                        = aws_kms_key.sns[0].id
  lambda_success_feedback_role_arn         = lookup(var.aws_sns_topic, "lambda_success_feedback_role_arn", null)
  lambda_success_feedback_sample_rate      = lookup(var.aws_sns_topic, "lambda_success_feedback_sample_rate", null)
  lambda_failure_feedback_role_arn         = lookup(var.aws_sns_topic, "lambda_failure_feedback_role_arn", null)
  sqs_success_feedback_role_arn            = lookup(var.aws_sns_topic, "sqs_success_feedback_role_arn", null)
  sqs_success_feedback_sample_rate         = lookup(var.aws_sns_topic, "sqs_success_feedback_sample_rate", null)
  sqs_failure_feedback_role_arn            = lookup(var.aws_sns_topic, "sqs_failure_feedback_role_arn", null)
  tags                                     = local.tags
}
#--------------------------------------------------------------
# Provides a resource for subscribing to SNS topics.
# Requires that an SNS topic exist for the subscription to attach to.
# This resource allows you to automatically place messages sent to SNS topics in SQS queues, send them as HTTP(S) POST requests to a given endpoint, send SMS messages, or notify devices / applications. The most likely use case for Terraform users will probably be SQS queues.
#--------------------------------------------------------------
resource "aws_sns_topic_subscription" "this" {
  count                           = var.is_enabled ? 1 : 0
  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = lookup(var.aws_sns_topic_subscription, "protocol", null)
  endpoint                        = lookup(var.aws_sns_topic_subscription, "endpoint", null)
  endpoint_auto_confirms          = lookup(var.aws_sns_topic_subscription, "endpoint_auto_confirms", null)
  confirmation_timeout_in_minutes = lookup(var.aws_sns_topic_subscription, "confirmation_timeout_in_minutes", null)
  raw_message_delivery            = lookup(var.aws_sns_topic_subscription, "raw_message_delivery", null)
  filter_policy                   = lookup(var.aws_sns_topic_subscription, "filter_policy", null)
  delivery_policy                 = lookup(var.aws_sns_topic_subscription, "delivery_policy", null)
  redrive_policy                  = lookup(var.aws_sns_topic_subscription, "redrive_policy", null)
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Group resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count             = var.is_enabled ? 1 : 0
  name              = lookup(var.aws_cloudwatch_log_group, "name")
  retention_in_days = lookup(var.aws_cloudwatch_log_group, "retention_in_days")
  kms_key_id        = lookup(var.aws_cloudwatch_log_group, "kms_key_id", null)
  tags              = local.tags
}

#--------------------------------------------------------------
# (CIS.3.1) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_1" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-unautorizedoperation-api"
  pattern        = <<PATTERN
{($.errorCode="*UnauthorizedOperation") || ($.errorCode="AccessDenied*")}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-unautorizedoperation-api"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.1) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_1" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-unautorizedoperation-api"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_1[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_1[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.1] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for unauthorized API calls."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}

#--------------------------------------------------------------
# (CIS.3.2) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.2-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_2" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-mfa"
  pattern        = <<PATTERN
{($.eventName="ConsoleLogin") && ($.additionalEventData.MFAUsed !="Yes")}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-mfa"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.2) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.2-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_2" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-mfa"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_2[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_2[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.2] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for console logins that are not protected by multi-factor authentication (MFA)."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}

#--------------------------------------------------------------
# (CIS.3.3) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.3-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_3" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-root"
  pattern        = <<PATTERN
{$.userIdentity.type="Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !="AwsServiceEvent"}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-root"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.3) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.3-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_3" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-root"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_3[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_3[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.3] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for root login attempts."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.4) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.4
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_4" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-iam-policy"
  pattern        = <<PATTERN
{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-iam-policy"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.4) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.4
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_4" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-iam-policy"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_4[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_4[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.4] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established changes made to Identity and Access Management (IAM) policies."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.5) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.5
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_5" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-cloudtrail"
  pattern        = <<PATTERN
{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-cloudtrail"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.5) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.5
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_5" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-cloudtrail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_5[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_5[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.5] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.6) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.6-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_6" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-failed-authentication"
  pattern        = <<PATTERN
{($.eventName=ConsoleLogin) && ($.errorMessage="Failed authentication")}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-failed-authentication"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.6) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.6-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_6" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-failed-authentication"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_6[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_6[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.6] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for failed console authentication attempts."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.7) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.7-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_7" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-cmk"
  pattern        = <<PATTERN
{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-cmk"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.7) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.7-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_7" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-cmk"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_7[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_7[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.7] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for customer created CMKs which have changed state to disabled or scheduled deletion."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.8) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.8-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_8" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-s3-bucket-policy"
  pattern        = <<PATTERN
{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-s3-bucket-policy"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.8) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.8-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_8" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-s3-bucket-policy"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_8[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_8[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.8] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for changes to S3 bucket policies."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.9) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.9
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_9" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-config"
  pattern        = <<PATTERN
{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-config"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.9) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.9
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_9" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-config"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_9[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_9[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.9] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations"
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.10) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.10
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_10" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-security-group"
  pattern        = <<PATTERN
{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-security-group"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.10) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.10
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_10" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-security-group"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_10[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_10[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.10] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Security Groups are a stateful packet filter that controls ingress and egress traffic within a VPC. It is recommended that a metric filter and alarm be established changes to Security Groups."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.11) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.11-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_11" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-nacl"
  pattern        = <<PATTERN
{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-nacl"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.11) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.11-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_11" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-nacl"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_11[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_11[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.11] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. NACLs are used as a stateless packet filter to control ingress and egress traffic for subnets within a VPC. It is recommended that a metric filter and alarm be established for changes made to NACLs."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.12) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.12-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_12" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-network-gateways"
  pattern        = <<PATTERN
{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-network-gateways"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.12) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.12-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_12" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-network-gateways"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_12[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_12[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.12] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Network gateways are required to send/receive traffic to a destination outside of a VPC. It is recommended that a metric filter and alarm be established for changes to network gateways."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.13) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.13-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_13" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-route-table"
  pattern        = <<PATTERN
{($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-route-table"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.13) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.13-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_13" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-route-table"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_13[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_13[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.13] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Routing tables are used to route network traffic between subnets and to network gateways. It is recommended that a metric filter and alarm be established for changes to route tables."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}
#--------------------------------------------------------------
# (CIS.3.14) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.14-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_14" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-vpc"
  pattern        = <<PATTERN
{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-vpc"
    namespace = "CloudTrail"
    value     = "1"
  }
}
#--------------------------------------------------------------
# (CIS.3.14) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.14-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_14" {
  count                     = var.is_enabled ? 1 : 0
  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-vpc"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cis_3_14[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cis_3_14[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CIS.3.14] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is possible to have more than 1 VPC within an account, in addition it is also possible to create a peer connection between 2 VPCs enabling network traffic to route between VPCs. It is recommended that a metric filter and alarm be established for changes made to VPCs."
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  tags                      = local.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count              = var.is_enabled ? 1 : 0
  name               = lookup(var.aws_iam_role, "name")
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path               = lookup(var.aws_iam_role, "path", "/")
  tags               = local.tags
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "this" {
  count       = var.is_enabled ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}:log-stream:*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}:log-stream:*"
            ]
        }
    ]
}
POLICY
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = var.is_enabled ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
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
# Provides a CloudTrail resource.
#--------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  count                         = var.is_enabled ? 1 : 0
  name                          = lookup(var.aws_cloudtrail, "name")
  s3_bucket_name                = local.bucket_id
  s3_key_prefix                 = lookup(var.aws_cloudtrail, "s3_key_prefix", null)
  cloud_watch_logs_role_arn     = aws_iam_role.this[0].arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this[0].arn}:*"
  enable_logging                = lookup(var.aws_cloudtrail, "enable_logging", true)
  include_global_service_events = lookup(var.aws_cloudtrail, "include_global_service_events", true)
  is_multi_region_trail         = lookup(var.aws_cloudtrail, "is_multi_region_trail", false)
  is_organization_trail         = lookup(var.aws_cloudtrail, "is_organization_trail", false)
  sns_topic_name                = lookup(var.aws_cloudtrail, "sns_topic_name", null)
  enable_log_file_validation    = lookup(var.aws_cloudtrail, "enable_log_file_validation", true)
  kms_key_id                    = aws_kms_key.cloudtrail[0].arn
  dynamic "event_selector" {
    for_each = lookup(var.aws_cloudtrail, "event_selector", [])
    content {
      read_write_type           = lookup(event_selector.value, "read_write_type", null)
      include_management_events = lookup(event_selector.value, "include_management_events", null)
      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resource", [])
        content {
          type   = lookup(data_resource.value, "type")
          values = lookup(data_resource.value, "values")
        }
      }
    }
  }
  dynamic "insight_selector" {
    for_each = lookup(var.aws_cloudtrail, "insight_selector", [])
    content {
      insight_type = lookup(insight_selector.value, "insight_type", null)
    }
  }
  tags = local.tags
  depends_on = [
    aws_kms_key.cloudtrail,
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.this,
    module.s3,
  ]
}
