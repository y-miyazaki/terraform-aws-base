#--------------------------------------------------------------
# For Chatbot
#--------------------------------------------------------------
module "aws_chatbot_create" {
  source = "../../../modules/aws/chatbot/create"

  name             = "${var.name_prefix}security"
  slack_channel_id = var.security_notification.slack_channel_id
  slack_team_id    = var.security_notification.slack_team_id
  logging_level    = "ERROR"
  sns_topic_arns = concat(
    var.security_notification.securityhub.is_enabled ? [module.aws_chatbot_security_securityhub.sns_topic_arn] : [],
    var.security_notification.guardduty.is_enabled ? [module.aws_chatbot_security_guardduty.sns_topic_arn] : []
  )

  tags = var.tags
}
