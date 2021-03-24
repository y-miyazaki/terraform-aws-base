#--------------------------------------------------------------
# For IAM Users
#--------------------------------------------------------------
locals {
  iam_group_policy_developer = concat(lookup(var.iam.group_policy, "developer"), [{
    group      = "developer"
    policy_arn = module.aws_recipes_iam_policy_create_developer_base.arn
  }])
  iam_group_policy_operator = concat(lookup(var.iam.group_policy, "operator"), [{
    group      = "operator"
    policy_arn = module.aws_recipes_iam_policy_create_operator_base.arn
  }])
}
#--------------------------------------------------------------
# Create IAM Users and Group
#--------------------------------------------------------------
module "aws_recipes_iam_user" {
  source                       = "../modules/aws/recipes/iam/user"
  iam_user_users               = lookup(var.iam.user, "users")
  iam_user_group_administrator = lookup(var.iam.group, "group_administrator")
  iam_user_group_developer     = lookup(var.iam.group, "group_developer")
  iam_user_group_operator      = lookup(var.iam.group, "group_operator")
  name_prefix                  = var.name_prefix
}
#--------------------------------------------------------------
# Create IAM Policy for developer(base)
#--------------------------------------------------------------
module "aws_recipes_iam_policy_create_developer_base" {
  source      = "../modules/aws/recipes/iam/policy/create"
  statement   = lookup(var.iam.group_policy_document.developer_base, "statement")
  description = lookup(var.iam.group_policy_document.developer_base, "description")
  path        = lookup(var.iam.group_policy_document.developer_base, "path")
  name        = "${var.name_prefix}${lookup(var.iam.group_policy_document.developer_base, "name")}"
  tags        = var.tags
}
#--------------------------------------------------------------
# Create IAM Policy for operator(base)
#--------------------------------------------------------------
module "aws_recipes_iam_policy_create_operator_base" {
  source      = "../modules/aws/recipes/iam/policy/create"
  statement   = lookup(var.iam.group_policy_document.operator_base, "statement")
  description = lookup(var.iam.group_policy_document.operator_base, "description")
  path        = lookup(var.iam.group_policy_document.operator_base, "path")
  name        = "${var.name_prefix}${lookup(var.iam.group_policy_document.operator_base, "name")}"
  tags        = var.tags
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group: developer
#--------------------------------------------------------------
module "aws_recipes_iam_group_policy_attachment_developer" {
  source                          = "../modules/aws/recipes/iam/group/policy_attachment"
  aws_iam_group_policy_attachment = local.iam_group_policy_developer
  depends_on = [
    module.aws_recipes_iam_policy_create_developer_base
  ]
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM group: operator
#--------------------------------------------------------------
module "aws_recipes_iam_group_policy_attachment_operator" {
  source                          = "../modules/aws/recipes/iam/group/policy_attachment"
  aws_iam_group_policy_attachment = local.iam_group_policy_operator
  depends_on = [
    module.aws_recipes_iam_policy_create_operator_base
  ]
}
