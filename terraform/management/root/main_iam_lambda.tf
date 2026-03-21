#--------------------------------------------------------------
# IAM role of Lambda for alarm monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  aws_iam_policy_lambda = merge(var.common_lambda.aws_iam_policy, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_policy.name}"
    # Note: remove logs:CreateLogGroup from Action.
    # https://advancedweb.hu/how-to-manage-lambda-log-groups-with-terraform/
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "AllowCloudWatchLogs"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:DescribeMetricFilters",
            "logs:FilterLogEvents",
            "logs:PutLogEvents",
            "logs:PutRetentionPolicy",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
        },
        {
          Sid = "AllowBudgets"
          Action = [
            "ce:GetCostAndUsage",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ce:us-east-1:${data.aws_caller_identity.current.account_id}:/GetCostAndUsage"
        },
        {
          Sid = "AllowBudgetsBedrock"
          Action = [
            "bedrock:InvokeModel",
          ]
          Effect   = "Allow"
          Resource = "arn:aws:bedrock:*::foundation-model/*"
        },
        {
          Sid = "AllowOrganizations"
          Action = [
            "organizations:ListAccounts",
            "organizations:DescribeAccount",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        # Note: Account API access required for account-level metadata in single-account setups
        {
          Sid = "AllowAccountGetAccountInformation"
          Action = [
            "account:GetAccountInformation",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid = "AllowSupports"
          Action = [
            "support:*",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  })
}

#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_iam_role_lambda" {
  source = "../../../modules/aws/iam/role/lambda"

  is_vpc = var.common_lambda.vpc.is_enabled
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_role.name}"
    }
  )
  aws_iam_policy = local.aws_iam_policy_lambda

  tags = var.tags
}
