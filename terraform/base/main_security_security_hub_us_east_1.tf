#--------------------------------------------------------------
# For Security Hub (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account in us-east-1.
#--------------------------------------------------------------
module "aws_security_securityhub_us_east_1" {
  source     = "../../modules/aws/security/securityhub"
  is_enabled = local.is_enabled_us_east_1 && var.security_securityhub.is_enabled && !local.control_tower_managed_services.securityhub
  providers = {
    aws = aws.us-east-1
  }

  # aws_securityhub_member
  aws_securityhub_member = var.security_securityhub.aws_securityhub_member
  # aws_securityhub_product_subscription
  aws_securityhub_product_subscription = var.security_securityhub.aws_securityhub_product_subscription
  # aws_securityhub_action_target
  aws_securityhub_action_target = var.security_securityhub.aws_securityhub_action_target

  depends_on = [
    module.aws_security_config_create_v4_us_east_1
  ]
}
