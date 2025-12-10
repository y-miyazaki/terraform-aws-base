output "delegated_admin_account_id" {
  description = "The account ID of the delegated admin for Inspector2"
  value       = try(aws_inspector2_delegated_admin_account.this[0].account_id, null)
}

output "enabler_id" {
  description = "The ID of the Inspector2 enabler"
  value       = try(aws_inspector2_enabler.this[0].id, null)
}

output "organization_configuration_id" {
  description = "The ID of the Inspector2 organization configuration"
  value       = try(aws_inspector2_organization_configuration.this[0].id, null)
}
