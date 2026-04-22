#--------------------------------------------------------------
# For EBS (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Manage EBS account-level security defaults: EBS Encryption by Default
# and public snapshot access blocking. See `modules/aws/security/ebs` for
# implementation details.
#--------------------------------------------------------------
module "aws_security_ebs_us_east_1" {
  source     = "../../modules/aws/security/ebs"
  is_enabled = local.is_enabled_us_east_1 && var.security_ebs.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  is_enabled_ebs_encryption_by_default        = var.security_ebs.is_enabled_ebs_encryption_by_default
  is_enabled_ebs_public_snapshot_block_access = var.security_ebs.is_enabled_ebs_public_snapshot_block_access
}
