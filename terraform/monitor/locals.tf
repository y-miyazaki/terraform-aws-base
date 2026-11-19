#--------------------------------------------------------------
# Local Variables
#--------------------------------------------------------------
locals {
  # Whether global region differs from primary (need separate global resources)
  is_enabled_global = var.region.global != var.region.primary

  # Target regions other than primary/global. Keyed by region name.
  extra_regions = {
    for r in var.region.targets : r => r
    if r != var.region.primary && r != var.region.global
  }

  # Regions where monitor infrastructure (KMS, VPC, Lambda, DynamoDB, Delivery) is deployed.
  # Keys: "primary", "global" (only when it differs from primary), and the region name for other targets.
  # Keep "primary"/"global" keys stable to avoid recreating existing resources.
  monitor_regions = merge(
    { primary = var.region.primary },
    local.is_enabled_global ? { global = var.region.global } : {},
    local.extra_regions,
  )

  # Key of module.lambda_vpc used by the global-region Lambda functions.
  lambda_vpc_global_key = local.is_enabled_global ? "global" : "primary"

  # Lambda VPC settings by monitor region key. Empty when the Lambda VPC is disabled.
  # Uses the VPC created by module.lambda_vpc (create_vpc = true) or var.common_lambda.vpc.exists (create_vpc = false).
  lambda_vpc_security_group_ids = {
    for k, r in local.monitor_regions : k => var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? [module.lambda_vpc[k].default_security_group_id] : [var.common_lambda.vpc.exists[r].security_group_id] : []
  }
  lambda_vpc_subnet_ids = {
    for k, r in local.monitor_regions : k => var.common_lambda.vpc.is_enabled ? var.common_lambda.vpc.create_vpc ? module.lambda_vpc[k].private_subnets : var.common_lambda.vpc.exists[r].private_subnets : []
  }

  # Settings of each regional metric/log alarm (common values + optional "regions" / "region_override").
  metric_settings = {
    metric_log_application                 = var.metric_log_application
    metric_log_mysql_slowquery             = var.metric_log_mysql_slowquery
    metric_log_postgresql                  = var.metric_log_postgresql
    metric_log_postgresql_slowquery        = var.metric_log_postgresql_slowquery
    metric_log_step_functions              = var.metric_log_step_functions
    metric_log_waf                         = var.metric_log_waf
    metric_resource_api_gateway            = var.metric_resource_api_gateway
    metric_resource_ec2                    = var.metric_resource_ec2
    metric_resource_ecs_container_insights = var.metric_resource_ecs_container_insights
    metric_resource_elasticache            = var.metric_resource_elasticache
    metric_resource_elb                    = var.metric_resource_elb
    metric_resource_eventbridge_scheduler  = var.metric_resource_eventbridge_scheduler
    metric_resource_lambda                 = var.metric_resource_lambda
    metric_resource_nat_gateway            = var.metric_resource_nat_gateway
    metric_resource_rds_cluster            = var.metric_resource_rds_cluster
    metric_resource_redshift               = var.metric_resource_redshift
    metric_resource_ses                    = var.metric_resource_ses
    metric_resource_sns                    = var.metric_resource_sns
    metric_resource_sqs                    = var.metric_resource_sqs
  }

  # Metric/log name => (monitor region key => effective settings).
  # - regions: Regions to monitor. Default: [var.region.primary]. Must be listed in var.region.targets.
  # - region_override: Per-region values. Top-level keys replace the common values for that region.
  metric_regions = {
    for name, v in local.metric_settings : name => {
      for k, r in local.monitor_regions : k => merge(v, try(v.region_override[r], {}))
      if contains(try(v.regions, [var.region.primary]), r)
    }
  }
}

# Fail the plan when a metric/log "regions" entry is not listed in var.region.targets (it would be silently ignored).
resource "terraform_data" "validate_metric_regions" {
  lifecycle {
    precondition {
      condition = alltrue([
        for name, v in local.metric_settings : length(setsubtract(toset(try(v.regions, [])), toset(var.region.targets))) == 0
      ])
      error_message = "regions of ${join(", ", [for name, v in local.metric_settings : name if length(setsubtract(toset(try(v.regions, [])), toset(var.region.targets))) > 0])} must be listed in region.targets."
    }
  }
}
