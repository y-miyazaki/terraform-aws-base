#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
locals {
  aws_iam_role_lambda = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_role.name}"
    }
  )
  aws_iam_policy_lambda = merge(var.common_lambda.aws_iam_policy, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_policy.name}"
    # Note: remove logs:CreateLogGroup from Action.
    # https://advancedweb.hu/how-to-manage-lambda-log-groups-with-terraform/
    # AllowBudgets for cost notification .
    # AllowSupports for Trusted Advisor notification.
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
          Resource = [
            "arn:aws:ce:us-east-1:${data.aws_caller_identity.current.account_id}:/GetCostAndUsage",
          ]
        },
        {
          Sid    = "AllowIamPasswordExpired"
          Effect = "Allow"
          Action = [
            "iam:GetUser",
            "iam:ListUsers",
          ]
          Resource = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*",
          ]
        },
        {
          Sid    = "AllowIamPasswordExpired2"
          Effect = "Allow"
          Action = [
            "iam:GenerateCredentialReport",
            "iam:GetCredentialReport",
          ]
          Resource = [
            "*",
          ]
        },
        {
          Sid    = "AllowKinesisDataFirehoseCloudwatchLogsProcessor"
          Effect = "Allow"
          Action = [
            "firehose:PutRecordBatch",
          ]
          Resource = [
            "arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/*",
          ]
        },
        # Note: Organizations API access required for account-level metadata in multi-account setups
        {
          Sid    = "AllowOrganizationsDescribeAccount"
          Effect = "Allow"
          Action = [
            "organizations:DescribeAccount",
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

module "aws_iam_role_lambda" {
  source = "../../modules/aws/iam/role/lambda"

  is_vpc         = var.common_lambda.vpc.is_enabled
  aws_iam_role   = local.aws_iam_role_lambda
  aws_iam_policy = local.aws_iam_policy_lambda

  tags = var.tags
}
