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
  description = try(var.aws_cloudwatch_event_rule.description, "This cloudwatch event used for Health.")
  event_pattern = jsonencode({
    source = [
      "aws.health"
    ]
  })
  name  = try(var.aws_cloudwatch_event_rule.name, "health-cloudwatch-event-rule")
  state = try(var.aws_cloudwatch_event_rule.state, "ENABLED")

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  rule   = aws_cloudwatch_event_rule.this[0].name
  arn    = try(var.aws_cloudwatch_event_target.arn, null)

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
