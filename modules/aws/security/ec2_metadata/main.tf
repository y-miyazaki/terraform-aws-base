#--------------------------------------------------------------
# Module: aws/security/ec2_metadata
# Purpose: Enforce IMDSv2 as the default for all new EC2 instances at the account level.
# Security Hub: EC2.8 - EC2 instances should use Instance Metadata Service Version 2 (IMDSv2)
#--------------------------------------------------------------

#--------------------------------------------------------------
# Set account-level EC2 instance metadata defaults.
# This enforces IMDSv2 for all new instances launched in the account.
#--------------------------------------------------------------
resource "aws_ec2_instance_metadata_defaults" "this" {
  count = var.is_enabled ? 1 : 0

  http_tokens                 = var.http_tokens
  http_put_response_hop_limit = var.http_put_response_hop_limit
  http_endpoint               = var.http_endpoint
}
