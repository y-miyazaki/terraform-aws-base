#--------------------------------------------------------------
# Regional deployment of AWS ECR account settings
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to enforce ECR account-level security defaults.
# Migrates basic scan type to AWS native scanning technology.

module "aws_security_ecr" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/ecr"

  is_enabled = var.security_ecr.is_enabled
  region     = each.value
}
