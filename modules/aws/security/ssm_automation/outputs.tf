output "log_group_name" {
  description = "Name of the CloudWatch Log Group for SSM Automation."
  value       = var.is_enabled ? aws_cloudwatch_log_group.ssm_automation[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for SSM Automation."
  value       = var.is_enabled ? aws_cloudwatch_log_group.ssm_automation[0].arn : null
}
