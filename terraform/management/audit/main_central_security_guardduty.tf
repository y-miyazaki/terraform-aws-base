#--------------------------------------------------------------
# For GuardDuty
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables GuardDuty for this AWS account.
#--------------------------------------------------------------
module "aws_chatbot_security_guardduty" {
  source = "../../../modules/aws/chatbot/security/guardduty"

  is_enabled = var.security_notification.guardduty.is_enabled
  region     = var.region.primary

  kms_master_key_id = module.kms_key["audit"].key_id
  name_prefix       = var.name_prefix

  tags = var.tags
}
