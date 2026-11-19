#--------------------------------------------------------------
# Regional deployment of Amazon Inspector v2
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets.
# Not created when Inspector is managed by Control Tower / the organization
# (control_tower.managed_services.inspector2).

module "aws_security_inspector2" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/inspector2"

  is_enabled = (
    var.security_inspector2.is_enabled &&
    !local.control_tower_managed_services.inspector2
  )
  region = each.value

  resource_types = var.security_inspector2.resource_types
}
