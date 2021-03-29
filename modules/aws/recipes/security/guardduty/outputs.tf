output "id" {
  description = "The ID of the GuardDuty detector"
  value       = var.is_enabled ? aws_guardduty_detector.this[0].id : null
}
output "account_id" {
  description = "The AWS account ID of the GuardDuty detector"
  value       = var.is_enabled ? aws_guardduty_detector.this[0].account_id : null
}
output "arn" {
  description = "The Amazon Resource Name (ARN) of the rule"
  value       = var.is_enabled ? aws_cloudwatch_event_rule.this[0].arn : null
}
