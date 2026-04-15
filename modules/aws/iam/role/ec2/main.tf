#--------------------------------------------------------------
# Module: aws/iam/role/ec2
# Purpose: Create IAM role and instance profile for EC2 instances.
# Notes: Unified tagging applied; future improvement: allow attachment of managed/inline policies via variables.
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
          Service = "ec2.amazonaws.com"
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
# Provides an IAM instance profile.
#--------------------------------------------------------------
resource "aws_iam_instance_profile" "this" {
  name = var.aws_iam_instance_profile.name
  path = try(var.aws_iam_instance_profile.path, "/")
  role = aws_iam_role.this.name
}
