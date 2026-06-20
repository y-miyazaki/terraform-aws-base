#--------------------------------------------------------------
# Macie organization configuration
# Deployed to each region in var.region.targets.
#--------------------------------------------------------------
module "macie_organization" {
  for_each = toset(var.region.targets)

  source = "../../../modules/aws/security/macie_organization"

  is_enabled       = var.macie_organization.is_enabled && local.is_delegated_admin.macie
  is_enabled_admin = false
  region           = each.value

  admin_account_id             = data.aws_caller_identity.current.account_id
  auto_enable                  = var.macie_organization.auto_enable
  classification_jobs          = var.macie_organization.classification_jobs
  finding_publishing_frequency = var.macie_organization.finding_publishing_frequency
  findings_filters             = var.macie_organization.findings_filters
  status                       = var.macie_organization.status

  tags = var.tags
}
