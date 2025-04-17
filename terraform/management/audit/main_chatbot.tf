#--------------------------------------------------------------
# For Chatbot
#--------------------------------------------------------------
module "aws_chatbot_create" {
  source             = "../../../modules/aws/chatbot/create"
  name_prefix        = var.name_prefix
  name               = "security"
  slack_channel_id   = var.security.slack_channel_id
  slack_workspace_id = var.security.slack_workspace_id
  logging_level      = "ERROR"
  sns_topic_arns = concat(
    var.security.securityhub.is_enabled ? [module.aws_chatbot_security_securityhub.sns_topic_arn] : [],
    var.security.guardduty.is_enabled ? [module.aws_chatbot_security_guardduty.sns_topic_arn] : []
  )
}
