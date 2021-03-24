output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = aws_sns_topic.this.arn
}
output "log_group_name" {
  description = "The Name of the Log Group"
  value       = aws_cloudwatch_log_group.this.name
}
