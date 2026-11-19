#--------------------------------------------------------------
# Module: aws/cloudwatch/events/trusted_advisor
# Purpose: Create scheduled EventBridge rule to trigger processing of AWS Trusted Advisor data.
# Notes: Uses schedule_expression (default every 5 minutes); unified tagging applied; future improvement: support event-driven refresh when available.
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

  region              = local.region
  description         = var.aws_cloudwatch_event_rule.description
  name                = var.aws_cloudwatch_event_rule.name
  schedule_expression = var.aws_cloudwatch_event_rule.schedule_expression
  state               = var.aws_cloudwatch_event_rule.state

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  arn    = var.aws_cloudwatch_event_target.arn
  rule   = aws_cloudwatch_event_rule.this[0].name

  retry_policy {
    maximum_event_age_in_seconds = var.retry_policy.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.retry_policy.maximum_retry_attempts
  }

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
