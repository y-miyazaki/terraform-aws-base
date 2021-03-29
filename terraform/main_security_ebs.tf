
#--------------------------------------------------------------
# Enables Security Hub for this AWS account.
#--------------------------------------------------------------
module "aws_recipes_security_ebs" {
  source     = "../modules/aws/recipes/security/ebs"
  is_enabled = lookup(var.security_ebs, "is_enabled", true)
}
