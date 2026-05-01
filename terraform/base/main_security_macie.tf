#--------------------------------------------------------------
# For Macie
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Amazon Macie for this AWS account.
#--------------------------------------------------------------
module "aws_security_macie" {
  source     = "../../modules/aws/security/macie"
  is_enabled = var.security_macie.is_enabled && !local.control_tower_managed_services.macie

  status                       = var.security_macie.status
  finding_publishing_frequency = var.security_macie.finding_publishing_frequency
  classification_jobs          = try(var.security_macie.classification_jobs, [])
  findings_filters             = try(var.security_macie.findings_filters, [])
}
