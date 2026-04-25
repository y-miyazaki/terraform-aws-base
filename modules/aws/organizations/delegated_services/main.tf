#--------------------------------------------------------------
# Check delegated admin status for this account.
# Verifies which services this account is authorized to manage
# as a delegated administrator in the organization.
#
# Verification command:
#   aws organizations list-delegated-services-for-account --account-id <ACCOUNT_ID>
#--------------------------------------------------------------
data "external" "delegated_services" {
  program = ["bash", "${path.module}/scripts/check_delegated_services.sh", var.account_id]
}
