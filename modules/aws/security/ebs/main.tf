#--------------------------------------------------------------
# Module: aws/security/ebs
# Purpose: Manage EBS security settings such as default encryption and snapshot public access blocking.
# Notes: This module uses aws_ebs_encryption_by_default and aws_ebs_snapshot_block_public_access resources.
#        Ensure that the AWS provider is properly configured in the root module.
#
# See: README.md (tfdocs) in this module for requirements, inputs and examples.
# Inputs: `is_enabled`, `is_enabled_ebs_encryption_by_default`, `is_enabled_ebs_public_snapshot_block_access`, `state`
#--------------------------------------------------------------

#--------------------------------------------------------------
# Provides a resource to manage whether default EBS encryption is enabled for your AWS account in the current AWS region.
# To manage the default KMS key for the region, see the aws_ebs_default_kms_key resource.
# Security Hub: EC2.7 - EBS default encryption should be enabled
#--------------------------------------------------------------
resource "aws_ebs_encryption_by_default" "this" {
  count = var.is_enabled && var.is_enabled_ebs_encryption_by_default ? 1 : 0

  enabled = true
}

#--------------------------------------------------------------
# Provides a resource to manage the block public access settings for EBS snapshots in your AWS account
# Security Hub: EC2.182 - Amazon EBS Snapshots should not be publicly accessible
#--------------------------------------------------------------
resource "aws_ebs_snapshot_block_public_access" "this" {
  count = var.is_enabled && var.is_enabled_ebs_public_snapshot_block_access ? 1 : 0

  state = var.state
}
