#--------------------------------------------------------------
# Module: aws/iam/role/lambda
# Purpose: Create an IAM role and inline policy for Lambda execution with optional VPC ENI management policy attachment.
# Notes: Ensures tagging via unified local; future improvement: parameterize VPC ENI policy attachment for finer control.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
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
  policy      = var.aws_iam_policy.policy

  tags = var.tags
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "vpc" {
  count = var.is_vpc ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}
