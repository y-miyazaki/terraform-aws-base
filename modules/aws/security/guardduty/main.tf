#--------------------------------------------------------------
# Module: aws/security/guardduty
# Purpose: Provision and optionally invite member accounts to AWS GuardDuty for continuous threat detection and monitoring.
# Notes: Member invite accepter assumes detector primary account; future improvement: add organization-wide auto-enable and tag standardization (tags local already present).
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty detector.
#--------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  count = var.is_enabled ? 1 : 0

  enable                       = var.aws_guardduty_detector.enable
  finding_publishing_frequency = var.aws_guardduty_detector.finding_publishing_frequency

  tags = var.tags
}

#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty member. To accept invitations in member accounts, see the aws_guardduty_invite_accepter resource.
#--------------------------------------------------------------
resource "aws_guardduty_member" "this" {
  count = var.is_enabled ? length(var.aws_guardduty_member) : 0

  account_id                 = var.aws_guardduty_member[count.index].account_id
  detector_id                = aws_guardduty_detector.this[0].id
  email                      = var.aws_guardduty_member[count.index].email
  invite                     = try(var.aws_guardduty_member[count.index].invite, false)
  invitation_message         = try(var.aws_guardduty_member[count.index].invitation_message, null)
  disable_email_notification = try(var.aws_guardduty_member[count.index].disable_email_notification, false)
}

#--------------------------------------------------------------
# Provides a resource to accept a pending GuardDuty invite on creation, ensure the detector has the correct primary account on read, and disassociate with the primary account upon removal.
#--------------------------------------------------------------
resource "aws_guardduty_invite_accepter" "this" {
  count = var.is_enabled ? 1 : 0

  detector_id       = aws_guardduty_detector.this[0].id
  master_account_id = aws_guardduty_detector.this[0].account_id
}
