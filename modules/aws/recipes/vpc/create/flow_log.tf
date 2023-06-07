#--------------------------------------------------------------
# CloudWatch Log Group for flow log
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name              = lookup(var.aws_cloudwatch_log_group, "name")
  retention_in_days = lookup(var.aws_cloudwatch_log_group, "retention_in_days")
  kms_key_id        = lookup(var.aws_cloudwatch_log_group, "kms_key_id", null)
  tags              = merge(local.tags, { "Name" = lookup(var.aws_cloudwatch_log_group, "name") })
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  path                  = lookup(var.aws_iam_role, "path", "/")
  force_detach_policies = true
  tags                  = local.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "*",
    ]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "this" {
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = data.aws_iam_policy_document.this.json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.id
  policy_arn = aws_iam_policy.this.arn
}
#--------------------------------------------------------------
# Provides a resource to manage a default security group. This resource can manage the default security group of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_flow_log" "this" {
  log_destination = aws_cloudwatch_log_group.this.arn
  iam_role_arn    = aws_iam_role.this.arn
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role.this,
    aws_vpc.this
  ]
}
