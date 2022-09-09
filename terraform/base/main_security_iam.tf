#--------------------------------------------------------------
# For IAM
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages Password Policy for the AWS Account. See more about Account Password Policy in the official AWS docs.
#--------------------------------------------------------------
module "aws_recipes_security_iam" {
  source                          = "../../modules/aws/recipes/security/iam"
  is_enabled                      = lookup(var.security_iam, "is_enabled", true)
  aws_iam_account_password_policy = lookup(var.security_iam, "aws_iam_account_password_policy")
  support_iam_role_principal_arns = lookup(var.security_iam, "support_iam_role_principal_arns", null)
  aws_iam_role = {
    description = lookup(var.security_iam.aws_iam_role, "description", null)
    name        = "${var.name_prefix}${lookup(var.security_iam.aws_iam_role, "name")}"
    path        = lookup(var.security_iam.aws_iam_role, "path", "/")
  }
  tags = var.tags
}
