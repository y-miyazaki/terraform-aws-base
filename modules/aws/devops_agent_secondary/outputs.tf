output "additional_policy_name" {
  description = "Name of the additional IAM policy attached to the role (null when additional_policy_statements is empty)."
  value       = try(aws_iam_policy.additional[0].name, null)
}
output "role_arn" {
  description = "ARN of the cross-account role (null when disabled)."
  value       = try(aws_iam_role.this[0].arn, null)
}
output "role_name" {
  description = "Name of the cross-account role (null when disabled)."
  value       = try(aws_iam_role.this[0].name, null)
}
