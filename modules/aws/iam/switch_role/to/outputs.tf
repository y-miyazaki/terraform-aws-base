output "arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = var.is_enabled ? aws_iam_role.this[0].arn : null
}
output "name" {
  description = "Name of the role."
  value       = var.is_enabled ? aws_iam_role.this[0].name : null
}
