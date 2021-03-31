#--------------------------------------------------------------
# For Security Hub
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_recipes_security_securityhub" {
  source     = "../modules/aws/recipes/security/securityhub"
  is_enabled = lookup(var.security_securityhub, "is_enabled", true)
  # aws_securityhub_member
  securityhub_member = lookup(var.security_securityhub.aws_securityhub_member, "securityhub_member", {})
  # aws_securityhub_product_subscription
  product_subscription = lookup(var.security_securityhub.aws_securityhub_product_subscription, "product_subscription", {})
}
