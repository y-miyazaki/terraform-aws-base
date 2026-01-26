#--------------------------------------------------------------
# Module: aws/eventbridge/redshift
# Purpose: Schedule pause and resume of multiple Redshift Clusters using EventBridge Scheduler with auto-discovery support.
# Notes: Creates separate schedules for pause/resume if expressions provided; supports auto-discovery of Redshift clusters.
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
  primary_key                 = "cluster_identifier"
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  schedules = module.scheduler_helper.schedules
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for PAUSE.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "pause" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null
  }

  description = try(each.value.description, var.description, "Pause Redshift cluster ${each.value.cluster_identifier}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.cluster_identifier}-pause-cluster", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:redshift:pauseCluster"
    role_arn = var.role_arn

    input = jsonencode({
      ClusterIdentifier = each.value.cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for RESUME.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "resume" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null
  }

  description = try(each.value.description, var.description, "Resume Redshift cluster ${each.value.cluster_identifier}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.cluster_identifier}-resume-cluster", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:redshift:resumeCluster"
    role_arn = var.role_arn

    input = jsonencode({
      ClusterIdentifier = each.value.cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}
