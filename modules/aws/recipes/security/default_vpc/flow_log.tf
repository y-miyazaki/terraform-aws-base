#--------------------------------------------------------------
# CloudWatch Log Group for flow log
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_flow_logs ? 1 : 0
  retention_in_days = lookup(var.aws_cloudwatch_log_group, "retention_in_days")
  name_prefix       = lookup(var.aws_cloudwatch_log_group, "name_prefix")
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count                 = var.enable_flow_logs ? 1 : 0
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path                  = lookup(var.aws_iam_role, "path", "/")
  force_detach_policies = true
  tags                  = var.tags
}
#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  count       = var.enable_flow_logs ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
     {
        "Action":[
           "logs:CreateLogGroup",
           "logs:CreateLogStream",
           "logs:PutLogEvents",
           "logs:DescribeLogGroups",
           "logs:DescribeLogStreams"
        ],
        "Effect":"Allow",
        "Resource":"*"
     }
  ]
}
POLICY
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = var.enable_flow_logs ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

#--------------------------------------------------------------
# Provides a resource to manage a default security group. This resource can manage the default security group of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_flow_log" "this" {
  count           = var.enable_flow_logs ? 1 : 0
  log_destination = aws_cloudwatch_log_group.this[0].arn
  iam_role_arn    = aws_iam_role.this[0].arn
  vpc_id          = aws_default_vpc.this[0].id
  traffic_type    = "ALL"
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role.this,
    aws_default_vpc.this
  ]
}
