output "slack_channel_configuration_name" {
  description = "Name of the Chatbot Slack channel configuration."
  value       = aws_chatbot_slack_channel_configuration.this.configuration_name
}

output "chatbot_iam_role_arn" {
  description = "ARN of the IAM role assumed by AWS Chatbot."
  value       = aws_iam_role.this.arn
}

output "chatbot_securityhub_policy_arn" {
  description = "ARN of the custom SecurityHub IAM policy attached to the Chatbot role."
  value       = aws_iam_policy.securityhub.arn
}
