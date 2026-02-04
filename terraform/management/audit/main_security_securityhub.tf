#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_chatbot_security_securityhub" {
  source     = "../../../modules/aws/chatbot/security/securityhub"
  is_enabled = var.security_notification.securityhub.is_enabled

  name_prefix                            = var.name_prefix
  kms_master_key_id                      = module.kms_key["audit"].key_id
  cloudwatch_log_group_kms_key_id        = module.kms_key["audit"].key_arn
  cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.security_securityhub.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
}
