#--------------------------------------------------------------
# For GuardDuty
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables GuardDuty for this AWS account.
#--------------------------------------------------------------
module "aws_chatbot_security_guardduty" {
  source                                 = "../../../modules/aws/chatbot/security/guardduty"
  is_enabled                             = var.security.guardduty.is_enabled
  name_prefix                            = var.name_prefix
  kms_master_key_id                      = null
  cloudwatch_log_group_kms_key_id        = null
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  tags                                   = var.tags
}
