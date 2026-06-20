#--------------------------------------------------------------
# Regional deployment of AWS GuardDuty findings monitoring
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to monitor GuardDuty findings across regions.

module "aws_cloudwatch_events_guardduty" {
  for_each = (try(var.guardduty.is_enabled, true) && try(var.guardduty.aws_cloudwatch_event_target.arn, null) != null) ? toset(var.region.targets) : toset([])

  source = "../../modules/aws/cloudwatch/events/guardduty"

  is_enabled = try(var.guardduty.is_enabled, true)
  region     = each.value

  aws_cloudwatch_event_rule   = try(var.guardduty.aws_cloudwatch_event_rule, {})
  aws_cloudwatch_event_target = try(var.guardduty.aws_cloudwatch_event_target, {})

  tags = var.tags
}
