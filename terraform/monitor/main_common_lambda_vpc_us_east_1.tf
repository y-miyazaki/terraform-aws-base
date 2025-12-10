#--------------------------------------------------------------
# VPC for Lambda (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Creates a dedicated VPC in us-east-1 region for Lambda functions that
# need to operate in this specific region. This is particularly important
# for Lambda functions monitoring global AWS Health events or services
# that are region-specific to us-east-1.
#
# Features:
# - Private and public subnets across us-east-1 availability zones
# - NAT Gateway for outbound internet access from private subnets
# - VPC Flow Logs for network traffic monitoring
# - DNS support for internal service discovery
#
# This VPC is only created when:
# - var.common_lambda.vpc.is_enabled = true
# - var.common_lambda.vpc.create_vpc = true
# - Default region is NOT us-east-1 (to avoid duplication with main_common_lambda_vpc.tf)
#
# If default region is us-east-1, Lambda functions should use the VPC from
# main_common_lambda_vpc.tf instead of creating a duplicate.
#
# Reference:
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#--------------------------------------------------------------
module "lambda_vpc_us_east_1" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "6.5.1"
  create_vpc = !local.is_default_region_us_east_1 && var.common_lambda.vpc.is_enabled && var.common_lambda.vpc.create_vpc
  providers = {
    aws = aws.us-east-1
  }

  # Basic VPC configuration
  name = "${var.name_prefix}${var.common_lambda.vpc.new.name}"
  cidr = var.common_lambda.vpc.new.cidr

  # Subnet configuration across us-east-1 availability zones
  azs             = var.common_lambda.vpc.new.azs_us_east_1
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
  flow_log_cloudwatch_log_group_retention_in_days = try(var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days, null) != null ? var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days : var.cloudwatch_log_group.retention_in_days
  flow_log_file_format                            = var.common_lambda.vpc.new.flow_log_file_format

  # Disable default resource management
  manage_default_vpc            = false
  manage_default_security_group = false

  tags = var.tags
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
# Exports us-east-1 VPC resource IDs for use by Lambda function modules.
# These outputs are referenced by Lambda configurations that require
# VPC connectivity in the us-east-1 region.
#--------------------------------------------------------------

# VPC ID for Lambda functions in us-east-1
output "lambda_vpc_id_us_east_1" {
  description = "The ID of the VPC created for Lambda functions in us-east-1"
  value       = module.lambda_vpc_us_east_1.vpc_id
}

# Private subnet IDs for Lambda execution in us-east-1
output "lambda_vpc_private_subnet_us_east_1" {
  description = "List of private subnet IDs where Lambda functions will be deployed in us-east-1"
  value       = module.lambda_vpc_us_east_1.private_subnets
}

# Default security group for Lambda VPC in us-east-1
output "lambda_vpc_default_security_group_id_us_east_1" {
  description = "The ID of the default security group for Lambda VPC in us-east-1"
  value       = module.lambda_vpc_us_east_1.default_security_group_id
}
