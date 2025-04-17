#--------------------------------------------------------------
# IAM role of Lambda for alarm monitoring
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  aws_iam_policy_lambda = merge(var.common_lambda.aws_iam_policy, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_policy, "name")}"
    # Note: remove logs:CreateLogGroup from Action.
    # https://advancedweb.hu/how-to-manage-lambda-log-groups-with-terraform/
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudWatchLogs",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:PutRetentionPolicy",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeMetricFilters",
        "logs:FilterLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
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
  source = "../../../modules/aws/iam/role/lambda"
  is_vpc = var.common_lambda.vpc.is_enabled
  aws_iam_role = merge(var.common_lambda.aws_iam_role, {
    name = "${var.name_prefix}${lookup(var.common_lambda.aws_iam_role, "name")}"
    }
  )
  aws_iam_policy = local.aws_iam_policy_lambda
  tags           = var.tags
}
