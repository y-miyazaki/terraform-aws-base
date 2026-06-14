#--------------------------------------------------------------
# Module: aws/security/cloudtrail/cloudtrail
# Purpose: Provision CloudTrail with optional dedicated S3 bucket, CloudWatch log integration, CIS metric filters/alarms, and SNS notifications.
# Notes: Extensive CIS coverage (3.1-3.14); future improvement: parameterize CIS control enablement flags individually.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  is_s3_enabled = var.is_enabled && var.is_s3_enabled
  bucket_id     = local.is_s3_enabled ? module.s3.s3_bucket_id : var.aws_s3_bucket_existing.bucket_id
  #   bucket_arn    = local.is_s3_enabled ? module.s3.s3_bucket_arn : var.aws_s3_bucket_existing.bucket_arn
}

#--------------------------------------------------------------
# Provides an SNS topic resource
#--------------------------------------------------------------
resource "aws_sns_topic" "this" {
  count = var.is_enabled ? 1 : 0

  name                                     = try(var.aws_sns_topic.name, null)
  name_prefix                              = try(var.aws_sns_topic.name_prefix, null)
  display_name                             = try(var.aws_sns_topic.display_name, null)
  policy                                   = try(var.aws_sns_topic.policy, null)
  delivery_policy                          = try(var.aws_sns_topic.delivery_policy, null)
  application_success_feedback_role_arn    = try(var.aws_sns_topic.application_success_feedback_role_arn, null)
  application_success_feedback_sample_rate = try(var.aws_sns_topic.application_success_feedback_sample_rate, null)
  application_failure_feedback_role_arn    = try(var.aws_sns_topic.application_failure_feedback_role_arn, null)
  http_success_feedback_role_arn           = try(var.aws_sns_topic.http_success_feedback_role_arn, null)
  http_success_feedback_sample_rate        = try(var.aws_sns_topic.http_success_feedback_sample_rate, null)
  http_failure_feedback_role_arn           = try(var.aws_sns_topic.http_failure_feedback_role_arn, null)
  kms_master_key_id                        = var.sns_kms_master_key_id
  lambda_success_feedback_role_arn         = try(var.aws_sns_topic.lambda_success_feedback_role_arn, null)
  lambda_success_feedback_sample_rate      = try(var.aws_sns_topic.lambda_success_feedback_sample_rate, null)
  lambda_failure_feedback_role_arn         = try(var.aws_sns_topic.lambda_failure_feedback_role_arn, null)
  sqs_success_feedback_role_arn            = try(var.aws_sns_topic.sqs_success_feedback_role_arn, null)
  sqs_success_feedback_sample_rate         = try(var.aws_sns_topic.sqs_success_feedback_sample_rate, null)
  sqs_failure_feedback_role_arn            = try(var.aws_sns_topic.sqs_failure_feedback_role_arn, null)

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource for subscribing to SNS topics.
# Requires that an SNS topic exist for the subscription to attach to.
# This resource allows you to automatically place messages sent to SNS topics in SQS queues, send them as HTTP(S) POST requests to a given endpoint, send SMS messages, or notify devices / applications. The most likely use case for Terraform users will probably be SQS queues.
#--------------------------------------------------------------
resource "aws_sns_topic_subscription" "this" {
  count = var.is_enabled ? 1 : 0

  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = try(var.aws_sns_topic_subscription.protocol, null)
  endpoint                        = try(var.aws_sns_topic_subscription.endpoint, null)
  endpoint_auto_confirms          = try(var.aws_sns_topic_subscription.endpoint_auto_confirms, null)
  confirmation_timeout_in_minutes = try(var.aws_sns_topic_subscription.confirmation_timeout_in_minutes, null)
  raw_message_delivery            = try(var.aws_sns_topic_subscription.raw_message_delivery, null)
  filter_policy                   = try(var.aws_sns_topic_subscription.filter_policy, null)
  delivery_policy                 = try(var.aws_sns_topic_subscription.delivery_policy, null)
  redrive_policy                  = try(var.aws_sns_topic_subscription.redrive_policy, null)
}

#--------------------------------------------------------------
# Provides a CloudWatch Log Group resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = var.is_enabled ? 1 : 0

  name              = var.aws_cloudwatch_log_group.name
  retention_in_days = var.aws_cloudwatch_log_group.retention_in_days
  kms_key_id        = try(var.aws_cloudwatch_log_group.kms_key_id, null)

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.1) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_1" {
  count = var.is_enabled ? 1 : 0

  name = "${var.cis_name_prefix}cloudtrail-logs-unauthorized-operation-api"
  # noise list:
  # - assumed-role/AWSServiceRoleFor*
  # - assumed-role/AIOpsRole*
  pattern        = <<PATTERN
{(($.errorCode="*UnauthorizedOperation") || ($.errorCode="AccessDenied*")) && ($.userIdentity.arn!="*assumed-role/AWSServiceRoleFor*") && ($.userIdentity.arn!="*assumed-role/AIOpsRole*")}
PATTERN
  log_group_name = aws_cloudwatch_log_group.this[0].name
  metric_transformation {
    name      = "${var.cis_name_prefix}cloudtrail-logs-unauthorized-operation-api"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CIS.3.1) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cis_3_1" {
  count = var.is_enabled ? 1 : 0

  alarm_name                = "${var.cis_name_prefix}cloudtrail-logs-unauthorized-operation-api"
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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.2) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.2-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_2" {
  count = 0

  name           = "${var.cis_name_prefix}cloudtrail-logs-mfa"
  pattern        = <<PATTERN
{($.eventName="ConsoleLogin") && ($.additionalEventData.MFAUsed!="Yes") && ($.userIdentity.type="IAMUser") && ($.responseElements.ConsoleLogin="Success")}
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
  count = 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.3) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.3-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_3" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.4) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.4
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_4" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.5) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.5
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_5" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.6) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.6-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_6" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.7) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.7-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_7" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.8) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.8-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_8" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.9) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.9
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_9" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.10) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-3.10
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_10" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.11) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.11-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_11" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.12) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.12-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_12" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.13) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.13-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_13" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CIS.3.14) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-3.14-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cis_3_14" {
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

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
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
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
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "this" {
  count = var.is_enabled ? 1 : 0

  description = try(var.aws_iam_policy.description, null)
  name        = var.aws_iam_policy.name
  path        = try(var.aws_iam_policy.path, "/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailCreateLogStream"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}:log-stream:*"
        ]
      },
      {
        Sid    = "AWSCloudTrailPutLogEvents"
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.this[0].name}:log-stream:*"
        ]
      }
    ]
  })

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count = var.is_enabled ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

