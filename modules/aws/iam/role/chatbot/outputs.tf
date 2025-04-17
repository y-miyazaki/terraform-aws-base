output "arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = awscc_iam_role.this.arn
}
output "name" {
  description = "Name of the role."
  value       = awscc_iam_role.this.name
}
