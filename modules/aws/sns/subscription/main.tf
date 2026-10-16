#--------------------------------------------------------------
# Module: aws/sns/subscription
# Purpose: Provision an SNS topic with optional configuration and a single subscription (e.g., SQS, Lambda, HTTPS endpoint) including delivery and filter policies.
# Notes: Assumes one primary subscription; future enhancement: support multiple subscriptions via for_each and conditional KMS key usage.
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
}

resource "aws_sns_topic" "this" {
  region                                   = local.region
  application_failure_feedback_role_arn    = try(var.aws_sns_topic.application_failure_feedback_role_arn, null)
  application_success_feedback_role_arn    = try(var.aws_sns_topic.application_success_feedback_role_arn, null)
  application_success_feedback_sample_rate = try(var.aws_sns_topic.application_success_feedback_sample_rate, null)
  delivery_policy                          = try(var.aws_sns_topic.delivery_policy, null)
  display_name                             = try(var.aws_sns_topic.display_name, null)
  http_failure_feedback_role_arn           = try(var.aws_sns_topic.http_failure_feedback_role_arn, null)
  http_success_feedback_role_arn           = try(var.aws_sns_topic.http_success_feedback_role_arn, null)
  http_success_feedback_sample_rate        = try(var.aws_sns_topic.http_success_feedback_sample_rate, null)
  kms_master_key_id                        = var.kms_master_key_id
  lambda_failure_feedback_role_arn         = try(var.aws_sns_topic.lambda_failure_feedback_role_arn, null)
  lambda_success_feedback_role_arn         = try(var.aws_sns_topic.lambda_success_feedback_role_arn, null)
  lambda_success_feedback_sample_rate      = try(var.aws_sns_topic.lambda_success_feedback_sample_rate, null)
  name                                     = try(var.aws_sns_topic.name, null)
  name_prefix                              = try(var.aws_sns_topic.name_prefix, null)
  policy                                   = try(var.aws_sns_topic.policy, null)
  sqs_failure_feedback_role_arn            = try(var.aws_sns_topic.sqs_failure_feedback_role_arn, null)
  sqs_success_feedback_role_arn            = try(var.aws_sns_topic.sqs_success_feedback_role_arn, null)
  sqs_success_feedback_sample_rate         = try(var.aws_sns_topic.sqs_success_feedback_sample_rate, null)

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource for subscribing to SNS topics.
# Requires that an SNS topic exist for the subscription to attach to.
# This resource allows you to automatically place messages sent to SNS topics in SQS queues, send them as HTTP(S) POST requests to a given endpoint, send SMS messages, or notify devices / applications. The most likely use case for Terraform users will probably be SQS queues.
#--------------------------------------------------------------
resource "aws_sns_topic_subscription" "this" {
  region                          = local.region
  confirmation_timeout_in_minutes = try(var.aws_sns_topic_subscription.confirmation_timeout_in_minutes, null)
  delivery_policy                 = try(var.aws_sns_topic_subscription.delivery_policy, null)
  endpoint                        = try(var.aws_sns_topic_subscription.endpoint, null)
  endpoint_auto_confirms          = try(var.aws_sns_topic_subscription.endpoint_auto_confirms, null)
  filter_policy                   = try(var.aws_sns_topic_subscription.filter_policy, null)
  protocol                        = try(var.aws_sns_topic_subscription.protocol, null)
  raw_message_delivery            = try(var.aws_sns_topic_subscription.raw_message_delivery, null)
  redrive_policy                  = try(var.aws_sns_topic_subscription.redrive_policy, null)
  topic_arn                       = aws_sns_topic.this.arn
}
