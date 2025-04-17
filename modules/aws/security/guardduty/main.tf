#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty detector.
#--------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  count                        = var.is_enabled ? 1 : 0
  enable                       = lookup(var.aws_guardduty_detector, "enable")
  finding_publishing_frequency = lookup(var.aws_guardduty_detector, "finding_publishing_frequency")
  tags                         = local.tags
}
#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty member. To accept invitations in member accounts, see the aws_guardduty_invite_accepter resource.
#--------------------------------------------------------------
resource "aws_guardduty_member" "this" {
  count                      = var.is_enabled ? length(var.aws_guardduty_member) : 0
  account_id                 = lookup(var.aws_guardduty_member[count.index], "account_id")
  detector_id                = aws_guardduty_detector.this[0].id
  email                      = lookup(var.aws_guardduty_member[count.index], "email")
  invite                     = lookup(var.aws_guardduty_member[count.index], "invite", false)
  invitation_message         = lookup(var.aws_guardduty_member[count.index], "invitation_message", null)
  disable_email_notification = lookup(var.aws_guardduty_member[count.index], "disable_email_notification", false)
}
#--------------------------------------------------------------
# Provides a resource to accept a pending GuardDuty invite on creation, ensure the detector has the correct primary account on read, and disassociate with the primary account upon removal.
#--------------------------------------------------------------
resource "aws_guardduty_invite_accepter" "this" {
  count             = var.is_enabled && lookup(var.aws_guardduty_detector, "master_account_id", null) != null ? 1 : 0
  detector_id       = aws_guardduty_detector.this[0].id
  master_account_id = lookup(var.aws_guardduty_detector, "master_account_id", null)
}
