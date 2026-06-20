#--------------------------------------------------------------
# Regional deployment of AWS Health event monitoring
#--------------------------------------------------------------
# This module is deployed to each region in var.region.targets
# to monitor AWS Health events across regions.

module "aws_cloudwatch_events_health" {
  for_each = (try(var.health.is_enabled, true) && try(var.health.aws_cloudwatch_event_target.arn, null) != null) ? toset(var.region.targets) : toset([])

  source = "../../modules/aws/cloudwatch/events/health"

  is_enabled = try(var.health.is_enabled, true)
  region     = each.value

  aws_cloudwatch_event_rule   = try(var.health.aws_cloudwatch_event_rule, {})
  aws_cloudwatch_event_target = try(var.health.aws_cloudwatch_event_target, {})

  tags = var.tags
}
