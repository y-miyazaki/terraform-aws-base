#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  eventbridge_role = {
    aws_iam_role = {
      name        = format("%s%s", var.name_prefix, "eventbridge-monitor-role")
      description = "IAM role for EventBridge."
      path        = "/"
    }
    aws_iam_policy = {
      name        = format("%s%s", var.name_prefix, "eventbridge-monitor-policy")
      description = "IAM policy for EventBridge."
      path        = "/"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid = "AllowRDSClusterOperations"
            Action = [
              "rds:StartDBCluster",
              "rds:StopDBCluster",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cluster:*"
          },
          {
            Sid = "AllowEC2DescribeVpcs"
            Action = [
              "ec2:DescribeVpcs",
            ]
            Effect   = "Allow"
            Resource = "*"
          },
          {
            Sid = "AllowLambdaInvoke"
            Action = [
              "lambda:InvokeFunction",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"
          }
        ]
      })
    }
  }
}

#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_iam_role_eventbridge" {
  source = "../../modules/aws/iam/role/eventbridge"

  aws_iam_role   = local.eventbridge_role.aws_iam_role
  aws_iam_policy = local.eventbridge_role.aws_iam_policy

  tags = var.tags
}
