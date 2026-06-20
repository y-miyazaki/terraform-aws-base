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
