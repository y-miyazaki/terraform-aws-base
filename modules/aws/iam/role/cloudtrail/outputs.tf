output "arn" {
  description = "Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.this.arn
}
output "name" {
  description = "Name of the role."
  value       = aws_iam_role.this.name
}
