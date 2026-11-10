#--------------------------------------------------------------
# my account id/region
#--------------------------------------------------------------
data "aws_caller_identity" "current" {}

#--------------------------------------------------------------
# Organization accounts (used for explicit member registration)
#--------------------------------------------------------------
data "aws_organizations_organization" "current" {
  count = length(var.region.account_allowlist) > 0 ? 1 : 0
}
