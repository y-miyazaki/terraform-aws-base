#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Forwards Security Hub findings to Slack via AWS Chatbot (EventBridge rule + Step Functions + SNS topic).
#--------------------------------------------------------------
module "aws_chatbot_security_securityhub" {
  source = "../../../modules/aws/chatbot/security/securityhub"

  is_enabled = var.security_notification.securityhub.is_enabled
  region     = var.region.primary

  cloudwatch_log_group_kms_key_id        = module.kms_key["audit"].key_arn
  cloudwatch_log_group_retention_in_days = coalesce(try(var.cloudwatch_log_group.override.security_securityhub.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  kms_master_key_id                      = module.kms_key["audit"].key_id
  name_prefix                            = var.name_prefix
  step_functions_kms_key_arn             = module.kms_key["audit"].key_arn

  tags = var.tags
}
