#--------------------------------------------------------------
# IAM role of Lambda for CloudTrail, GuardDuty, CloudWatch alarm monitoring, and regular cost budget reporting.
#--------------------------------------------------------------
locals {
  aws_iam_role_lambda = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_role, "name")}"
    }
  )
  aws_iam_policy_lambda = merge(var.common_lambda.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_policy, "name")}"
    # Note: remove logs:CreateLogGroup from Action.
    # https://advancedweb.hu/how-to-manage-lambda-log-groups-with-terraform/
    # AllowBudgets for cost notification .
    # AllowSupports for Trusted Advisor notification.
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudWatchLogs",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeMetricFilters",
        "logs:FilterLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
    },
    {
      "Sid": "AllowBudgets",
      "Action": [
        "ce:GetCostAndUsage"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ce:us-east-1:${data.aws_caller_identity.current.account_id}:/GetCostAndUsage"
    },
    {
      "Sid": "AllowIamPasswordExpired",
      "Action": [
        "iam:GetUser",
        "iam:ListUsers"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Sid": "AllowIamPasswordExpired2",
      "Action": [
        "iam:GenerateCredentialReport",
        "iam:GetCredentialReport"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "AllowKinesisDataFirehoseCloudwatchLogsProcessor",
      "Action": [
        "firehose:PutRecordBatch"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:firehose:${var.region}:${data.aws_caller_identity.current.account_id}:deliverystream/*"
    },
    {
      "Sid": "AllowSupports",
      "Action": [
        "support:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
    }
  )
}
#--------------------------------------------------------------
# Create role and policy for Lambda
#--------------------------------------------------------------
module "aws_iam_role_lambda" {
  source         = "../../modules/aws/iam/role/lambda"
  is_vpc         = var.common_lambda.vpc.is_enabled
  aws_iam_role   = local.aws_iam_role_lambda
  aws_iam_policy = local.aws_iam_policy_lambda
  tags           = var.tags
}
