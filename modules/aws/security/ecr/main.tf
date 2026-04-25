#--------------------------------------------------------------
# Module: aws/security/ecr
# Purpose: Enforce ECR account-level security defaults.
# - Migrate basic scan type to AWS native scanning technology.
# Reference: https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
#--------------------------------------------------------------

resource "aws_ecr_account_setting" "basic_scan_type" {
  count = var.is_enabled ? 1 : 0

  name  = "BASIC_SCAN_TYPE_VERSION"
  value = "AWS_NATIVE"
}
