#--------------------------------------------------------------
# Module: aws/api_gateway/create
# Purpose: Create an API Gateway REST API with configurable endpoint types and execution endpoint toggle.
# Notes: Converted direct tag usage to unified local tagging pattern; future improvement: add logging and endpoint policy options.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages an API Gateway REST API
#--------------------------------------------------------------
resource "aws_api_gateway_rest_api" "this" {
  count = var.is_enabled ? 1 : 0

  description                  = var.description
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  name                         = var.name
  endpoint_configuration {
    types = var.types
  }

  tags = var.tags
}
