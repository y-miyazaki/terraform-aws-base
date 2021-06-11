#--------------------------------------------------------------
# For S3
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manages S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
#--------------------------------------------------------------
module "aws_recipes_security_s3" {
  source                  = "../../modules/aws/recipes/security/s3"
  is_enabled              = lookup(var.security_s3, "is_enabled", true)
  block_public_acls       = lookup(var.security_s3.aws_s3_account_public_access_block, "block_public_acls", true)
  block_public_policy     = lookup(var.security_s3.aws_s3_account_public_access_block, "block_public_policy", true)
  ignore_public_acls      = lookup(var.security_s3.aws_s3_account_public_access_block, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.security_s3.aws_s3_account_public_access_block, "restrict_public_buckets", true)
}
