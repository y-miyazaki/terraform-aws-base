#--------------------------------------------------------------
# Module: aws/iam/role/flow_log
# Purpose: Create IAM role and policy for VPC Flow Logs delivery to CloudWatch Logs.
# Notes: Unified tagging applied; future improvement: restrict log resource ARNs instead of wildcard.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
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
# Provides an IAM policy.
#--------------------------------------------------------------
#tfsec:ignore:AWS099
resource "aws_iam_policy" "this" {
  description = try(var.aws_iam_policy.description, null)
  name        = var.aws_iam_policy.name
  path        = try(var.aws_iam_policy.path, "/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
        ]
        Resource = [
          "*",
        ]
      }
    ]
  })

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
