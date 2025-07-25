
#--------------------------------------------------------------
# For Default VPC
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_cloudwatch_log_group_default_vpc = merge(var.security_default_vpc.aws_cloudwatch_log_group, {
    name = "${var.name_prefix}${lookup(var.security_default_vpc.aws_cloudwatch_log_group, "name")}"
    }
  )
}
#--------------------------------------------------------------
# Provides a KMS customer master key.
#--------------------------------------------------------------
module "aws_security_default_vpc" {
  source                   = "../../modules/aws/security/default_vpc"
  is_enabled               = lookup(var.security_default_vpc, "is_enabled", true)
  is_enabled_vpc_end_point = lookup(var.security_default_vpc, "is_enabled_vpc_end_point", false)
  is_enabled_flow_logs     = lookup(var.security_default_vpc, "is_enabled_flow_logs", true)
  aws_cloudwatch_log_group = local.aws_cloudwatch_log_group_default_vpc
  aws_iam_role = {
    description = lookup(var.security_default_vpc.aws_iam_role, "description", null)
    name        = "${var.name_prefix}${lookup(var.security_default_vpc.aws_iam_role, "name")}"
    path        = lookup(var.security_default_vpc.aws_iam_role, "path", "/")
  }
  aws_iam_policy = {
    description = lookup(var.security_default_vpc.aws_iam_policy, "description", null)
    name        = "${var.name_prefix}${lookup(var.security_default_vpc.aws_iam_policy, "name")}"
    path        = lookup(var.security_default_vpc.aws_iam_policy, "path", "/")
  }
  region = var.region
  tags   = var.tags
}
