#--------------------------------------------------------------
# For IAM Access Analyzer
#--------------------------------------------------------------
#--------------------------------------------------------------
# Forwards IAM Access Analyzer external access findings to Slack via AWS Chatbot (EventBridge rule + SNS topic).
# Deployed to each region in var.region.targets because the organization analyzers are regional.
# The KMS key exists only in the primary region, so the topics in the other regions are not encrypted.
#--------------------------------------------------------------
locals {
  # Same condition as the organization analyzers: without them no finding can reach EventBridge.
  # Known at plan time, so main_central_chatbot.tf can use it to decide which topics to subscribe to.
  is_access_analyzer_notification_enabled = var.security_notification.access_analyzer.is_enabled && var.access_analyzer_organization.is_enabled && local.is_delegated_admin.access_analyzer
}

module "aws_chatbot_security_access_analyzer" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/chatbot/security/access_analyzer"

  is_enabled = local.is_access_analyzer_notification_enabled
  region     = each.value

  kms_master_key_id = each.value == var.region.primary ? module.kms_key["audit"].key_id : null
  name_prefix       = var.name_prefix

  tags = var.tags
}
