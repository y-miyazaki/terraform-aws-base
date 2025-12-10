#--------------------------------------------------------------
# For GuardDuty
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables GuardDuty for this AWS account.
#--------------------------------------------------------------
module "aws_chatbot_security_guardduty" {
  source     = "../../../modules/aws/chatbot/security/guardduty"
  is_enabled = var.security_notification.guardduty.is_enabled

  name_prefix       = var.name_prefix
  kms_master_key_id = module.kms_key["audit"].key_id

  tags = var.tags
}
