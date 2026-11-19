output "sns_topic_arn" {
  description = "The ARN of the SNS topic that Chatbot subscribes to. Null when the module is disabled."
  value       = var.is_enabled ? aws_sns_topic.this[0].arn : null
}
