#--------------------------------------------------------------
# Module: aws/security/cloudtrail/controltower
# Purpose: Add CloudWatch metric filters/alarms and SNS notifications for existing ControlTower-managed CloudTrail.
# Notes: Assumes external CloudTrail and log group; future improvement: toggle individual CloudWatch controls via variables.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an SNS topic resource
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)

  cloudwatch_2_exclusion_clauses = [
    for exclusion in var.cloudwatch_2_event_exclusions :
    # CloudWatch filter patterns do not support !(...); use De Morgan: !(A && B) => (!A || !B)
    format(" && (($.eventSource!=\"%s\") || ($.eventName!=\"%s\"))", exclusion.event_source, exclusion.event_name)
  ]

  cloudwatch_2_pattern = join("", concat(
    [
      "{(($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")) && ($.userIdentity.arn!=\"*assumed-role/AWSServiceRoleFor*\") && ($.userIdentity.arn!=\"*assumed-role/AIOpsRole*\")"
    ],
    local.cloudwatch_2_exclusion_clauses,
    ["}"]
  ))
}

resource "aws_sns_topic" "this" {
  count = var.is_enabled ? 1 : 0

  region                                   = local.region
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

  region                          = local.region
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
# (CloudWatch.1) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_1" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-1-root"
  pattern        = <<PATTERN
{$.userIdentity.type="Root" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !="AwsServiceEvent"}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-1-root"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.1) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-1-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_1" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-1-root"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_1[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_1[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.1] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for root login attempts."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.2) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-2-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_2" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-2-unauthorized-operation-api"
  pattern        = local.cloudwatch_2_pattern
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-2-unauthorized-operation-api"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.2) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-2-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_2" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-2-unauthorized-operation-api"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_2[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_2[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.2] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for unauthorized API calls."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.3) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-3-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_3" {
  count = 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-3-mfa"
  pattern        = <<PATTERN
{($.eventName="ConsoleLogin") && ($.additionalEventData.MFAUsed!="Yes") && ($.userIdentity.type="IAMUser") && ($.responseElements.ConsoleLogin="Success")}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-3-mfa"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.3) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-3-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_3" {
  count = 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-3-mfa"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_3[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_3[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.3] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for console logins that are not protected by multi-factor authentication (MFA)."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.4) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-4-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_4" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-4-iam-policy"
  pattern        = <<PATTERN
{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-4-iam-policy"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.4) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-4-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_4" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-4-iam-policy"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_4[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_4[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.4] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established changes made to Identity and Access Management (IAM) policies."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.5) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-5-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_5" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-5-cloudtrail"
  pattern        = <<PATTERN
{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-5-cloudtrail"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.5) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-5-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_5" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-5-cloudtrail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_5[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_5[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.5] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.6) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-6-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_6" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-6-failed-authentication"
  pattern        = <<PATTERN
{($.eventName=ConsoleLogin) && ($.errorMessage="Failed authentication")}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-6-failed-authentication"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.6) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-6-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_6" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-6-failed-authentication"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_6[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_6[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.6] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for failed console authentication attempts."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.7) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-7-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_7" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-7-cmk"
  pattern        = <<PATTERN
{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-7-cmk"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.7) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-7-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_7" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-7-cmk"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_7[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_7[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.7] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for customer created CMKs which have changed state to disabled or scheduled deletion."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.8) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-8-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_8" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-8-s3-bucket-policy"
  pattern        = <<PATTERN
{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-8-s3-bucket-policy"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.8) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-8-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_8" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-8-s3-bucket-policy"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_8[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_8[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.8] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for changes to S3 bucket policies."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.9) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-9-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_9" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-9-config"
  pattern        = <<PATTERN
{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-9-config"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.9) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-9-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_9" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-9-config"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_9[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_9[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.9] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations"
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.10) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-10-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_10" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-10-security-group"
  pattern        = <<PATTERN
{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-10-security-group"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.10) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-10-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_10" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-10-security-group"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_10[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_10[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.10] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Security Groups are a stateful packet filter that controls ingress and egress traffic within a VPC. It is recommended that a metric filter and alarm be established changes to Security Groups."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.11) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-11-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_11" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-11-nacl"
  pattern        = <<PATTERN
{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-11-nacl"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.11) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-11-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_11" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-11-nacl"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_11[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_11[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.11] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. NACLs are used as a stateless packet filter to control ingress and egress traffic for subnets within a VPC. It is recommended that a metric filter and alarm be established for changes made to NACLs."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.12) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-12-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_12" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-12-network-gateways"
  pattern        = <<PATTERN
{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-12-network-gateways"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.12) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-12-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_12" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-12-network-gateways"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_12[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_12[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.12] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Network gateways are required to send/receive traffic to a destination outside of a VPC. It is recommended that a metric filter and alarm be established for changes to network gateways."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.13) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-13-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_13" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-13-route-table"
  pattern        = <<PATTERN
{($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-13-route-table"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.13) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-13-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_13" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-13-route-table"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_13[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_13[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.13] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Routing tables are used to route network traffic between subnets and to network gateways. It is recommended that a metric filter and alarm be established for changes to route tables."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}

#--------------------------------------------------------------
# (CloudWatch.14) Provides a CloudWatch Log Metric Filter resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-14-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "cloudwatch_14" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  name           = "${var.cloudwatch_name_prefix}cloudwatch-14-vpc"
  pattern        = <<PATTERN
{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}
PATTERN
  log_group_name = var.cloudtrail_log_group_name
  metric_transformation {
    name      = "${var.cloudwatch_name_prefix}cloudwatch-14-vpc"
    namespace = "CloudTrail"
    value     = "1"
  }
}

#--------------------------------------------------------------
# (CloudWatch.14) Provides a CloudWatch Metric Alarm resource.
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-14-remediation
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cloudwatch_14" {
  count = var.is_enabled ? 1 : 0

  region                    = local.region
  alarm_name                = "${var.cloudwatch_name_prefix}cloudwatch-14-vpc"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = aws_cloudwatch_log_metric_filter.cloudwatch_14[0].id
  namespace                 = aws_cloudwatch_log_metric_filter.cloudwatch_14[0].metric_transformation[0].namespace
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.this[0].arn]
  alarm_description         = "[CloudWatch.14] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is possible to have more than 1 VPC within an account, in addition it is also possible to create a peer connection between 2 VPCs enabling network traffic to route between VPCs. It is recommended that a metric filter and alarm be established for changes made to VPCs."
  ok_actions                = [aws_sns_topic.this[0].arn]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"

  tags = var.tags
}
