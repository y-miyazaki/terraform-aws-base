#--------------------------------------------------------------
# CloudWatch Log Group for flow log
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  region            = local.region
  name              = var.aws_cloudwatch_log_group.name
  retention_in_days = var.aws_cloudwatch_log_group.retention_in_days
  kms_key_id        = try(var.aws_cloudwatch_log_group.kms_key_id, null)

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  description           = try(var.aws_iam_role.description, null)
  force_detach_policies = true
  name                  = var.aws_iam_role.name
  path                  = try(var.aws_iam_role.path, "/")

  tags = var.tags
}

#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
data "aws_iam_policy_document" "this" {
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
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
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  description = try(var.aws_iam_policy.description, null)
  name        = var.aws_iam_policy.name
  path        = try(var.aws_iam_policy.path, "/")
  policy      = data.aws_iam_policy_document.this[0].json

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

#--------------------------------------------------------------
# Provides a resource to manage a default security group. This resource can manage the default security group of the default or a non-default VPC.
#--------------------------------------------------------------
resource "aws_flow_log" "this" {
  count = local.is_active && var.is_enabled_flow_logs ? 1 : 0

  region          = local.region
  log_destination = aws_cloudwatch_log_group.this[0].arn
  iam_role_arn    = aws_iam_role.this[0].arn
  vpc_id          = aws_default_vpc.this[0].id
  traffic_type    = "ALL"

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role.this,
    aws_default_vpc.this
  ]
}
