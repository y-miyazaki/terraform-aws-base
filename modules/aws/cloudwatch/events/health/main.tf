#--------------------------------------------------------------
# Module: aws/cloudwatch/events/health
# Purpose: Create EventBridge rule and target for AWS Health events.
# Notes: Broad event pattern (all aws.health events); unified tagging applied; future improvement: allow filtering by eventTypeCategory.
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
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  description = var.aws_cloudwatch_event_rule.description
  event_pattern = jsonencode({
    source = [
      "aws.health"
    ]
  })
  name  = try(var.aws_cloudwatch_event_rule.name, "health-cloudwatch-event-rule")
  state = var.aws_cloudwatch_event_rule.state

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  arn    = try(var.aws_cloudwatch_event_target.arn, null)
  rule   = aws_cloudwatch_event_rule.this[0].name

  retry_policy {
    maximum_event_age_in_seconds = var.retry_policy.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.retry_policy.maximum_retry_attempts
  }

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