#--------------------------------------------------------------
# S3
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
#--------------------------------------------------------------
module "s3" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "5.14.0"
  create_bucket = local.is_s3_enabled

  attach_access_log_delivery_policy         = true
  attach_analytics_destination_policy       = false
  attach_cloudtrail_log_delivery_policy     = true
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
# Provides a CloudTrail resource.
#--------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  count = var.is_enabled ? 1 : 0

  name                          = var.aws_cloudtrail.name
  s3_bucket_name                = local.bucket_id
  s3_key_prefix                 = try(var.aws_cloudtrail.s3_key_prefix, null)
  cloud_watch_logs_role_arn     = aws_iam_role.this[0].arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this[0].arn}:*"
  enable_logging                = try(var.aws_cloudtrail.enable_logging, true)
  include_global_service_events = try(var.aws_cloudtrail.include_global_service_events, true)
  is_multi_region_trail         = try(var.aws_cloudtrail.is_multi_region_trail, false)
  is_organization_trail         = try(var.aws_cloudtrail.is_organization_trail, false)
  sns_topic_name                = try(var.aws_cloudtrail.sns_topic_name, null)
  enable_log_file_validation    = try(var.aws_cloudtrail.enable_log_file_validation, true)
  kms_key_id                    = var.cloudtrail_kms_master_key_id
  dynamic "event_selector" {
    for_each = try(var.aws_cloudtrail.event_selector, [])

    content {
      read_write_type           = try(event_selector.value.read_write_type, null)
      include_management_events = try(event_selector.value.include_management_events, null)
      dynamic "data_resource" {
        for_each = try(event_selector.value.data_resource, [])

        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }
  dynamic "insight_selector" {
    for_each = try(var.aws_cloudtrail.insight_selector, [])

    content {
      insight_type = try(insight_selector.value.insight_type, null)
    }
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.this,
    module.s3,
  ]
}
