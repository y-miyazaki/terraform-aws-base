#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty detector.
#--------------------------------------------------------------
resource "aws_guardduty_detector" "this" {
  enable                       = lookup(var.aws_guardduty_detector, "enable")
  finding_publishing_frequency = lookup(var.aws_guardduty_detector, "finding_publishing_frequency")
}
#--------------------------------------------------------------
# Provides a resource to manage a GuardDuty member. To accept invitations in member accounts, see the aws_guardduty_invite_accepter resource.
#--------------------------------------------------------------
resource "aws_guardduty_member" "this" {
  count                      = length(var.aws_guardduty_member)
  account_id                 = lookup(var.aws_guardduty_member[count.index], "account_id")
  detector_id                = aws_guardduty_detector.this.id
  email                      = lookup(var.aws_guardduty_member[count.index], "email")
  invite                     = lookup(var.aws_guardduty_member[count.index], "invite", false)
  invitation_message         = lookup(var.aws_guardduty_member[count.index], "invitation_message", null)
  disable_email_notification = lookup(var.aws_guardduty_member[count.index], "disable_email_notification", false)
}
#--------------------------------------------------------------
# Provides a resource to accept a pending GuardDuty invite on creation, ensure the detector has the correct primary account on read, and disassociate with the primary account upon removal.
#--------------------------------------------------------------
resource "aws_guardduty_invite_accepter" "this" {
  count             = lookup(var.aws_guardduty_detector, "master_account_id", null) == null ? 0 : 1
  detector_id       = aws_guardduty_detector.this.id
  master_account_id = lookup(var.aws_guardduty_detector, "master_account_id", null)
}
