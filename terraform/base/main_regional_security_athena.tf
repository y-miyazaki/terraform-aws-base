#--------------------------------------------------------------
# Regional deployment of AWS Athena
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enable Athena query execution across regions.

module "aws_security_athena" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/athena"

  is_enabled = try(var.security_athena.is_enabled, true)
  region     = each.value

  output_location = try(var.security_athena.output_location, null)
  workgroup       = try(var.security_athena.workgroup, "primary")
}
