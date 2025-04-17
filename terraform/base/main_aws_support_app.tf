#--------------------------------------------------------------
# IAM role of AWS Support App
#--------------------------------------------------------------
#--------------------------------------------------------------
# Create role and policy for AWS Support App
#--------------------------------------------------------------
module "aws_iam_role_aws_support_app" {
  source = "../../modules/aws/iam/role/aws_support_app"
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}aws-support-app-role"
    }
  )
  tags = var.tags
}
