#--------------------------------------------------------------
# Regional deployment of AWS Athena
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable Athena query execution across regions.

module "aws_security_athena" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/athena"

  is_enabled = var.security_athena.is_enabled
  region     = each.value

  output_location = var.security_athena.output_location
  workgroup       = var.security_athena.workgroup
}
