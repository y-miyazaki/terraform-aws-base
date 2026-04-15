#--------------------------------------------------------------
# Create role and policy for Lambda
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
          Sid    = "AllowS3FullAccess"
          Effect = "Allow"
          Action = [
            "s3:DeleteObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
          ]
          Resource = [
            module.s3_application_log.s3_bucket_arn,
            "${module.s3_application_log.s3_bucket_arn}/*"
          ]
        },
        {
          Sid    = "AllowKinesisDataFirehoseCloudwatchLogsProcessor"
          Effect = "Allow"
          Action = [
            "firehose:PutRecordBatch",
          ]
          Resource = [
            "arn:aws:firehose:*:${data.aws_caller_identity.current.account_id}:deliverystream/*"
          ]
        },
        {
          Sid    = "AllowPostgreSQLSlowQuery"
          Effect = "Allow"
          Action = [
            "logs:GetLogEvents",
            "logs:FilterLogEvents",
            "logs:DescribeLogStreams",
            "logs:DescribeLogGroups",
          ]
          Resource = [
            "arn:aws:logs:*:*:log-group:/aws/rds/*",
          ]
        },
        {
          Sid    = "AllowDynamoDB"
          Effect = "Allow"
          Action = [
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:DeleteItem",
          ]
          Resource = [
            "arn:aws:dynamodb:*:*:table/${var.name_prefix}monitor-log",
          ]
        },
        # Note: KMS key access required for decrypting CloudWatch Logs, S3 objects, and Kinesis streams
        {
          Sid    = "AllowKMSDecrypt"
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:GenerateDataKey*",
          ]
          Resource = [
            "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
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
        # Note: AWS Support API does not support resource-level permissions
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

  is_vpc = var.common_lambda.vpc.is_enabled
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${var.common_lambda.aws_iam_role.name}"
    }
  )
  aws_iam_policy = local.aws_iam_policy_lambda

  tags = var.tags
}
