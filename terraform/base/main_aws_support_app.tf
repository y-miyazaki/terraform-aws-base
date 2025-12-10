#--------------------------------------------------------------
# For AWS Support App
#--------------------------------------------------------------
#--------------------------------------------------------------
# Creates IAM role and policy for AWS Support App integration.
# This role enables AWS Support App to access support cases and provide notifications.
#--------------------------------------------------------------
module "aws_iam_role_aws_support_app" {
  source = "../../modules/aws/iam/role/aws_support_app"

  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = format("%saws-support-app-role", var.name_prefix)
  })

  tags = var.tags
}
