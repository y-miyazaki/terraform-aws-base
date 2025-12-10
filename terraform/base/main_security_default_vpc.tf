
#--------------------------------------------------------------
# For Default VPC
#--------------------------------------------------------------

#--------------------------------------------------------------
# Check Default VPC.
#--------------------------------------------------------------
module "aws_security_default_vpc" {
  source     = "../../modules/aws/security/default_vpc"
  is_enabled = var.security_default_vpc.is_enabled

  is_enabled_vpc_end_point = try(var.security_default_vpc.is_enabled_vpc_end_point, false)
  is_enabled_flow_logs     = try(var.security_default_vpc.is_enabled_flow_logs, true)
  aws_cloudwatch_log_group = {
    name              = "${var.name_prefix}aws-vpc-flow-logs"
    kms_key_id        = module.kms_key["base"].key_arn
    retention_in_days = try(var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days, null) == null ? var.cloudwatch_log_group.retention_in_days : var.cloudwatch_log_group.override.common_lambda_vpc_flow_log.retention_in_days
  }
  aws_iam_role = {
    description = try(var.security_default_vpc.aws_iam_role.description, null)
    name        = "${var.name_prefix}${var.security_default_vpc.aws_iam_role.name}"
    path        = try(var.security_default_vpc.aws_iam_role.path, "/")
  }
  aws_iam_policy = {
    description = try(var.security_default_vpc.aws_iam_policy.description, null)
    name        = "${var.name_prefix}${var.security_default_vpc.aws_iam_policy.name}"
    path        = try(var.security_default_vpc.aws_iam_policy.path, "/")
  }
  region = var.region

  tags = var.tags
}
