#--------------------------------------------------------------
# Create role and policy for EventBridge
#--------------------------------------------------------------
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
            Sid = "AllowEC2Operations"
            Action = [
              "ec2:StartInstances",
              "ec2:StopInstances",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"
          },
          {
            Sid = "AllowECSServiceOperations"
            Action = [
              "ecs:UpdateService",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/*/*"
          },
          {
            Sid = "AllowApplicationAutoScalingOperations"
            Action = [
              "application-autoscaling:RegisterScalableTarget",
              "cloudwatch:DescribeAlarms",
              "ecs:DescribeServices",
            ]
            Effect = "Allow"
            Resource = [
              "arn:aws:application-autoscaling:*:${data.aws_caller_identity.current.account_id}:scalable-target/*",
              "arn:aws:cloudwatch:*:${data.aws_caller_identity.current.account_id}:alarm:*",
              "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/*/*",
            ]
          },
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
            Sid = "AllowRedshiftClusterOperations"
            Action = [
              "redshift:ResumeCluster",
              "redshift:PauseCluster",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:redshift:*:${data.aws_caller_identity.current.account_id}:cluster:*"
          },
          # Note: ec2:DescribeVpcs does not support resource-level permissions
          {
            Sid = "AllowEC2DescribeVpcs"
            Action = [
              "ec2:DescribeVpcs",
            ]
            Effect   = "Allow"
            Resource = "*"
          },
          {
            Sid = "AllowEventBridgeRuleOperations"
            Action = [
              "events:EnableRule",
              "events:DisableRule",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*"
          },
          {
            Sid = "AllowBatchJobQueueOperations"
            Action = [
              "batch:UpdateJobQueue",
            ]
            Effect   = "Allow"
            Resource = "arn:aws:batch:*:${data.aws_caller_identity.current.account_id}:job-queue/*"
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

module "aws_iam_role_eventbridge" {
  source = "../../modules/aws/iam/role/eventbridge"

  aws_iam_role   = local.eventbridge_role.aws_iam_role
  aws_iam_policy = local.eventbridge_role.aws_iam_policy

  tags = var.tags
}
