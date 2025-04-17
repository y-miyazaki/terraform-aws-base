output "id" {
  description = "ID of the REST API."
  value       = aws_api_gateway_rest_api.this.id
}
output "root_resource_id" {
  description = "Resource ID of the REST API's root."
  value       = aws_api_gateway_rest_api.this.root_resource_id
}
output "execution_arn" {
  description = "Execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function."
  value       = aws_api_gateway_rest_api.this.execution_arn
}
