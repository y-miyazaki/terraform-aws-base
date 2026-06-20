#--------------------------------------------------------------
# Module: aws/security/inspector2
# Purpose: Enable Amazon Inspector v2 scanning at the account level.
#--------------------------------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

resource "aws_inspector2_enabler" "this" {
  count = var.is_enabled ? 1 : 0

  region         = local.region
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = var.resource_types
}
