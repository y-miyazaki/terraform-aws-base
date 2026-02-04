#--------------------------------------------------------------
# For SSM Automation (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# SSM.6 and SSM.7 compliance settings for AWS Systems Manager Automation.
# Enables CloudWatch logging for SSM Automation to meet SSM.6 control requirements.
# Disables public sharing of SSM Automation documents to comply with SSM.7 control.
#--------------------------------------------------------------
module "aws_security_ssm_automation_us_east_1" {
  source     = "../../modules/aws/security/ssm_automation"
  is_enabled = var.security_ssm_automation.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  cloudwatch_log_group_name              = var.security_ssm_automation.cloudwatch_log_group_name
  cloudwatch_log_group_kms_key_id        = module.kms_key_us_east_1["base"].key_arn
  cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.security_ssm_automation.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)

  tags = var.tags
}
