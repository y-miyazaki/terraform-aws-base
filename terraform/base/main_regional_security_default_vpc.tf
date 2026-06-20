#--------------------------------------------------------------
# Regional deployment of AWS Default VPC monitoring
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to monitor default VPC security configuration across regions.

module "aws_security_default_vpc" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/default_vpc"

  is_enabled = try(var.security_default_vpc.is_enabled, true)
  region     = each.value

  aws_cloudwatch_log_group = try(
    {
      name              = "${var.name_prefix}aws-vpc-flow-logs-${each.value}"
      kms_key_id        = try(module.kms_key[each.value].key_arn, null)
      retention_in_days = try(var.security_default_vpc.retention_in_days, 7)
    },
    {}
  )
  aws_iam_policy = try(
    {
      description = try(var.security_default_vpc.aws_iam_policy.description, "VPC Flow Logs policy")
      name        = "${var.name_prefix}vpc-flow-logs-${each.value}"
      path        = "/"
    },
    {}
  )
  aws_iam_role = try(
    {
      description = try(var.security_default_vpc.aws_iam_role.description, "VPC Flow Logs role")
      name        = "${var.name_prefix}vpc-flow-logs-${each.value}"
      path        = "/"
    },
    {}
  )
  is_enabled_flow_logs     = try(var.security_default_vpc.is_enabled_flow_logs, true)
  is_enabled_vpc_end_point = try(var.security_default_vpc.is_enabled_vpc_end_point, false)
  tags                     = var.tags
}
