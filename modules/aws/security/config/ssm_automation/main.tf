#--------------------------------------------------------------
# Module: aws/security/config/ssm_automation
# Purpose: IAM role and policy for SSM Automation remediation runbooks used by Config remediation configurations (e.g., S3 public access block, SG SSH restriction, CloudFront HTTPS enforcement).
# Notes: Grants broad permissions (*) for remediation actions; future improvement: restrict resources and scope per action; tags standardized via locals.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
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
  count = var.is_enabled ? 1 : 0

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
  count = var.is_enabled ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
