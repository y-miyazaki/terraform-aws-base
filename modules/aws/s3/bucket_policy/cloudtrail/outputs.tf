output "policy_json" {
  description = "S3 bucket policy output as string."
  value       = data.aws_iam_policy_document.this.json
}
