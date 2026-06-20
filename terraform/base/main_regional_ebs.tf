#--------------------------------------------------------------
# Regional deployment of AWS EBS default encryption settings
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable EBS encryption by default across regions.

module "aws_security_ebs" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/ebs"

  is_enabled                                  = try(var.security_ebs.is_enabled, true)
  is_enabled_ebs_encryption_by_default        = try(var.security_ebs.is_enabled_ebs_encryption_by_default, true)
  is_enabled_ebs_public_snapshot_block_access = try(var.security_ebs.is_enabled_ebs_public_snapshot_block_access, true)
  region                                      = each.value

  state = try(var.security_ebs.state, "block-all-sharing")
}
