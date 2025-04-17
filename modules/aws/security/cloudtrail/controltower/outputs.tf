output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = var.is_enabled ? aws_sns_topic.this[0].arn : null
}
