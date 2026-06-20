#--------------------------------------------------------------
# Module: aws/cloudwatch/events/guardduty
# Purpose: Create EventBridge rule and target for AWS GuardDuty findings.
# Notes: Static event pattern matching GuardDuty Finding; unified tagging applied; future improvement: filter by severity or detector ID via pattern.
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
  description = try(var.aws_cloudwatch_event_rule.description, "This cloudwatch event used for GuardDuty.")
  event_pattern = jsonencode({
    source = [
      "aws.guardduty"
    ]
    detail-type = [
      "GuardDuty Finding"
    ]
  })
  name  = try(var.aws_cloudwatch_event_rule.name, "security-guardduty-cloudwatch-event-rule")
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
