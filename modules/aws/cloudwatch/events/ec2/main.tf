#--------------------------------------------------------------
# Module: aws/cloudwatch/events/ec2
# Purpose: Create EventBridge rule and target for EC2 Spot interruption and rebalance recommendation events.
# Notes: Static event pattern; unified tagging applied; future improvement: parameterize detail-types and add optional SNS/Lambda targets.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/spot-interruptions.html
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/rebalance-recommendations.html
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
  description = try(var.aws_cloudwatch_event_rule.description, "This cloudwatch event used for EC2.")
  event_pattern = jsonencode({
    source = [
      "aws.ec2"
    ]
    detail-type = [
      "EC2 Instance Rebalance Recommendation",
      "EC2 Spot Instance Interruption Warning"
    ]
  })
  name  = try(var.aws_cloudwatch_event_rule.name, "ec2-cloudwatch-event-rule")
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
