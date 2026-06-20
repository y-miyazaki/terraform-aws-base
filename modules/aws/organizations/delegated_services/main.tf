#--------------------------------------------------------------
# Check delegated admin status for this account.
# Verifies which services this account is authorized to manage
# as a delegated administrator in the organization.
#
# Verification command:
#   aws organizations list-delegated-services-for-account --account-id <ACCOUNT_ID>
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

data "external" "delegated_services" {
  program = ["bash", "${path.module}/scripts/check_delegated_services.sh", var.account_id, local.region]
}
