#--------------------------------------------------------------
# Regional deployment of SSM Automation
#--------------------------------------------------------------
# SSM.6 and SSM.7 compliance settings for AWS Systems Manager Automation.
# Enables CloudWatch logging for SSM Automation to meet SSM.6 control requirements.
# Disables public sharing of SSM Automation documents to comply with SSM.7 control.
#--------------------------------------------------------------
module "aws_security_ssm_automation" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/ssm_automation"

  is_enabled = try(var.security_ssm_automation.is_enabled, true)
  region     = each.value

  cloudwatch_log_group_name              = try(var.security_ssm_automation.cloudwatch_log_group_name, "/aws/ssm/automation/executeScript")
  cloudwatch_log_group_kms_key_id        = module.kms_key[each.value].key_arn
  cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.security_ssm_automation.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)

  tags = var.tags
}
