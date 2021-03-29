#--------------------------------------------------------------
# For IAM Users
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create IAM Users and Group
#--------------------------------------------------------------
module "aws_recipes_iam_user_group" {
  count       = lookup(var.iam, "is_enabled", true) ? 1 : 0
  source      = "../modules/aws/recipes/iam/user_group"
  user        = lookup(var.iam, "user")
  group       = lookup(var.iam, "group")
  name_prefix = var.name_prefix
}
