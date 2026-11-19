#--------------------------------------------------------------
# Regional deployment of Amazon Macie
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets.
# Not created when Macie is managed by Control Tower / the organization
# (control_tower.managed_services.macie).

module "aws_security_macie" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/macie"

  is_enabled = (
    var.security_macie.is_enabled &&
    !local.control_tower_managed_services.macie
  )
  region = each.value

  classification_jobs          = var.security_macie.classification_jobs
  finding_publishing_frequency = var.security_macie.finding_publishing_frequency
  findings_filters             = var.security_macie.findings_filters
  status                       = var.security_macie.status
}
