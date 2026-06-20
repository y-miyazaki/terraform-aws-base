#--------------------------------------------------------------
# Module: aws/api_gateway/report_csp
# Purpose: Expose a POST /report-csp endpoint via API Gateway integrated with a Lambda to send CSP violation reports to Slack.
# Notes: Adds deployment and stage with optional access logs; tagging to be unified via future refactor (currently passed through); future improvement: enable access logging and WAF association.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Provides an API Gateway Resource.
#--------------------------------------------------------------
resource "aws_api_gateway_resource" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  rest_api_id = var.aws_api_gateway_rest_api_id
  parent_id   = var.aws_api_gateway_rest_api_root_resource_id
  path_part   = "report-csp"
}

#--------------------------------------------------------------
# Provides a HTTP Method for an API Gateway Resource.
#--------------------------------------------------------------
resource "aws_api_gateway_method" "this" {
  count = var.is_enabled ? 1 : 0

  region        = local.region
  rest_api_id   = var.aws_api_gateway_rest_api_id
  resource_id   = aws_api_gateway_resource.this[0].id
  http_method   = "POST"
  authorization = "NONE"
}

#--------------------------------------------------------------
# Manages an API Gateway REST Deployment.
# A deployment is a snapshot of the REST API configuration.
# The deployment can then be published to callable endpoints via the aws_api_gateway_stage
# resource and optionally managed further with the aws_api_gateway_base_path_mapping resource,
# aws_api_gateway_domain_name resource, and aws_api_method_settings resource.
# For more information, see the API Gateway Developer Guide.
#--------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  count = var.is_enabled ? 1 : 0

  region      = local.region
  rest_api_id = var.aws_api_gateway_rest_api_id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this[0].id,
      aws_api_gateway_method.this[0].id,
      aws_api_gateway_integration.this[0].id,
      aws_api_gateway_integration.this[0].uri,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Manages an API Gateway Stage.
# A stage is a named reference to a deployment, which can be done via
# the aws_api_gateway_deployment resource. Stages can be optionally managed further
# with the aws_api_gateway_base_path_mapping resource, aws_api_gateway_domain_name resource,
# and aws_api_method_settings resource. For more information, see the API Gateway Developer Guide.
#--------------------------------------------------------------
# tfsec:ignore:aws-api-gateway-enable-access-logging
resource "aws_api_gateway_stage" "this" {
  count = var.is_enabled ? 1 : 0

  region        = local.region
  deployment_id = aws_api_gateway_deployment.this[0].id
  rest_api_id   = var.aws_api_gateway_rest_api_id
  stage_name    = "base"
  dynamic "access_log_settings" {
    for_each = length(keys(var.access_log_settings)) == 0 ? [] : [var.access_log_settings]

    content {
      destination_arn = try(access_log_settings.value.destination_arn, null)
      format          = try(access_log_settings.value.format, null)
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function
# For CSP report handler
#--------------------------------------------------------------
module "aws_lambda_create_lambda_report_csp" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.8.0"

  create = var.is_enabled
  region = local.region

  allowed_triggers = var.is_enabled ? {
    trigger = {
      action              = "lambda:InvokeFunction"
      event_source_token  = null
      principal           = "apigateway.amazonaws.com"
      qualifier           = null
      source_account      = null
      source_arn          = "${var.aws_api_gateway_rest_api_execution_arn}/*/*"
      statement_id        = "APIGatewayInvokeReportCSP"
      statement_id_prefix = null
    }
  } : {}
  architectures                           = ["arm64"]
  attach_network_policy                   = length(var.vpc_config) > 0
  cloudwatch_logs_kms_key_id              = try(var.lambda_function_aws_cloudwatch_log_group.kms_key_id, null)
  cloudwatch_logs_retention_in_days       = try(var.lambda_function_aws_cloudwatch_log_group.retention_in_days, null)
  create_current_version_allowed_triggers = false
  create_package                          = false
  create_role                             = false
  description                             = "This program sends the result of report csp to Slack."
  environment_variables                   = var.lambda_function_environment
  function_name                           = "${var.name_prefix}report-csp"
  handler                                 = "report_csp"
  lambda_role                             = var.role_arn
  layers                                  = []
  local_existing_package                  = "${path.module}/../../../../lambda/outputs/api/go_report_csp.zip"
  logging_application_log_level           = "WARN"
  logging_log_format                      = "JSON"
  logging_system_log_level                = "WARN"
  memory_size                             = 128
  publish                                 = false
  runtime                                 = "provided.al2023"
  timeout                                 = 300
  tracing_mode                            = "PassThrough"
  vpc_security_group_ids                  = length(var.vpc_config) > 0 ? try(var.vpc_config[0]["security_group_ids"], []) : []
  vpc_subnet_ids                          = length(var.vpc_config) > 0 ? try(var.vpc_config[0]["subnet_ids"], []) : []

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an HTTP Method Integration for an API Gateway Integration.
#--------------------------------------------------------------
resource "aws_api_gateway_integration" "this" {
  count = var.is_enabled ? 1 : 0

  region                  = local.region
  rest_api_id             = var.aws_api_gateway_rest_api_id
  resource_id             = aws_api_gateway_method.this[0].resource_id
  http_method             = aws_api_gateway_method.this[0].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.aws_lambda_create_lambda_report_csp.lambda_function_invoke_arn
}
