#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_chatbot_security_securityhub" {
  source                                 = "../../../modules/aws/chatbot/security/securityhub"
  is_enabled                             = var.security.securityhub.is_enabled
  name_prefix                            = var.name_prefix
  kms_master_key_id                      = null
  cloudwatch_log_group_kms_key_id        = null
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}
