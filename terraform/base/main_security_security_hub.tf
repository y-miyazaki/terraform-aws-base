#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_security_securityhub" {
  source = "../../modules/aws/security/securityhub"
  #   tags   = var.tags

  is_enabled = var.security_securityhub.is_enabled && var.use_control_tower
  # aws_securityhub_member
  aws_securityhub_member = var.security_securityhub.aws_securityhub_member
  # aws_securityhub_product_subscription
  aws_securityhub_product_subscription = var.security_securityhub.aws_securityhub_product_subscription
  # aws_securityhub_action_target
  aws_securityhub_action_target = var.security_securityhub.aws_securityhub_action_target
  #   aws_cloudwatch_event_rule = {
  #     name        = "${var.name_prefix}${var.security_securityhub.aws_cloudwatch_event_rule.name}"
  #     description = var.security_securityhub.aws_cloudwatch_event_rule.description
  #   }
  #   aws_cloudwatch_event_target = {
  #     arn = module.aws_lambda_create_securityhub.arn
  #   }

  depends_on = [
    module.aws_security_config_create_v4
  ]
}
