#--------------------------------------------------------------
# Module: aws/eventbridge/batch
# Purpose: Schedule enable and disable of AWS Batch job queues using EventBridge Scheduler with auto-discovery support.
# Notes: Creates separate schedules for enable/disable if expressions provided; supports auto-discovery of Batch job queues.
#--------------------------------------------------------------
#--------------------------------------------------------------
# eventbridge_scheduler_helper module for schedule filtering
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
  primary_key                 = "job_queue"
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  schedules = module.scheduler_helper.schedules
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for DISABLE (stop Batch job queue).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null
  }

  description = try(each.value.description, var.description, "Disable AWS Batch job queue ${each.value.job_queue}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.job_queue}-disable-job-queue", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:batch:updateJobQueue"
    role_arn = var.role_arn

    input = jsonencode({
      JobQueue = each.value.job_queue
      State    = "DISABLED"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for ENABLE (start Batch job queue).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null
  }

  description = try(each.value.description, var.description, "Enable AWS Batch job queue ${each.value.job_queue}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.job_queue}-enable-job-queue", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:batch:updateJobQueue"
    role_arn = var.role_arn

    input = jsonencode({
      JobQueue = each.value.job_queue
      State    = "ENABLED"
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}
