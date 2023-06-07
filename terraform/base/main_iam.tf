#--------------------------------------------------------------
# For IAM Users
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create IAM Users and Group
#--------------------------------------------------------------
# tfsec:ignore:aws-iam-enforce-mfa
module "aws_recipes_iam_user_group" {
  count       = lookup(var.iam, "is_enabled", true) ? 1 : 0
  source      = "../../modules/aws/recipes/iam/user_group"
  user        = lookup(var.iam, "user")
  group       = lookup(var.iam, "group")
  name_prefix = var.name_prefix
}
#--------------------------------------------------------------
# Create IAM switch role(From)
#--------------------------------------------------------------
module "aws_recipes_iam_switch_role_from" {
  for_each       = lookup(var.iam.switch_role.from, "group", {})
  source         = "../../modules/aws/recipes/iam/switch_role/from"
  is_enabled     = lookup(var.iam, "is_enabled") && lookup(var.iam.switch_role.from, "is_enabled")
  group          = each.key
  aws_iam_policy = lookup(each.value, "aws_iam_policy", null)
  name_prefix    = var.name_prefix
  depends_on = [
    module.aws_recipes_iam_user_group
  ]
}
#--------------------------------------------------------------
# Create IAM switch role(To)
#--------------------------------------------------------------
module "aws_recipes_iam_switch_role_to" {
  for_each       = lookup(var.iam.switch_role.to, "role", {})
  source         = "../../modules/aws/recipes/iam/switch_role/to"
  is_enabled     = lookup(var.iam, "is_enabled") && lookup(var.iam.switch_role.to, "is_enabled")
  aws_iam_role   = lookup(each.value, "aws_iam_role")
  aws_iam_policy = lookup(each.value, "aws_iam_policy", null)
  policy         = lookup(each.value, "policy", [])
  name_prefix    = var.name_prefix
  tags           = var.tags
  depends_on = [
    module.aws_recipes_iam_user_group
  ]
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
output "iam_user_login_profile" {
  value     = lookup(var.iam, "is_enabled", true) ? module.aws_recipes_iam_user_group[0].iam_user_login_profile : null
  sensitive = true
}
output "iam_access_key" {
  value     = lookup(var.iam, "is_enabled", true) ? module.aws_recipes_iam_user_group[0].iam_access_key : null
  sensitive = true
}
