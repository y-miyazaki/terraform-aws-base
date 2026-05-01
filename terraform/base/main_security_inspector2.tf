#--------------------------------------------------------------
# For Inspector2
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Amazon Inspector v2 for this AWS account.
#--------------------------------------------------------------
module "aws_security_inspector2" {
  source     = "../../modules/aws/security/inspector2"
  is_enabled = var.security_inspector2.is_enabled && !local.control_tower_managed_services.inspector2

  resource_types = var.security_inspector2.resource_types
}
