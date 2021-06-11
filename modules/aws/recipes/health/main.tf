#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count         = var.is_enabled ? 1 : 0
  name          = lookup(var.aws_cloudwatch_event_rule, "name", "health-cloudwatch-event-rule")
  event_pattern = <<EVENT_PATTERN
{
  "source": [
    "aws.health"
  ]
}
EVENT_PATTERN
  description   = lookup(var.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for Health.")
  is_enabled    = lookup(var.aws_cloudwatch_event_rule, "is_enabled", true)
  tags          = var.tags
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
