output "iam_role_id" {
  description = "The id of IAM role."
  value       = var.is_enabled && var.aws_iam_role != null ? aws_iam_role.this[0].id : null
}
