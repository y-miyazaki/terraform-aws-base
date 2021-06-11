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
      "Resource": "*"
    },
    {
      "Sid": "AllowBudgets",
      "Action": [
        "ce:GetCostAndUsage"
      ],
      "Effect": "Allow",
      "Resource": "*"
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
module "aws_recipes_iam_lambda" {
  source         = "../../modules/aws/recipes/iam/role/lambda"
  aws_iam_role   = local.aws_iam_role_lambda
  aws_iam_policy = local.aws_iam_policy_lambda
  tags           = var.tags
}
