#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count               = var.is_enabled ? 1 : 0
  name                = lookup(var.aws_cloudwatch_event_rule, "name", "trusted-advisor-cloudwatch-event-rule")
  schedule_expression = lookup(var.aws_cloudwatch_event_rule, "schedule_expression", "cron(*/5 * * * ? *)")
  description         = lookup(var.aws_cloudwatch_event_rule, "description", "Trusted Advisor event rule.")
  is_enabled          = lookup(var.aws_cloudwatch_event_rule, "is_enabled", true)
  tags                = var.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.this[0].name
  arn   = lookup(var.aws_cloudwatch_event_target, "arn")
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
