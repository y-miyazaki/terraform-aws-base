
#--------------------------------------------------------------
# For Default VPC
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_cloudwatch_log_group_default_vpc = merge(var.security_default_vpc.aws_cloudwatch_log_group, {
    name_prefix = "${var.name_prefix}${lookup(var.security_default_vpc.aws_cloudwatch_log_group, "name_prefix")}"
    }
  )
}
#--------------------------------------------------------------
# Provides a KMS customer master key.
#--------------------------------------------------------------
module "aws_recipes_security_default_vpc" {
  source                   = "../modules/aws/recipes/security/default_vpc"
  enabled                  = lookup(var.security_default_vpc, "enabled", true)
  enable_vpc_end_point     = lookup(var.security_default_vpc, "enable_vpc_end_point", false)
  enable_flow_logs         = lookup(var.security_default_vpc, "enable_flow_logs", true)
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
