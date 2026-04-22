#--------------------------------------------------------------
# For Default VPC (us-east-1)
#--------------------------------------------------------------

#--------------------------------------------------------------
# Check Default VPC in us-east-1.
#--------------------------------------------------------------
module "aws_security_default_vpc_us_east_1" {
  source     = "../../modules/aws/security/default_vpc"
  is_enabled = local.is_enabled_us_east_1 && var.security_default_vpc.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  is_enabled_vpc_end_point = try(var.security_default_vpc.is_enabled_vpc_end_point, false)
  is_enabled_flow_logs     = try(var.security_default_vpc.is_enabled_flow_logs, true)
  aws_cloudwatch_log_group = {
    name              = "${var.name_prefix}aws-vpc-flow-logs-us-east-1"
    kms_key_id        = module.kms_key_us_east_1["base"].key_arn
    retention_in_days = coalesce(try(var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  }
  aws_iam_role = {
    description = try(var.security_default_vpc.aws_iam_role.description, null)
    name        = "${var.name_prefix}${var.security_default_vpc.aws_iam_role.name}-us-east-1"
    path        = try(var.security_default_vpc.aws_iam_role.path, "/")
  }
  aws_iam_policy = {
    description = try(var.security_default_vpc.aws_iam_policy.description, null)
    name        = "${var.name_prefix}${var.security_default_vpc.aws_iam_policy.name}-us-east-1"
    path        = try(var.security_default_vpc.aws_iam_policy.path, "/")
  }
  region = "us-east-1"

  tags = var.tags
}
