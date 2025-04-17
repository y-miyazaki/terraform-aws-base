output "role_arn" {
  description = "The ARN assigned by AWS to this role."
  value       = var.is_enabled ? aws_iam_role.this[0].arn : null
}
