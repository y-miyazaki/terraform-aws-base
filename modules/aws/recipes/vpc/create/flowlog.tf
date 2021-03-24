#--------------------------------------------------------------
# flow log
#--------------------------------------------------------------
resource "aws_flow_log" "flow_log" {
  count           = lookup(var.flow_log, "enabled") ? 1 : 0
  log_destination = element(aws_cloudwatch_log_group.flow_log.*.arn, count.index)
  iam_role_arn    = aws_iam_role.flow_log.arn
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
}

#--------------------------------------------------------------
# CloudWatch Log Group for flow log
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_log" {
  # count             = lookup(var.flow_log, "enabled") ? length(data.aws_subnet_ids.this.ids) : 0
  retention_in_days = lookup(var.flow_log, "retention_in_days")
  name_prefix       = "flow-log-"
  tags              = merge(local.tags, { "Name" = "${local.tags.Name}-flow-log" })
  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# IAM Role and policy for flow log
#--------------------------------------------------------------
resource "aws_iam_role" "flow_log" {
  name               = "${local.name}-flow-log"
  assume_role_policy = <<EOF
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
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "flow_log" {
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
resource "aws_iam_policy" "flow_log" {
  name   = "flow_log"
  path   = "/"
  policy = data.aws_iam_policy_document.flow_log.json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "flow_log" {
  role       = aws_iam_role.flow_log.id
  policy_arn = aws_iam_policy.flow_log.arn
}
