output "id" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.id
}
output "arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = aws_sns_topic.this.arn
}
