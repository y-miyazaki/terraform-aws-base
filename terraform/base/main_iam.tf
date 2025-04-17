#--------------------------------------------------------------
# For IAM Users
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create IAM Users and Group
#--------------------------------------------------------------
# tfsec:ignore:aws-iam-enforce-mfa
module "aws_iam_user_group" {
  count       = var.iam.is_enabled ? 1 : 0
  source      = "../../modules/aws/iam/user_group"
  user        = var.iam.user
  group       = var.iam.group
  name_prefix = var.name_prefix
  tags        = var.tags
}
#--------------------------------------------------------------
# Create IAM switch role(From)
#--------------------------------------------------------------
module "aws_iam_switch_role_from" {
  for_each       = var.iam.switch_role.from.group
  source         = "../../modules/aws/iam/switch_role/from"
  is_enabled     = var.iam.is_enabled && var.iam.switch_role.from.is_enabled
  group          = each.key
  aws_iam_policy = each.value.aws_iam_policy
  name_prefix    = var.name_prefix
  tags           = var.tags
  depends_on = [
    module.aws_iam_user_group
  ]
}
#--------------------------------------------------------------
# Create IAM switch role(To)
#--------------------------------------------------------------
module "aws_iam_switch_role_to" {
  for_each       = var.iam.switch_role.to.role
  source         = "../../modules/aws/iam/switch_role/to"
  is_enabled     = var.iam.is_enabled && var.iam.switch_role.to.is_enabled
  aws_iam_role   = each.value.aws_iam_role
  aws_iam_policy = each.value.aws_iam_policy
  policy         = each.value.policy
  name_prefix    = var.name_prefix
  tags           = var.tags
  depends_on = [
    module.aws_iam_user_group
  ]
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
output "iam_user_login_profile" {
  value     = var.iam.is_enabled ? module.aws_iam_user_group[0].iam_user_login_profile : null
  sensitive = true
}
output "iam_access_key" {
  value     = var.iam.is_enabled ? module.aws_iam_user_group[0].iam_access_key : null
  sensitive = true
}
