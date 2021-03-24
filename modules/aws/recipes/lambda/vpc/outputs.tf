output "securty_group_id" {
  description = "The ID of the security group"
  value       = module.lambda_vpc_security_group.id
}
output "role_name" {
  description = "The name of the role."
  value       = aws_iam_role.this.name
}
output "role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role."
  value       = aws_iam_role.this.arn
}
output "role_id" {
  description = "The name of the role."
  value       = aws_iam_role.this.id
}
