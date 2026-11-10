#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  # Delegated service principals for this account.
  delegated_service_principals = module.delegated_services.service_principals
  is_delegated_admin = {
    access_analyzer = contains(local.delegated_service_principals, "access-analyzer.amazonaws.com")
    guardduty       = contains(local.delegated_service_principals, "guardduty.amazonaws.com")
    inspector2      = contains(local.delegated_service_principals, "inspector2.amazonaws.com")
    macie           = contains(local.delegated_service_principals, "macie.amazonaws.com")
    securityhub     = contains(local.delegated_service_principals, "securityhub.amazonaws.com")
  }
}

#--------------------------------------------------------------
# Check delegated admin status for this account.
#--------------------------------------------------------------
module "delegated_services" {
  source     = "../../../modules/aws/organizations/delegated_services"
  account_id = data.aws_caller_identity.current.account_id
}

#--------------------------------------------------------------
# Per-region account allowlist (null = all accounts in the region).
#--------------------------------------------------------------
locals {
  # GuardDuty members to register explicitly in regions that have an allowlist.
  # (Organization auto-enable cannot be restricted per account.)
  guardduty_members_by_region = {
    for r, allowed in local.region_account_allowlist : r => {
      for a in try(data.aws_organizations_organization.current[0].accounts, []) : a.id => a.email
      if a.id != data.aws_caller_identity.current.account_id && contains(allowed, a.id)
    } if allowed != null
  }

  region_account_allowlist = { for r in var.region.targets : r => lookup(var.region.account_allowlist, r, null) }
}

#--------------------------------------------------------------
# Inspector2 enabler accounts per region, limited to the region allowlist.
#--------------------------------------------------------------
locals {
  inspector2_enabler_by_region = {
    for r, m in local.inspector2_enabler_filtered : r => { for k, v in m : k => v if length(v.account_ids) > 0 && length(v.resource_types) > 0 }
  }
  inspector2_enabler_filtered = {
    for r in var.region.targets : r => {
      for k, v in var.inspector2_organization.enabler : k => {
        account_ids    = local.region_account_allowlist[r] == null ? v.account_ids : [for a in v.account_ids : a if contains(local.region_account_allowlist[r], a)]
        resource_types = [for t in v.resource_types : t if !contains(lookup(var.inspector2_organization.region_excluded_resource_types, r, []), t)]
      }
    }
  }
}
