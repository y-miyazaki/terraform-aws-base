output "sns_topic_arn" {
  value = var.is_enabled ? aws_sns_topic.this[0].arn : null
}
