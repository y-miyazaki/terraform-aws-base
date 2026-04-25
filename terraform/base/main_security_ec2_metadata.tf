#--------------------------------------------------------------
# For EC2 Instance Metadata Defaults
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enforce IMDSv2 as the default for all new EC2 instances at the account level.
# Security Hub: EC2.8 - EC2 instances should use IMDSv2
#--------------------------------------------------------------
module "aws_security_ec2_metadata" {
  source     = "../../modules/aws/security/ec2_metadata"
  is_enabled = var.security_ec2_metadata.is_enabled
}
