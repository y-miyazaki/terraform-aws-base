#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count              = var.is_enabled ? 1 : 0
  name               = lookup(var.aws_iam_role, "name")
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
POLICY
  path               = lookup(var.aws_iam_role, "path", "/")
  tags               = local.tags
}
#--------------------------------------------------------------
# Generates an IAM policy document in JSON format for use with resources that expect policy documents such as aws_iam_policy.
#--------------------------------------------------------------
data "aws_iam_policy_document" "this" {
  count = var.is_enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ssm:StartAutomationExecution",
      "ssm:GetAutomationExecution",
      # for AWS-DisablePublicAccessForSecurityGroup
      "ec2:RevokeSecurityGroupIngress",
      # for AWSConfigRemediation-EnableCloudFrontViewerPolicyHTTPS
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:UpdateDistribution",
      # for AWS-ConfigureS3BucketVersioning
      "s3:PutBucketVersioning",
      # for AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock
      # for AWSConfigRemediation-ConfigureS3PublicAccessBlock
      "s3:GetAccountPublicAccessBlock",
      "s3:PutAccountPublicAccessBlock",
      "s3:GetBucketPublicAccessBlock",
      "s3:PutBucketPublicAccessBlock",
      # for AWS-EnableS3BucketEncryption
      # "s3:PutEncryptionConfiguration",
      # for AWSConfigRemediation-RestrictBucketSSLRequestsOnly
      "s3:DeleteBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketPolicy",
    ]
    #tfsec:ignore:AWS099
    resources = ["*"]
  }
}

#--------------------------------------------------------------
# Provides an IAM policy.
#--------------------------------------------------------------
resource "aws_iam_policy" "this" {
  count       = var.is_enabled ? 1 : 0
  description = lookup(var.aws_iam_policy, "description", null)
  name        = lookup(var.aws_iam_policy, "name")
  path        = lookup(var.aws_iam_policy, "path", "/")
  policy      = data.aws_iam_policy_document.this[0].json
}
#--------------------------------------------------------------
# Attaches a Managed IAM Policy to an IAM role
#--------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "this" {
  count      = var.is_enabled ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
