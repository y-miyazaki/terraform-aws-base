#--------------------------------------------------------------
# For API Gateway
#--------------------------------------------------------------
module "aws_api_gateway_create" {
  source     = "../../modules/aws/api_gateway/create"
  is_enabled = var.report_csp.is_enabled

  description                  = "This API is used for purposes such as reporting to the infrastructure."
  disable_execute_api_endpoint = false
  name                         = format("%s%s", var.name_prefix, "api")
}

#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_api_gateway_report_csp" {
  source     = "../../modules/aws/api_gateway/report_csp"
  is_enabled = var.report_csp.is_enabled

  name_prefix                               = var.name_prefix
  role_arn                                  = module.aws_iam_role_lambda.arn
  aws_api_gateway_rest_api_id               = var.report_csp.is_enabled ? module.aws_api_gateway_create.id : ""
  aws_api_gateway_rest_api_root_resource_id = var.report_csp.is_enabled ? module.aws_api_gateway_create.root_resource_id : ""
  aws_api_gateway_rest_api_execution_arn    = var.report_csp.is_enabled ? module.aws_api_gateway_create.execution_arn : ""
  vpc_config = var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [
    {
      subnet_ids         = module.lambda_vpc.private_subnets
      security_group_ids = [module.lambda_vpc.default_security_group_id]
    }
    ] : [
    {
      subnet_ids         = var.common_lambda.vpc.exists.private_subnets
      security_group_ids = [var.common_lambda.vpc.exists.security_group_id]
    }
  ] : []
  lambda_function_environment = {
    LOGGER_FORMATTER = "json"
    LOGGER_OUT       = "stdout"
    LOGGER_LEVEL     = "warn"
    # Override SLACK_* with priority: override > defaults
    SLACK_OAUTH_ACCESS_TOKEN = try(var.slack.override.apigateway_report_csp.oauth_access_token, null) != null ? var.slack.override.apigateway_report_csp.oauth_access_token : var.slack.oauth_access_token
    SLACK_CHANNEL_ID         = try(var.slack.override.apigateway_report_csp.channel_id, null) != null ? var.slack.override.apigateway_report_csp.channel_id : var.slack.channel_id
  }

  tags = var.tags
}

output "report_csp_endpoint" {
  description = "Endpoint to report CSP. method is POST."
  value       = module.aws_api_gateway_report_csp.endpoint
}
