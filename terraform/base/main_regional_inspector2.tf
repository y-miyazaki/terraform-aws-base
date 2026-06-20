#############################################################################
# Security: Inspector2 (Multi-Region)
#############################################################################
# Inspector2 deployment across multiple regions

module "aws_security_inspector2" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/inspector2"

  is_enabled = (var.security_inspector2.is_enabled && !local.control_tower_managed_services.inspector2)
  region     = each.value

  resource_types = try(var.security_inspector2.resource_types, ["EC2", "ECR"])
}
