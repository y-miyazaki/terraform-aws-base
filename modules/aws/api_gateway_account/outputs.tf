output "cloudwatch_role_arn" {
  description = "The ARN of the IAM role used by API Gateway for CloudWatch Logs."
  value       = aws_iam_role.this.arn
}
