#--------------------------------------------------------------
# VPC Endpoint
#--------------------------------------------------------------
locals {
}
#--------------------------------------------------------------
# VPC for Lambda
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#--------------------------------------------------------------
module "lambda_vpc" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "3.14.0"
  create_vpc = var.common_lambda.vpc.is_enabled

  name = "${var.name_prefix}${var.common_lambda.vpc.name}"
  cidr = var.common_lambda.vpc.cidr

  # Network
  azs             = var.common_lambda.vpc.azs
  private_subnets = var.common_lambda.vpc.private_subnets
  public_subnets  = var.common_lambda.vpc.public_subnets

  enable_dns_hostnames = var.common_lambda.vpc.enable_dns_hostnames
  enable_dns_support   = var.common_lambda.vpc.enable_dns_support

  # NAT Gateway
  enable_nat_gateway     = var.common_lambda.vpc.enable_nat_gateway
  single_nat_gateway     = var.common_lambda.vpc.single_nat_gateway
  one_nat_gateway_per_az = var.common_lambda.vpc.one_nat_gateway_per_az

  # VPN Gateway
  enable_vpn_gateway = var.common_lambda.vpc.enable_vpn_gateway

  # Flow Log
  enable_flow_log                                 = var.common_lambda.vpc.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.common_lambda.vpc.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role             = var.common_lambda.vpc.create_flow_log_cloudwatch_iam_role
  flow_log_cloudwatch_log_group_retention_in_days = var.common_lambda.vpc.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_file_format                            = var.common_lambda.vpc.flow_log_file_format

  tags = var.tags
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
output "lambda_vpc_id" {
  value = module.lambda_vpc.vpc_id
}
