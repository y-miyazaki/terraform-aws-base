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
          Sid    = "AllowCloudWatchLogs"
          Effect = "Allow"
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
          Resource = [
            "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*",
          ]
        },
        {
          Sid    = "AllowBudgets"
          Effect = "Allow"
          Action = [
            "ce:GetCostAndUsage",
          ]
          # "*" unless a custom billing view is used; then scope to arn:aws:billing::<account_id>:billingview/<id> (service is billing, not ce).
          Resource = [
            "*",
          ]
        },
        {
          Sid    = "AllowBudgetsBedrock"
          Effect = "Allow"
          Action = [
            "bedrock:InvokeModel",
          ]
          Resource = [
            "arn:aws:bedrock:*::foundation-model/*",
          ]
        },
        {
          Sid    = "AllowOrganizationsDescribeAccount"
          Effect = "Allow"
          Action = [
            "organizations:DescribeAccount",
          ]
          Resource = [
            "arn:aws:organizations::*:account/o-*/*",
          ]
        },
        # Note: organizations:ListAccounts does not support resource-level permissions
        {
          Sid    = "AllowOrganizationsListAccounts"
          Effect = "Allow"
          Action = [
            "organizations:ListAccounts",
          ]
          Resource = [
            "*",
          ]
        },
        # Note: Account API access required for account-level metadata in single-account setups
        {
          Sid    = "AllowAccountGetAccountInformation"
          Effect = "Allow"
          Action = [
            "account:GetAccountInformation",
          ]
          Resource = [
            "arn:aws:account::${data.aws_caller_identity.current.account_id}:account",
          ]
        },
        {
          Sid    = "AllowSupports"
          Effect = "Allow"
          Action = [
            "support:*",
          ]
          Resource = [
            "*",
          ]
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

  aws_iam_policy = local.aws_iam_policy_lambda
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_role.name}"
    }
  )
  is_vpc = var.common_lambda.vpc.is_enabled

  tags = var.tags
}
