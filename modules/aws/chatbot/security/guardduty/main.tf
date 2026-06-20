#--------------------------------------------------------------
# Module: aws/chatbot/security/guardduty
# Purpose: Create EventBridge rule and SNS topic to forward GuardDuty findings to Slack via AWS Chatbot.
# Notes: SNS topic policy allows events.amazonaws.com publish; unified tagging applied; future improvement: add severity filtering and batching.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  description = "This cloudwatch event used for GuardDuty."
  event_pattern = jsonencode({
    source = [
      "aws.guardduty"
    ]
    detail-type = [
      "GuardDuty Finding"
    ]
  })
  name  = "${var.name_prefix}security-guardduty-rule"
  state = "ENABLED"

  tags = var.tags
}

data "aws_iam_policy_document" "sns_topic" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.this[0].arn,
    ]
  }
}

resource "aws_sns_topic" "this" {
  count = var.is_enabled ? 1 : 0

  region            = local.region
  name              = "${var.name_prefix}security-guardduty-chatbot-slack-topic"
  kms_master_key_id = var.kms_master_key_id

  tags = var.tags
}

resource "aws_sns_topic_policy" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

#--------------------------------------------------------------
# aws_cloudwatch_event_target
# - sns
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "sns_publish" {
  count = var.is_enabled ? 1 : 0

  region    = local.region
  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = aws_sns_topic.this[0].name
  arn       = aws_sns_topic.this[0].arn
}
