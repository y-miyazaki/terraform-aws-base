output "policy_json" {
  description = "S3 bucket policy output as string."
  value       = length(local.resource_config) > 0 ? data.aws_iam_policy_document.this[0].json : null
}
