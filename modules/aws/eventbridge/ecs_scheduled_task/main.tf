#--------------------------------------------------------------
# Module: aws/eventbridge/ecs_scheduled_task
# Purpose: Schedule enable and disable of EventBridge rules that trigger ECS tasks using EventBridge Scheduler.
#          Discovery is based on Cluster Name and Task Definition Family.
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
  primary_key                 = "task_definition" # Filter by task definition family name
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  # 1. Get raw schedules from helper (User inputs: Cluster/Task)
  raw_schedules = module.scheduler_helper.schedules

  # 2. Resolve Rule Names and Flatten
  #    Each user input might map to multiple rules (though usually one)
  resolved_schedules_flat = flatten([
    for k, v in local.raw_schedules : [
      for rule_name in split(",", lookup(local.discovered_rules_map, "${v.ecs_cluster}/${v.task_definition}", "")) : {
        key                       = k
        rule_name                 = rule_name
        schedule_expression_start = v.schedule_expression_start
        schedule_expression_stop  = v.schedule_expression_stop
        description               = try(v.description, null)
        ecs_cluster               = v.ecs_cluster
        task_definition           = v.task_definition
      }
      if rule_name != ""
    ]
  ])

  # 3. Create final map for for_each
  #    Key format: "tfvars_key-rule_name" to ensure uniqueness
  final_schedules = {
    for item in local.resolved_schedules_flat : "${item.key}-${item.rule_name}" => item
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for DISABLE (stop ECS task rule).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop" {
  for_each = {
    for k, v in local.final_schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null
  }

  description = try(each.value.description, var.description, "Disable EventBridge rule ${each.value.rule_name} (Task: ${each.value.task_definition})")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.rule_name}-disable-rule", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:eventbridge:disableRule"
    role_arn = var.role_arn

    input = jsonencode({
      Name = each.value.rule_name
    })

    retry_policy {
      maximum_event_age_in_seconds = var.retry_max_age_seconds
      maximum_retry_attempts       = var.retry_max_attempts
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for ENABLE (start ECS task rule).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start" {
  for_each = {
    for k, v in local.final_schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null
  }

  description = try(each.value.description, var.description, "Enable EventBridge rule ${each.value.rule_name} (Task: ${each.value.task_definition})")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.rule_name}-enable-rule", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:eventbridge:enableRule"
    role_arn = var.role_arn

    input = jsonencode({
      Name = each.value.rule_name
    })

    retry_policy {
      maximum_event_age_in_seconds = var.retry_max_age_seconds
      maximum_retry_attempts       = var.retry_max_attempts
    }
  }
}
