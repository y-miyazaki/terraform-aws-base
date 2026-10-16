#--------------------------------------------------------------
# For IAM Users
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create IAM Users and Group
#--------------------------------------------------------------
# tfsec:ignore:aws-iam-enforce-mfa
module "aws_iam_user_group" {
  source = "../../modules/aws/iam/user_group"

  is_enabled = var.iam.is_enabled

  group       = var.iam.group
  name_prefix = var.name_prefix
  user        = var.iam.user

  tags = var.tags
}

#--------------------------------------------------------------
# Create IAM switch role(From)
#--------------------------------------------------------------
module "aws_iam_switch_role_from" {
  for_each = var.iam.switch_role.from.group

  source = "../../modules/aws/iam/switch_role/from"

  is_enabled = var.iam.is_enabled && var.iam.switch_role.from.is_enabled

  aws_iam_policy = each.value.aws_iam_policy
  group          = each.key
  name_prefix    = var.name_prefix

  tags = var.tags
  depends_on = [
    module.aws_iam_user_group
  ]
}

#--------------------------------------------------------------
# Create IAM switch role(To)
#--------------------------------------------------------------
module "aws_iam_switch_role_to" {
  for_each = var.iam.switch_role.to.role

  source = "../../modules/aws/iam/switch_role/to"

  is_enabled = var.iam.is_enabled && var.iam.switch_role.to.is_enabled

  aws_iam_policy = each.value.aws_iam_policy
  aws_iam_role   = each.value.aws_iam_role
  name_prefix    = var.name_prefix
  policy         = each.value.policy

  tags = var.tags
  depends_on = [
    module.aws_iam_user_group
  ]
}

#--------------------------------------------------------------
# Output
#--------------------------------------------------------------
output "iam_user_login_profile" {
  value     = module.aws_iam_user_group.iam_user_login_profile
  sensitive = true
}
output "iam_access_key" {
  value     = module.aws_iam_user_group.iam_access_key
  sensitive = true
}
