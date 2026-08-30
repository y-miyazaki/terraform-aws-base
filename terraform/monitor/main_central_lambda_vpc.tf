#--------------------------------------------------------------
# VPC for Lambda
# Deployed to each monitor region (primary + global when enabled).
#--------------------------------------------------------------
data "aws_availability_zones" "available" {
  for_each = local.monitor_regions

  region = each.value
  state  = "available"
}

module "lambda_vpc" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.0"

  create_vpc = var.common_lambda.vpc.is_enabled && var.common_lambda.vpc.create_vpc
  region     = each.value

  # Basic VPC configuration
  cidr = var.common_lambda.vpc.new.cidr
  name = "${var.name_prefix}${var.common_lambda.vpc.new.name}"

  # Subnet configuration — AZs determined dynamically per region
  azs             = slice(data.aws_availability_zones.available[each.key].names, 0, min(3, length(data.aws_availability_zones.available[each.key].names)))
  private_subnets = var.common_lambda.vpc.new.private_subnets
  public_subnets  = var.common_lambda.vpc.new.public_subnets

  # DNS settings for service discovery
  enable_dns_hostnames = var.common_lambda.vpc.new.enable_dns_hostnames
  enable_dns_support   = var.common_lambda.vpc.new.enable_dns_support

  # NAT Gateway for private subnet internet access
  enable_nat_gateway     = var.common_lambda.vpc.new.enable_nat_gateway
  one_nat_gateway_per_az = var.common_lambda.vpc.new.one_nat_gateway_per_az
  single_nat_gateway     = var.common_lambda.vpc.new.single_nat_gateway

  # VPN Gateway for on-premises connectivity
  enable_vpn_gateway = var.common_lambda.vpc.new.enable_vpn_gateway

  # VPC Flow Logs for network monitoring
  create_flow_log_cloudwatch_iam_role             = var.common_lambda.vpc.new.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group            = var.common_lambda.vpc.new.create_flow_log_cloudwatch_log_group
  enable_flow_log                                 = var.common_lambda.vpc.new.enable_flow_log
  flow_log_cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  flow_log_file_format                            = var.common_lambda.vpc.new.flow_log_file_format

  # Disable default resource management
  default_security_group_egress  = []
  default_security_group_ingress = []
  manage_default_security_group  = true
  manage_default_vpc             = false

  tags = var.tags
}
