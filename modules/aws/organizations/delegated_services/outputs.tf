#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "service_principals" {
  value       = try(jsondecode(data.external.delegated_services.result.principals), [])
  description = "List of delegated service principal strings for the account."
}
