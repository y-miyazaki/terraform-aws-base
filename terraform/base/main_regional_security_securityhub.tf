#--------------------------------------------------------------
# Regional deployment of AWS Security Hub
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable centralized security findings across regions.

module "aws_security_securityhub" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/securityhub"

  is_enabled = try(var.security_securityhub.is_enabled, true)
  region     = each.value
}
