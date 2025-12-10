output "id" {
  description = "ID of the REST API."
  value       = var.is_enabled ? aws_api_gateway_rest_api.this[0].id : null
}
output "root_resource_id" {
  description = "Resource ID of the REST API's root."
  value       = var.is_enabled ? aws_api_gateway_rest_api.this[0].root_resource_id : null
}
output "execution_arn" {
  description = "Execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function."
  value       = var.is_enabled ? aws_api_gateway_rest_api.this[0].execution_arn : null
}
