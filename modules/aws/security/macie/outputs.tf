output "id" {
  description = "The ID of the Macie account"
  value       = try(aws_macie2_account.this[0].id, null)
}

output "service_role" {
  description = "The ARN of the service-linked role for Macie"
  value       = try(aws_macie2_account.this[0].service_role, null)
}

output "created_at" {
  description = "The date and time when the Macie account was created"
  value       = try(aws_macie2_account.this[0].created_at, null)
}

output "updated_at" {
  description = "The date and time of the most recent change to the Macie account status"
  value       = try(aws_macie2_account.this[0].updated_at, null)
}

output "classification_job_ids" {
  description = "Map of classification job names to their IDs"
  value       = { for k, v in aws_macie2_classification_job.this : k => v.id }
}

output "findings_filter_ids" {
  description = "Map of findings filter names to their IDs"
  value       = { for k, v in aws_macie2_findings_filter.this : k => v.id }
}

output "findings_filter_arns" {
  description = "Map of findings filter names to their ARNs"
  value       = { for k, v in aws_macie2_findings_filter.this : k => v.arn }
}
