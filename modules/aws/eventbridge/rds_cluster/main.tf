#--------------------------------------------------------------
# Module: aws/eventbridge/rds_cluster
# Purpose: Schedule start and stop of multiple RDS/Aurora DB Clusters using EventBridge Scheduler with auto-discovery support.
# Notes: Creates separate schedules for start/stop if expressions provided; supports auto-discovery of RDS clusters.
#--------------------------------------------------------------
#--------------------------------------------------------------
# eventbridge_scheduler_helper module for schedule parsing and filtering
#--------------------------------------------------------------
module "scheduler_helper" {
  source = "../../_internal/eventbridge_scheduler_helper"

  is_enabled                  = var.is_enabled
  create_auto_schedules       = var.create_auto_schedules
  source_schedules            = local.auto_discovered_schedules
  auto_schedules_include_list = var.auto_schedules_include_list
  auto_schedules_exclude_list = var.auto_schedules_exclude_list
  manual_schedules            = var.schedules
  schedule_expression_start   = var.schedule_expression_start
  schedule_expression_stop    = var.schedule_expression_stop
  primary_key                 = "db_cluster_identifier"
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  schedules = module.scheduler_helper.schedules
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for STOP.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null
  }

  description = try(each.value.description, var.description, "Stop RDS cluster ${each.value.db_cluster_identifier}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.db_cluster_identifier}-stop-db-cluster", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = var.role_arn

    input = jsonencode({
      DbClusterIdentifier = each.value.db_cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = var.retry_max_age_seconds
      maximum_retry_attempts       = var.retry_max_attempts
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for START.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null
  }

  description = try(each.value.description, var.description, "Start RDS cluster ${each.value.db_cluster_identifier}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.db_cluster_identifier}-start-db-cluster", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = var.role_arn

    input = jsonencode({
      DbClusterIdentifier = each.value.db_cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = var.retry_max_age_seconds
      maximum_retry_attempts       = var.retry_max_attempts
    }
  }
}
