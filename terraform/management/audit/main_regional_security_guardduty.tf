#--------------------------------------------------------------
# For GuardDuty (regions other than the primary region)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Forwards GuardDuty findings to Slack via AWS Chatbot (EventBridge rule + SNS topic).
# The primary region is handled by main_central_security_guardduty.tf. GuardDuty findings are regional, so every other
# region in var.region.targets needs its own rule and topic. The KMS key exists only in the primary region, so these
# topics are not encrypted.
#--------------------------------------------------------------
module "aws_chatbot_security_guardduty_secondary" {
  for_each = toset([for r in var.region.targets : r if r != var.region.primary])

  source = "../../../modules/aws/chatbot/security/guardduty"

  is_enabled = var.security_notification.guardduty.is_enabled
  region     = each.value

  name_prefix = var.name_prefix

  tags = var.tags
}
