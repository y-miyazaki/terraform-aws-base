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
  description         = try(var.aws_cloudwatch_event_rule.description, "Trusted Advisor event rule.")
  name                = try(var.aws_cloudwatch_event_rule.name, "trusted-advisor-cloudwatch-event-rule")
  schedule_expression = try(var.aws_cloudwatch_event_rule.schedule_expression, "cron(*/5 * * * ? *)")
  state               = try(var.aws_cloudwatch_event_rule.state, "ENABLED")

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  region = local.region
  rule   = aws_cloudwatch_event_rule.this[0].name
  arn    = var.aws_cloudwatch_event_target.arn

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
