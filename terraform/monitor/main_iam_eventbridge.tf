#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  eventbridge_role = {
    aws_iam_role = {
      name        = format("%s%s", var.name_prefix, "eventbridge-role")
      description = "Role for EventBridge."
      path        = "/"
    }
    aws_iam_policy = {
      name        = format("%s%s", var.name_prefix, "eventbridge-policy")
      description = "Policy for EventBridge."
      path        = "/"
      policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:StartDBCluster",
        "rds:StopDBCluster"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
    }
  }
}
#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_iam_role_eventbrdige" {
  source         = "../../modules/aws/iam/role/eventbridge"
  aws_iam_role   = local.eventbridge_role.aws_iam_role
  aws_iam_policy = local.eventbridge_role.aws_iam_policy
  tags           = var.tags
}
