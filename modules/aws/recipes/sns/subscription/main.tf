#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a KMS customer master key.
#--------------------------------------------------------------
resource "aws_kms_key" "this" {
  description             = lookup(var.aws_kms_key, "description", null)
  policy                  = <<POLICY
{
  "Version":"2012-10-17",
  "Id":"Key policy created",
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
      "Sid":"Allow_for_CMK",
      "Effect":"Allow",
      "Principal":{
        "Service":[
          "cloudwatch.amazonaws.com",
          "ses.amazonaws.com"
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
  deletion_window_in_days = lookup(var.aws_kms_key, "deletion_window_in_days", 7)
  is_enabled              = lookup(var.aws_kms_key, "is_enabled", true)
  enable_key_rotation     = lookup(var.aws_kms_key, "enable_key_rotation", true)
  tags = merge(local.tags, {
    Name = lookup(var.aws_kms_key, "alias_name")
    }
  )
}
#--------------------------------------------------------------
# Provides an alias for a KMS customer master key. AWS Console enforces 1-to-1 mapping between aliases & keys, but API (hence Terraform too) allows you to create as many aliases as the account limits allow you.
#--------------------------------------------------------------
resource "aws_kms_alias" "this" {
  name          = lookup(var.aws_kms_key, "alias_name")
  target_key_id = aws_kms_key.this.key_id
}

#--------------------------------------------------------------
# Provides an SNS topic resource
#--------------------------------------------------------------
resource "aws_sns_topic" "this" {
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
  kms_master_key_id                        = aws_kms_key.this.id
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
  topic_arn                       = aws_sns_topic.this.arn
  protocol                        = lookup(var.aws_sns_topic_subscription, "protocol", null)
  endpoint                        = lookup(var.aws_sns_topic_subscription, "endpoint", null)
  endpoint_auto_confirms          = lookup(var.aws_sns_topic_subscription, "endpoint_auto_confirms", null)
  confirmation_timeout_in_minutes = lookup(var.aws_sns_topic_subscription, "confirmation_timeout_in_minutes", null)
  raw_message_delivery            = lookup(var.aws_sns_topic_subscription, "raw_message_delivery", null)
  filter_policy                   = lookup(var.aws_sns_topic_subscription, "filter_policy", null)
  delivery_policy                 = lookup(var.aws_sns_topic_subscription, "delivery_policy", null)
  redrive_policy                  = lookup(var.aws_sns_topic_subscription, "redrive_policy", null)
}
