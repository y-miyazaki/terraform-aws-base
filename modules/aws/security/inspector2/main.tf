#--------------------------------------------------------------
# Module: aws/security/inspector2
# Purpose: Enable Amazon Inspector v2 scanning at the account level.
#--------------------------------------------------------------
resource "aws_inspector2_enabler" "this" {
  count = var.is_enabled ? 1 : 0

  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = var.resource_types
}

data "aws_caller_identity" "current" {}
