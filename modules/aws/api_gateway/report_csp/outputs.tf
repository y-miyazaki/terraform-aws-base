output "endpoint" {
  description = "Outputs the Endpoint of the API."
  value       = var.is_enabled ? format("%s%s/%s", aws_api_gateway_stage.this[0].invoke_url, aws_api_gateway_stage.this[0].stage_name, aws_api_gateway_resource.this[0].path_part) : null
}
