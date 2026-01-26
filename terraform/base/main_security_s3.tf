#--------------------------------------------------------------
# For S3
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest/submodules/account-public-access
#--------------------------------------------------------------
module "s3_account_public_access" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/account-public-access"
  version = "5.10.0"
  create  = var.security_s3.is_enabled

  block_public_acls       = var.security_s3.block_public_acls
  block_public_policy     = var.security_s3.block_public_policy
  ignore_public_acls      = var.security_s3.ignore_public_acls
  restrict_public_buckets = var.security_s3.restrict_public_buckets
}
