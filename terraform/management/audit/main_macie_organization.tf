#--------------------------------------------------------------
# Macie organization configuration
# This configures the Macie settings for the entire
# AWS Organization to use a central model.
#--------------------------------------------------------------
module "macie_organization" {
  source     = "../../../modules/aws/security/macie_organization"
  is_enabled = var.macie_organization.is_enabled && local.is_delegated_admin.macie

  # Macie organization admin account designation is always disabled,
  # because delegated admin is expected to be configured from the management account.
  is_enabled_admin = false

  admin_account_id             = data.aws_caller_identity.current.account_id
  auto_enable                  = var.macie_organization.auto_enable
  status                       = var.macie_organization.status
  finding_publishing_frequency = var.macie_organization.finding_publishing_frequency
  classification_jobs          = var.macie_organization.classification_jobs
  findings_filters             = var.macie_organization.findings_filters

  tags = var.tags
}
