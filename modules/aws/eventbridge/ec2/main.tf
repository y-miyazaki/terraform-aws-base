#--------------------------------------------------------------
# Module: aws/eventbridge/ec2_instance
# Purpose: Schedule start and stop of multiple EC2 Instances using EventBridge Scheduler with auto-discovery support.
# Notes: Creates separate schedules for start/stop if expressions provided; supports auto-discovery of EC2 instances.
#--------------------------------------------------------------
#--------------------------------------------------------------
# eventbridge_scheduler_helper module for schedule filtering
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}
module "scheduler_helper" {
  source = "../../_internal/eventbridge_scheduler_helper"

  is_enabled            = var.is_enabled
  create_auto_schedules = var.create_auto_schedules

  source_schedules            = local.auto_discovered_schedules
  auto_schedules_include_list = var.auto_schedules_include_list
  auto_schedules_exclude_list = var.auto_schedules_exclude_list
  manual_schedules            = var.schedules
  schedule_expression_start   = var.schedule_expression_start
  schedule_expression_stop    = var.schedule_expression_stop
  primary_key                 = "instance_id"
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

  region      = local.region
  description = try(each.value.description, var.description, "Stop EC2 instance ${each.value.instance_id}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${coalesce(try(each.key, null), each.value.instance_id)}-stop-ec2-instance-scheduler", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = var.role_arn
    input = jsonencode({
      InstanceIds = [each.value.instance_id]
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

  region      = local.region
  description = try(each.value.description, var.description, "Start EC2 instance ${each.value.instance_id}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${coalesce(try(each.key, null), each.value.instance_id)}-start-ec2-instance-scheduler", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = var.role_arn
    input = jsonencode({
      InstanceIds = [each.value.instance_id]
    })
    retry_policy {
      maximum_event_age_in_seconds = var.retry_max_age_seconds
      maximum_retry_attempts       = var.retry_max_attempts
    }
  }
}
