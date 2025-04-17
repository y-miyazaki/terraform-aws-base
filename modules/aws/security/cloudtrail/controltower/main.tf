#--------------------------------------------------------------
# For CloudTrail(ControlTower)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  base_principal = "          \"arn:aws:iam::${var.account_id}:root\""
  principal      = local.base_principal
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
${local.principal}
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
${local.principal}
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
# (CIS.3.1) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_1" {
  count          = var.is_enabled ? 1 : 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-unautorizedoperation-api"
  pattern        = <<PATTERN
{(($.errorCode="*UnauthorizedOperation") || ($.errorCode="AccessDenied*")) && $.userIdentity.principalId!="*configLambdaExecution" && $.userIdentity.principalId!="*AutoScaling-UpdateDesiredCapacity"}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
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
  count          = 0
  name           = "${var.cis_name_prefix}cloudtrail-logs-mfa"
  pattern        = <<PATTERN
{($.eventName="ConsoleLogin") && ($.additionalEventData.MFAUsed!="Yes") && ($.userIdentity.type="IAMUser") && ($.responseElements.ConsoleLogin="Success")}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
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
  count                     = 0
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
  log_group_name = var.cloudtrail_log_group_name
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
