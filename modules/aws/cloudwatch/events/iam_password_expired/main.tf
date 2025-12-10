#--------------------------------------------------------------
# Module: aws/cloudwatch/events/iam_password_expired
# Purpose: Create scheduled EventBridge rule to trigger checks/notifications for IAM password expiration.
# Notes: Schedule defaults to daily at 00:00 UTC; unified tagging applied; future improvement: integrate with IAM credential report age validation.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count = var.is_enabled ? 1 : 0

  description         = try(var.aws_cloudwatch_event_rule.description, "IAM password expired event rule.")
  name                = try(var.aws_cloudwatch_event_rule.name, "iam-password-expired-cloudwatch-event-rule")
  schedule_expression = try(var.aws_cloudwatch_event_rule.schedule_expression, "cron(0 0 * * ? *)")
  state               = try(var.aws_cloudwatch_event_rule.state, "ENABLED")

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0

  rule = aws_cloudwatch_event_rule.this[0].name
  arn  = var.aws_cloudwatch_event_target.arn

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
