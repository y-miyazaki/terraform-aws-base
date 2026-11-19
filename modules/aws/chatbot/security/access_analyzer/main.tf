#--------------------------------------------------------------
# Module: aws/chatbot/security/access_analyzer
# Purpose: Create EventBridge rule and SNS topic to forward IAM Access Analyzer external access findings to Slack via AWS Chatbot.
# Notes: Only active external access findings are forwarded (error, deleted and non-ACTIVE findings are ignored). The event is reshaped into a
#        Chatbot custom notification because the raw event is not rendered in a readable form. Deploy once per region that has an analyzer.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
# https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-eventbridge.html
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  description = "This cloudwatch event used for IAM Access Analyzer external access findings."
  event_pattern = jsonencode({
    detail = {
      error     = [{ exists = false }]
      isDeleted = [false]
      status    = ["ACTIVE"]
    }
    detail-type = [
      "Access Analyzer Finding"
    ]
    source = [
      "aws.access-analyzer"
    ]
  })
  name  = "${var.name_prefix}security-access-analyzer-rule"
  state = "ENABLED"

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an SNS topic resource and its policy.
#--------------------------------------------------------------
resource "aws_sns_topic" "this" {
  count = var.is_enabled ? 1 : 0

  region            = local.region
  kms_master_key_id = var.kms_master_key_id
  name              = "${var.name_prefix}security-access-analyzer-chatbot-slack-topic"

  tags = var.tags
}

data "aws_iam_policy_document" "sns_topic" {
  count = var.is_enabled ? 1 : 0

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

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.this[0].arn]
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.sns_topic[0].json
}

#--------------------------------------------------------------
# aws_cloudwatch_event_target
# - sns (reshaped into a Chatbot custom notification)
# https://docs.aws.amazon.com/chatbot/latest/adminguide/custom-notifs.html
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "sns_publish" {
  count = var.is_enabled ? 1 : 0

  region    = local.region
  arn       = aws_sns_topic.this[0].arn
  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = aws_sns_topic.this[0].name

  input_transformer {
    input_paths = {
      account_id    = "$.detail.accountId"
      finding_id    = "$.detail.id"
      is_public     = "$.detail.isPublic"
      region        = "$.detail.region"
      resource      = "$.detail.resource"
      resource_type = "$.detail.resourceType"
    }
    # The template is plain text on purpose: jsonencode() would escape the angle brackets of the placeholders.
    # The placeholders are substituted without JSON escaping. This is accepted because the analyzed resources (S3 buckets, IAM roles,
    # KMS keys, Lambda functions, SQS queues, Secrets Manager secrets, ...) have identifiers whose allowed characters exclude
    # double quotes and backslashes. Do not add free-text fields (for example condition values) to the template.
    input_template = <<-EOT
      {
        "version": "1.0",
        "source": "custom",
        "id": "<finding_id>",
        "content": {
          "textType": "client-markdown",
          "title": ":warning: IAM Access Analyzer: external access finding",
          "description": "*Resource:* <resource>\n*Type:* <resource_type>\n*Account:* <account_id>\n*Region:* <region>\n*Public:* <is_public>",
          "nextSteps": [
            "Open IAM Access Analyzer in the audit account and review the finding <finding_id>.",
            "If the access is intended, archive the finding; otherwise remove the external access."
          ],
          "keywords": ["AccessAnalyzer", "ExternalAccess"]
        }
      }
    EOT
  }

  retry_policy {
    maximum_event_age_in_seconds = var.retry_policy.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.retry_policy.maximum_retry_attempts
  }
}
