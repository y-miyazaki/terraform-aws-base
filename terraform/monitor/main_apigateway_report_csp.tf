#--------------------------------------------------------------
# For API Gateway
#--------------------------------------------------------------
module "aws_api_gateway_create" {
  count                        = var.report_csp.is_enabled ? 1 : 0
  source                       = "../../modules/aws/api_gateway/create"
  description                  = "This API is used for purposes such as reporting to the infrastructure."
  disable_execute_api_endpoint = false
  name                         = format("%s%s", var.name_prefix, "api")
}

#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_api_gateway_report_csp" {
  count                                     = var.report_csp.is_enabled ? 1 : 0
  source                                    = "../../modules/aws/api_gateway/report_csp"
  name_prefix                               = var.name_prefix
  role_arn                                  = module.aws_iam_role_lambda.arn
  aws_api_gateway_rest_api_id               = module.aws_api_gateway_create[0].id
  aws_api_gateway_rest_api_root_resource_id = module.aws_api_gateway_create[0].root_resource_id
  aws_api_gateway_rest_api_execution_arn    = module.aws_api_gateway_create[0].execution_arn
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
  lambda_function_environment = var.report_csp.aws_lambda_function.environment
  tags                        = var.tags
}

output "report_csp_endpoint" {
  description = "Endpoint to report CSP. method is POST."
  value       = var.report_csp.is_enabled ? module.aws_api_gateway_report_csp[0].endpoint : null
}
