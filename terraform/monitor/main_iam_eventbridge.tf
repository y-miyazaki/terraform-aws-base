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
            Sid    = "AllowEC2Operations"
            Effect = "Allow"
            Action = [
              "ec2:StartInstances",
              "ec2:StopInstances",
            ]
            Resource = [
              "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
            ]
          },
          {
            Sid    = "AllowECSServiceOperations"
            Effect = "Allow"
            Action = [
              "ecs:UpdateService",
            ]
            Resource = [
              "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/*/*",
            ]
          },
          {
            Sid    = "AllowApplicationAutoScalingOperations"
            Effect = "Allow"
            Action = [
              "application-autoscaling:RegisterScalableTarget",
              "cloudwatch:DescribeAlarms",
              "ecs:DescribeServices",
            ]
            Resource = [
              "arn:aws:application-autoscaling:*:${data.aws_caller_identity.current.account_id}:scalable-target/*",
              "arn:aws:cloudwatch:*:${data.aws_caller_identity.current.account_id}:alarm:*",
              "arn:aws:ecs:*:${data.aws_caller_identity.current.account_id}:service/*/*",
            ]
          },
          {
            Sid    = "AllowRDSClusterOperations"
            Effect = "Allow"
            Action = [
              "rds:StartDBCluster",
              "rds:StopDBCluster",
            ]
            Resource = [
              "arn:aws:rds:*:${data.aws_caller_identity.current.account_id}:cluster:*",
            ]
          },
          {
            Sid    = "AllowRedshiftClusterOperations"
            Effect = "Allow"
            Action = [
              "redshift:ResumeCluster",
              "redshift:PauseCluster",
            ]
            Resource = [
              "arn:aws:redshift:*:${data.aws_caller_identity.current.account_id}:cluster:*",
            ]
          },
          # Note: ec2:DescribeVpcs does not support resource-level permissions
          {
            Sid    = "AllowEC2DescribeVpcs"
            Effect = "Allow"
            Action = [
              "ec2:DescribeVpcs",
            ]
            Resource = [
              "*",
            ]
          },
          {
            Sid    = "AllowEventBridgeRuleOperations"
            Effect = "Allow"
            Action = [
              "events:EnableRule",
              "events:DisableRule",
            ]
            Resource = [
              "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:rule/*",
            ]
          },
          {
            Sid    = "AllowBatchJobQueueOperations"
            Effect = "Allow"
            Action = [
              "batch:UpdateJobQueue",
            ]
            Resource = [
              "arn:aws:batch:*:${data.aws_caller_identity.current.account_id}:job-queue/*",
            ]
          },
          {
            Sid    = "AllowLambdaInvoke"
            Effect = "Allow"
            Action = [
              "lambda:InvokeFunction",
            ]
            Resource = [
              "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*",
            ]
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
