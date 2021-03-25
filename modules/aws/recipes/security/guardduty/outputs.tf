output "id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.this.id
}
output "account_id" {
  description = "The AWS account ID of the GuardDuty detector"
  value       = aws_guardduty_detector.this.account_id
}
output "arn" {
  description = "The Amazon Resource Name (ARN) of the rule"
  value       = aws_cloudwatch_event_rule.this.arn
}
