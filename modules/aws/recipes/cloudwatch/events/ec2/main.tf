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
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/spot-interruptions.html
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/rebalance-recommendations.html
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count         = var.is_enabled ? 1 : 0
  name          = lookup(var.aws_cloudwatch_event_rule, "name", "ec2-cloudwatch-event-rule")
  event_pattern = <<EVENT_PATTERN
{
  "source": [
    "aws.ec2"
  ],
  "detail-type": [
    "EC2 Instance Rebalance Recommendation",
    "EC2 Spot Instance Interruption Warning"
  ]
}
EVENT_PATTERN
  description   = lookup(var.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for EC2.")
  is_enabled    = lookup(var.aws_cloudwatch_event_rule, "is_enabled", true)
  tags          = local.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.this[0].name
  arn   = lookup(var.aws_cloudwatch_event_target, "arn", null)
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
