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

#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  count         = var.is_enabled ? 1 : 0
  name          = lookup(var.aws_cloudwatch_event_rule, "name", "security-guarduty-cloudwatch-event-rule")
  event_pattern = <<EVENT_PATTERN
  {
    "source": [
      "aws.guardduty"
    ],
    "detail-type": [
      "GuardDuty Finding"
    ]
  }
EVENT_PATTERN
  description   = lookup(var.aws_cloudwatch_event_rule, "description", "This cloudwatch event used for GuardDuty.")
  is_enabled    = lookup(var.aws_cloudwatch_event_rule, "is_enabled", true)
  tags          = local.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  count = var.is_enabled ? 1 : 0
  rule  = aws_cloudwatch_event_rule.this[0].name
  arn   = lookup(var.aws_cloudwatch_event_target, "arn", null)
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
