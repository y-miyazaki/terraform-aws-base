#--------------------------------------------------------------
# Module: aws/iam/role/cloudtrail
# Purpose: Create IAM role and policy for AWS CloudTrail service integration.
# Notes: Unified tagging applied; future improvement: restrict policy actions to least privilege if currently broad.
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
          Service = "cloudtrail.amazonaws.com"
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
