#--------------------------------------------------------------
# Provides an API Gateway Resource.
#--------------------------------------------------------------
resource "aws_api_gateway_resource" "this" {
  rest_api_id = var.aws_api_gateway_rest_api_id
  parent_id   = var.aws_api_gateway_rest_api_root_resource_id
  path_part   = "report-csp"
}

#--------------------------------------------------------------
# Provides a HTTP Method for an API Gateway Resource.
#--------------------------------------------------------------
resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.aws_api_gateway_rest_api_id
  resource_id   = aws_api_gateway_resource.this.id
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
  rest_api_id = var.aws_api_gateway_rest_api_id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this.id,
      aws_api_gateway_method.this.id,
      aws_api_gateway_integration.this.id,
      aws_api_gateway_integration.this.uri,
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
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = var.aws_api_gateway_rest_api_id
  stage_name    = "base"
  dynamic "access_log_settings" {
    for_each = length(keys(var.access_log_settings)) == 0 ? [] : [var.access_log_settings]
    content {
      destination_arn = lookup(access_log_settings.value, "destination_arn", null)
      format          = lookup(access_log_settings.value, "format", null)
    }
  }
}

#--------------------------------------------------------------
# Create Lambda function
# For Log
#--------------------------------------------------------------
module "lambda_create_lambda_report_csp" {
  source                   = "../../lambda/create"
  aws_cloudwatch_log_group = var.lambda_function_aws_cloudwatch_log_group

  # Provides a Lambda Function resource.
  # Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
  aws_lambda_function = {
    filename                       = "${path.module}/../../../../../lambda/outputs/api/report_csp.zip"
    s3_bucket                      = null
    s3_key                         = null
    s3_object_version              = null
    function_name                  = "${var.name_prefix}report-csp"
    dead_letter_config             = []
    handler                        = "report_csp"
    role                           = var.role_arn
    description                    = "This program sends the result of report csp to Slack."
    layers                         = []
    memory_size                    = 128
    runtime                        = "go1.x"
    timeout                        = 300
    reserved_concurrent_executions = null
    publish                        = false
    kms_key_arn                    = null
    source_code_hash               = filebase64sha256("${path.module}/../../../../../lambda/outputs/api/report_csp.zip")
    environment                    = var.lambda_function_environment
    vpc_config                     = var.vpc_config
  }
  # Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Eventss Rule, SNS or S3).
  tags = var.tags
}
#--------------------------------------------------------------
# Create Lambda Permission
# For Log
#--------------------------------------------------------------
module "lambda_permission_lambda_report_csp" {
  source     = "../../lambda/permission"
  is_enabled = true
  aws_lambda_permission = {
    action              = "lambda:InvokeFunction"
    event_source_token  = null
    function_name       = module.lambda_create_lambda_report_csp.function_name
    principal           = "apigateway.amazonaws.com"
    qualifier           = null
    source_account      = null
    source_arn          = "${var.aws_api_gateway_rest_api_execution_arn}/*/*"
    statement_id        = "APIGatewayInvokeReportCSP"
    statement_id_prefix = null
  }
  depends_on = [
    aws_api_gateway_deployment.this,
    aws_api_gateway_stage.this,
  ]
}

#--------------------------------------------------------------
# Provides an HTTP Method Integration for an API Gateway Integration.
#--------------------------------------------------------------
resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.aws_api_gateway_rest_api_id
  resource_id             = aws_api_gateway_method.this.resource_id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_create_lambda_report_csp.invoke_arn
}
