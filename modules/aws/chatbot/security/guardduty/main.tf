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
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count         = var.is_enabled ? 1 : 0
  name          = "${var.name_prefix}security-guarduty-rule"
  event_pattern = <<EVENT_PATTERN
  {
    "source": [
      "aws.guardduty"
    ],
    "detail-type": [
      "GuardDuty Finding"
    ]
  }
EVENT_PATTERN
  description   = "This cloudwatch event used for GuardDuty."
  state         = "ENABLED"
  tags          = local.tags
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
  count             = var.is_enabled ? 1 : 0
  name              = "${var.name_prefix}security-guardduty-chatbot-slack-topic"
  kms_master_key_id = var.kms_master_key_id
  tags              = local.tags
}

resource "aws_sns_topic_policy" "this" {
  count  = var.is_enabled ? 1 : 0
  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

#--------------------------------------------------------------
# aws_cloudwatch_event_target
# - sns
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "sns_publish" {
  count     = var.is_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = aws_sns_topic.this[0].name
  arn       = aws_sns_topic.this[0].arn
}
