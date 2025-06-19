#--------------------------------------------------------------
# VPC for Lambda
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#--------------------------------------------------------------
module "lambda_vpc" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "6.0.0"
  create_vpc = var.common_lambda.vpc.is_enabled && var.common_lambda.vpc.create_vpc

  name = "${var.name_prefix}${var.common_lambda.vpc.new.name}"
  cidr = var.common_lambda.vpc.new.cidr

  # Network
  azs             = var.common_lambda.vpc.new.azs
  private_subnets = var.common_lambda.vpc.new.private_subnets
  public_subnets  = var.common_lambda.vpc.new.public_subnets

  enable_dns_hostnames = var.common_lambda.vpc.new.enable_dns_hostnames
  enable_dns_support   = var.common_lambda.vpc.new.enable_dns_support

  # NAT Gateway
  enable_nat_gateway     = var.common_lambda.vpc.new.enable_nat_gateway
  single_nat_gateway     = var.common_lambda.vpc.new.single_nat_gateway
  one_nat_gateway_per_az = var.common_lambda.vpc.new.one_nat_gateway_per_az

  # VPN Gateway
  enable_vpn_gateway = var.common_lambda.vpc.new.enable_vpn_gateway

  # Flow Log
  enable_flow_log                                 = var.common_lambda.vpc.new.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.common_lambda.vpc.new.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role             = var.common_lambda.vpc.new.create_flow_log_cloudwatch_iam_role
  flow_log_cloudwatch_log_group_retention_in_days = var.common_lambda.vpc.new.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_file_format                            = var.common_lambda.vpc.new.flow_log_file_format

  manage_default_vpc            = false
  manage_default_security_group = false

  tags = var.tags
}
#--------------------------------------------------------------
# VPC for Lambda(us-east-1)
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#--------------------------------------------------------------
module "lambda_vpc_us_east_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"
  providers = {
    aws = aws.us-east-1
  }
  create_vpc = var.common_lambda.vpc.is_enabled && var.common_lambda.vpc.create_vpc

  name = "${var.name_prefix}${var.common_lambda.vpc.new.name}"
  cidr = var.common_lambda.vpc.new.cidr

  # Network
  azs             = var.common_lambda.vpc.new.azs_us_east_1
  private_subnets = var.common_lambda.vpc.new.private_subnets
  public_subnets  = var.common_lambda.vpc.new.public_subnets

  enable_dns_hostnames = var.common_lambda.vpc.new.enable_dns_hostnames
  enable_dns_support   = var.common_lambda.vpc.new.enable_dns_support

  # NAT Gateway
  enable_nat_gateway     = var.common_lambda.vpc.new.enable_nat_gateway
  single_nat_gateway     = var.common_lambda.vpc.new.single_nat_gateway
  one_nat_gateway_per_az = var.common_lambda.vpc.new.one_nat_gateway_per_az

  # VPN Gateway
  enable_vpn_gateway = var.common_lambda.vpc.new.enable_vpn_gateway

  # Flow Log
  enable_flow_log                                 = var.common_lambda.vpc.new.enable_flow_log
  create_flow_log_cloudwatch_log_group            = var.common_lambda.vpc.new.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role             = var.common_lambda.vpc.new.create_flow_log_cloudwatch_iam_role
  flow_log_cloudwatch_log_group_retention_in_days = var.common_lambda.vpc.new.flow_log_cloudwatch_log_group_retention_in_days
  flow_log_file_format                            = var.common_lambda.vpc.new.flow_log_file_format

  manage_default_vpc            = false
  manage_default_security_group = false

  tags = var.tags
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
output "lambda_vpc_id" {
  value = module.lambda_vpc.vpc_id
}
output "lambda_vpc_private_subnet" {
  value = module.lambda_vpc.private_subnets
}
output "lambda_vpc_default_security_group_id" {
  value = module.lambda_vpc.default_security_group_id
}
output "lambda_vpc_id_us_east_1" {
  value = module.lambda_vpc_us_east_1.vpc_id
}
output "lambda_vpc_private_subnet_us_east_1" {
  value = module.lambda_vpc_us_east_1.private_subnets
}
output "lambda_vpc_default_security_group_id_us_east_1" {
  value = module.lambda_vpc_us_east_1.default_security_group_id
}
