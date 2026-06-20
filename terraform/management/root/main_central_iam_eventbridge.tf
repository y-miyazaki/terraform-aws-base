#--------------------------------------------------------------
# Create role and policy for EventBridge
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  eventbridge_role = {
    aws_iam_role = {
      name        = format("%s%s", var.name_prefix, "eventbridge-audit-role")
      description = "IAM role for EventBridge."
      path        = "/"
    }
    aws_iam_policy = {
      name        = format("%s%s", var.name_prefix, "eventbridge-audit-policy")
      description = "IAM policy for EventBridge."
      path        = "/"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "lambda:InvokeFunction",
            ]
            Resource = [
              "*",
            ]
          }
        ]
      })
    }
  }
}

module "aws_iam_role_eventbridge" {
  source = "../../../modules/aws/iam/role/eventbridge"

  aws_iam_role   = local.eventbridge_role.aws_iam_role
  aws_iam_policy = local.eventbridge_role.aws_iam_policy

  tags = var.tags
}
