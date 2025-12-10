# Outputs to expose created resource ids
output "organization_configuration_id" {
  value       = length(aws_securityhub_organization_configuration.this) > 0 ? aws_securityhub_organization_configuration.this[0].id : ""
  description = "ID of Security Hub organization configuration resource (if created)"
}

output "configuration_policy_id" {
  value       = length(aws_securityhub_configuration_policy.this) > 0 ? aws_securityhub_configuration_policy.this[0].id : ""
  description = "ID of created configuration policy (if created)"
}

output "admin_account_id" {
  value       = length(aws_securityhub_organization_admin_account.this) > 0 ? aws_securityhub_organization_admin_account.this[0].id : ""
  description = "Administrator account id associated if created"
}
