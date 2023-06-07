output "endpoint" {
  description = "Outputs the Endpoint of the API."
  value       = format("%s%s/%s", aws_api_gateway_deployment.this.invoke_url, aws_api_gateway_stage.this.stage_name, aws_api_gateway_resource.this.path_part)
}
