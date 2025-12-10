output "admin_account_id" {
  description = "The account ID of the GuardDuty organization admin account"
  value       = try(aws_guardduty_organization_admin_account.this[0].admin_account_id, null)
}

output "detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = try(data.aws_guardduty_detector.existing[0].id, null)
}

output "organization_configuration_id" {
  description = "The ID of the GuardDuty organization configuration"
  value       = try(aws_guardduty_organization_configuration.this[0].id, null)
}

output "organization_configuration_feature_ids" {
  description = "The IDs of the GuardDuty organization configuration features"
  value       = try([for feature in aws_guardduty_organization_configuration_feature.this : feature.id], [])
}
