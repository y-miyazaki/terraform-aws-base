#--------------------------------------------------------------
# For Inspector2 (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Amazon Inspector v2 for this AWS account in us-east-1.
#--------------------------------------------------------------
module "aws_security_inspector2_us_east_1" {
  source     = "../../modules/aws/security/inspector2"
  is_enabled = local.is_enabled_us_east_1 && var.security_inspector2_us_east_1.is_enabled && !local.control_tower_managed_services.inspector2
  providers = {
    aws = aws.us-east-1
  }

  resource_types = var.security_inspector2_us_east_1.resource_types
}
