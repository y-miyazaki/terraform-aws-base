#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  control_tower_managed_services = {
    access_analyzer = coalesce(try(var.control_tower.managed_services.access_analyzer, null), local.is_control_tower_enabled)
    cloudtrail      = coalesce(try(var.control_tower.managed_services.cloudtrail, null), local.is_control_tower_enabled)
    config          = coalesce(try(var.control_tower.managed_services.config, null), local.is_control_tower_enabled)
    guardduty       = coalesce(try(var.control_tower.managed_services.guardduty, null), local.is_control_tower_enabled)
    inspector2      = coalesce(try(var.control_tower.managed_services.inspector2, null), local.is_control_tower_enabled)
    macie           = coalesce(try(var.control_tower.managed_services.macie, null), local.is_control_tower_enabled)
    securityhub     = coalesce(try(var.control_tower.managed_services.securityhub, null), local.is_control_tower_enabled)
  }
  # EventBridge rule names of the notification pipelines. The Lambda permissions build the rule ARN from
  # these names instead of reading it from the events modules, which would make the modules depend on each other.
  # The names carry name_prefix, as in the deployed rules (for example base-health-cloudwatch-event-rule). Do not drop it: the rules would be replaced.
  event_rule_names = {
    config    = "${var.name_prefix}${var.security_config.aws_cloudwatch_event_rule.name}"
    guardduty = "${var.name_prefix}${var.guardduty.aws_cloudwatch_event_rule.name}"
    health    = "${var.name_prefix}${var.health.aws_cloudwatch_event_rule.name}"
  }
  # Derive is_control_tower_enabled from the control_tower object.
  # Defaults to false when control_tower is not set.
  is_control_tower_enabled = var.control_tower != null ? var.control_tower.is_enabled : false
  # Notification pipelines (EventBridge -> Lambda -> Slack) are not created when
  # Control Tower / the organization manages the service.
  is_enabled_check_guardduty = var.guardduty.is_enabled && !local.control_tower_managed_services.guardduty
  is_enabled_security_config = var.security_config.is_enabled && !local.control_tower_managed_services.config
  # The Lambda VPC is created only in var.region.global, so regional Lambda functions
  # attach to it only in that region and run outside a VPC in the other regions.
  is_lambda_vpc_region = {
    for region in var.region.targets : region => var.common_lambda.vpc.is_enabled && region == var.region.global
  }
  lambda_vpc_security_group_ids = {
    for region, is_vpc in local.is_lambda_vpc_region : region => is_vpc ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc.default_security_group_id] : [var.common_lambda.vpc.exists.security_group_id] : []
  }
  lambda_vpc_subnet_ids = {
    for region, is_vpc in local.is_lambda_vpc_region : region => is_vpc ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc.private_subnets : var.common_lambda.vpc.exists.private_subnets : []
  }
}
