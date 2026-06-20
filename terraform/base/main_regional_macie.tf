#############################################################################
# Security: Macie (Multi-Region)
#############################################################################
# Macie deployment across multiple regions
module "aws_security_macie" {
  for_each = toset(var.region.targets)

  source = "../../modules/aws/security/macie"

  is_enabled = (var.security_macie.is_enabled && !local.control_tower_managed_services.macie)
  region     = each.value

  # Macie account configuration
  status                       = try(var.security_macie.status, "ENABLED")
  finding_publishing_frequency = try(var.security_macie.finding_publishing_frequency, "FIFTEEN_MINUTES")

  # Classification jobs
  classification_jobs = try(var.security_macie.classification_jobs, [])

  # Findings filters
  findings_filters = try(var.security_macie.findings_filters, [])
}
