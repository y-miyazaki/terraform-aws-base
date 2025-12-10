output "arn" {
  description = "The ARN assigned by AWS for this resource group."
  value       = var.is_enabled ? aws_resourcegroups_group.this[0].arn : null
}
