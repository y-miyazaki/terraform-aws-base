#--------------------------------------------------------------
# For Macie (us-east-1)
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables Amazon Macie for this AWS account in us-east-1.
#--------------------------------------------------------------
module "aws_security_macie_us_east_1" {
  source     = "../../modules/aws/security/macie"
  is_enabled = local.is_enabled_us_east_1 && var.security_macie_us_east_1.is_enabled && !local.control_tower_managed_services.macie
  providers = {
    aws = aws.us-east-1
  }

  status                       = var.security_macie_us_east_1.status
  finding_publishing_frequency = var.security_macie_us_east_1.finding_publishing_frequency
  classification_jobs          = try(var.security_macie_us_east_1.classification_jobs, [])
  findings_filters             = try(var.security_macie_us_east_1.findings_filters, [])
}
