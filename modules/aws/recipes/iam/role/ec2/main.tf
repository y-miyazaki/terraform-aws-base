#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  description           = lookup(var.aws_iam_role, "description", null)
  name                  = lookup(var.aws_iam_role, "name")
  assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  force_detach_policies = true
  path                  = lookup(var.aws_iam_role, "path", "/")
  tags                  = var.tags
}
#--------------------------------------------------------------
# Provides an IAM instance profile.
#--------------------------------------------------------------
resource "aws_iam_instance_profile" "this" {
  name = lookup(var.aws_iam_instance_profile, "name")
  path = lookup(var.aws_iam_instance_profile, "path", "/")
  role = aws_iam_role.this.name
}
