#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_recipes_security_securityhub" {
  source = "../../modules/aws/recipes/security/securityhub"
  tags   = var.tags

  is_enabled = lookup(var.security_securityhub, "is_enabled", true)
  # aws_securityhub_member
  aws_securityhub_member = lookup(var.security_securityhub, "aws_securityhub_member", {})
  # aws_securityhub_product_subscription
  aws_securityhub_product_subscription = lookup(var.security_securityhub, "aws_securityhub_product_subscription", {})
  # aws_securityhub_action_target
  aws_securityhub_action_target = lookup(var.security_securityhub, "aws_securityhub_action_target", {})
  #   aws_cloudwatch_event_rule = {
  #     name        = "${var.name_prefix}${lookup(var.security_securityhub.aws_cloudwatch_event_rule, "name", "security-securityhub-cloudwatch-event-rule")}"
  #     description = lookup(var.security_securityhub.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for SecurityHub.")
  #   }
  #   aws_cloudwatch_event_target = {
  #     arn = module.aws_recipes_lambda_create_securityhub.arn
  #   }

  depends_on = [
    module.aws_recipes_security_config_create_v4
  ]
}
