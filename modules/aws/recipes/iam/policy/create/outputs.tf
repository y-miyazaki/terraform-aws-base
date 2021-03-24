output "id" {
  description = "The policy's ID."
  value       = aws_iam_policy.this.id
}
output "arn" {
  description = "The ARN assigned by AWS to this policy."
  value       = aws_iam_policy.this.arn
}
output "description" {
  description = "The description of the policy."
  value       = aws_iam_policy.this.description
}
output "name" {
  description = "The name of the policy."
  value       = aws_iam_policy.this.name
}
output "path" {
  description = "The path of the policy in IAM."
  value       = aws_iam_policy.this.path
}
output "policy" {
  description = "The policy document."
  value       = aws_iam_policy.this.policy
}
