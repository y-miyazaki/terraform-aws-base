#--------------------------------------------------------------
# Manages an API Gateway REST API
#--------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  description                  = var.description
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  name                         = var.name
  endpoint_configuration {
    types = var.types
  }
  tags = var.tags
}
