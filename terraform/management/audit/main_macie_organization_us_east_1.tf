#--------------------------------------------------------------
# Macie organization configuration (us-east-1)
# This configures the Macie settings for the entire
# AWS Organization to use a central model in us-east-1.
#--------------------------------------------------------------
module "macie_organization_us_east_1" {
  source     = "../../../modules/aws/security/macie_organization"
  is_enabled = local.is_enabled_us_east_1 && var.macie_organization_us_east_1.is_enabled && local.is_delegated_admin.macie
  providers = {
    aws = aws.us-east-1
  }

  # Macie organization admin account designation is always disabled,
  # because delegated admin is expected to be configured from the management account.
  is_enabled_admin = false

  admin_account_id             = data.aws_caller_identity.current.account_id
  auto_enable                  = var.macie_organization_us_east_1.auto_enable
  status                       = var.macie_organization_us_east_1.status
  finding_publishing_frequency = var.macie_organization_us_east_1.finding_publishing_frequency
  classification_jobs          = var.macie_organization_us_east_1.classification_jobs
  findings_filters             = var.macie_organization_us_east_1.findings_filters

  tags = var.tags
}
