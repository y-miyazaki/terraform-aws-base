#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  region = var.region == null ? data.aws_region.current.name : var.region
}

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  name          = lookup(var.aws_cloudwatch_event_rule, "name", "trusted-advisor-cloudwatch-event-rule")
  event_pattern = <<EOF
{
  "source": [
    "aws.trustedadvisor"
  ],
  "detail-type": [
    "Trusted Advisor Check Item Refresh Notification"
  ],
  "detail": {
    "status": [
      "ERROR",
      "WARN",
      "INFO"
    ]
  }
}
EOF
  description   = lookup(var.aws_cloudwatch_event_rule, "description", "Trusted Advisor event rule.")
  role_arn      = lookup(var.aws_cloudwatch_event_rule, "role_arn")
  is_enabled    = lookup(var.aws_cloudwatch_event_rule, "is_enabled", true)
  tags          = var.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = lookup(var.aws_cloudwatch_event_target, "arn", null)
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
