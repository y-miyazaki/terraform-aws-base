#--------------------------------------------------------------
# Module: aws/eventbridge/ecs_service
# Purpose: Schedule start and stop of multiple ECS Services using EventBridge Scheduler with auto-discovery support.
# Notes: Creates separate schedules for start/stop if expressions provided; supports auto-discovery of ECS services.
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
  primary_key                 = "ecs_service"
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  schedules = module.scheduler_helper.schedules
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for STOP (DesiredCount only when AutoScaling disabled).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null && try(v.has_autoscaling, 0) == 0
  }

  description = try(each.value.description, var.description, "Stop ECS service ${each.value.ecs_service}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.ecs_service}-stop-ecs-service", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = var.role_arn

    input = jsonencode({
      Cluster      = each.value.ecs_cluster
      Service      = each.value.ecs_service
      DesiredCount = 0
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource to set Application Auto Scaling to 0 for STOP (when AutoScaling enabled).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop_autoscaling" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_stop != null && try(v.has_autoscaling, 0) == 1
  }

  description = "Set autoscaling min/max capacity to 0 for ECS service ${each.value.ecs_service}"
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.ecs_service}-stop-autoscaling", 0, 63)
  schedule_expression = each.value.schedule_expression_stop
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:applicationautoscaling:registerScalableTarget"
    role_arn = var.role_arn

    input = jsonencode({
      ServiceNamespace  = "ecs"
      ResourceId        = "service/${each.value.ecs_cluster}/${each.value.ecs_service}"
      ScalableDimension = "ecs:service:DesiredCount"
      MinCapacity       = 0
      MaxCapacity       = 0
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource for START (DesiredCount only when AutoScaling disabled).
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null && try(v.has_autoscaling, 0) == 0
  }

  description = try(each.value.description, var.description, "Start ECS service ${each.value.ecs_service}")
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.ecs_service}-start-ecs-service", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = var.role_arn

    input = jsonencode({
      Cluster      = each.value.ecs_cluster
      Service      = each.value.ecs_service
      DesiredCount = coalesce(each.value.desired_count, var.desired_count)
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource to restore Application Auto Scaling min capacity for START.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start_autoscaling" {
  for_each = {
    for k, v in local.schedules : k => v
    if var.is_enabled && v.schedule_expression_start != null && try(v.has_autoscaling, 0) == 1
  }

  description = "Restore autoscaling min/max capacity for ECS service ${each.value.ecs_service}"
  flexible_time_window {
    mode = "OFF"
  }
  name                = substr("${var.name_prefix}${each.value.ecs_service}-start-autoscaling", 0, 63)
  schedule_expression = each.value.schedule_expression_start
  state               = "ENABLED"
  target {
    arn      = "arn:aws:scheduler:::aws-sdk:applicationautoscaling:registerScalableTarget"
    role_arn = var.role_arn

    input = jsonencode({
      ServiceNamespace  = "ecs"
      ResourceId        = "service/${each.value.ecs_cluster}/${each.value.ecs_service}"
      ScalableDimension = "ecs:service:DesiredCount"
      # MinCapacity: Use discovered value if > 0, otherwise use var.autoscaling_min_capacity, minimum 1
      MinCapacity = max(1, try(each.value.autoscaling_min_capacity, 0) > 0 ? each.value.autoscaling_min_capacity : var.autoscaling_min_capacity)
      # MaxCapacity: Use discovered value if > 0, otherwise use var.autoscaling_max_capacity, at least equal to MinCapacity
      MaxCapacity = max(
        max(1, try(each.value.autoscaling_min_capacity, 0) > 0 ? each.value.autoscaling_min_capacity : var.autoscaling_min_capacity),
        try(each.value.autoscaling_max_capacity, 0) > 0 ? each.value.autoscaling_max_capacity : var.autoscaling_max_capacity
      )
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
}
