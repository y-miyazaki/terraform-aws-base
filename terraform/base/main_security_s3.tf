#--------------------------------------------------------------
# For S3
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
#--------------------------------------------------------------
module "aws_security_s3" {
  source                  = "../../modules/aws/security/s3"
  is_enabled              = var.security_s3.is_enabled
  block_public_acls       = var.security_s3.aws_s3_account_public_access_block.block_public_acls
  block_public_policy     = var.security_s3.aws_s3_account_public_access_block.block_public_policy
  ignore_public_acls      = var.security_s3.aws_s3_account_public_access_block.ignore_public_acls
  restrict_public_buckets = var.security_s3.aws_s3_account_public_access_block.restrict_public_buckets
}
