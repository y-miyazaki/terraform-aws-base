#--------------------------------------------------------------
# VPC for Lambda
#--------------------------------------------------------------
#--------------------------------------------------------------
# Creates a dedicated VPC for Lambda functions when VPC-enabled Lambda
# execution is required. This VPC provides network isolation and enables
# Lambda functions to access resources in private subnets.
#
# Features:
# - Private and public subnets across multiple availability zones
# - NAT Gateway for outbound internet access from private subnets
# - VPC Flow Logs for network traffic monitoring
# - DNS support for internal service discovery
#
# This VPC is only created when:
# - var.common_lambda.vpc.is_enabled = true
# - var.common_lambda.vpc.create_vpc = true
#
# Reference:
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#--------------------------------------------------------------
module "lambda_vpc" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "6.6.1"
  create_vpc = var.common_lambda.vpc.is_enabled && var.common_lambda.vpc.create_vpc

  # Basic VPC configuration
  name = "${var.name_prefix}${var.common_lambda.vpc.new.name}"
  cidr = var.common_lambda.vpc.new.cidr

  # Subnet configuration across availability zones
  azs             = var.common_lambda.vpc.new.azs
  private_subnets = var.common_lambda.vpc.new.private_subnets
  public_subnets  = var.common_lambda.vpc.new.public_subnets

  # DNS settings for service discovery
  enable_dns_hostnames = var.common_lambda.vpc.new.enable_dns_hostnames
  enable_dns_support   = var.common_lambda.vpc.new.enable_dns_support

  # NAT Gateway for private subnet internet access
  enable_nat_gateway     = var.common_lambda.vpc.new.enable_nat_gateway
  single_nat_gateway     = var.common_lambda.vpc.new.single_nat_gateway
  one_nat_gateway_per_az = var.common_lambda.vpc.new.one_nat_gateway_per_az

  # VPN Gateway for on-premises connectivity
  enable_vpn_gateway = var.common_lambda.vpc.new.enable_vpn_gateway

  # VPC Flow Logs for network monitoring
  enable_flow_log                                 = var.common_lambda.vpc.new.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.common_lambda.vpc.new.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role             = var.common_lambda.vpc.new.create_flow_log_cloudwatch_iam_role
  flow_log_cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  flow_log_file_format                            = var.common_lambda.vpc.new.flow_log_file_format

  # Disable default resource management
  manage_default_vpc             = false
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = var.tags
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
# Exports VPC resource IDs for use by Lambda function modules.
# These outputs are referenced by Lambda configurations that require
# VPC connectivity.
#--------------------------------------------------------------

# VPC ID for Lambda functions
output "lambda_vpc_id" {
  description = "The ID of the VPC created for Lambda functions"
  value       = module.lambda_vpc.vpc_id
}

# Private subnet IDs for Lambda execution
output "lambda_vpc_private_subnet" {
  description = "List of private subnet IDs where Lambda functions will be deployed"
  value       = module.lambda_vpc.private_subnets
}

# Default security group for Lambda VPC
output "lambda_vpc_default_security_group_id" {
  description = "The ID of the default security group for Lambda VPC"
  value       = module.lambda_vpc.default_security_group_id
}
