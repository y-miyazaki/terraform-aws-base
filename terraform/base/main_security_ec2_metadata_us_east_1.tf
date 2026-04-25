#--------------------------------------------------------------
# For EC2 Instance Metadata Defaults (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enforce IMDSv2 as the default for all new EC2 instances at the account level.
# Security Hub: EC2.8 - EC2 instances should use IMDSv2
#--------------------------------------------------------------
module "aws_security_ec2_metadata_us_east_1" {
  source     = "../../modules/aws/security/ec2_metadata"
  is_enabled = local.is_enabled_us_east_1 && var.security_ec2_metadata.is_enabled
  providers = {
    aws = aws.us-east-1
  }
}
