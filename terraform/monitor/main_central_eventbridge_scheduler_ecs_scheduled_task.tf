#--------------------------------------------------------------
# Create ECS Scheduled Task (EventBridge Rule) Enable & Disable Scheduler
#--------------------------------------------------------------
module "eventbridge_ecs_scheduled_task" {
  source = "../../modules/aws/eventbridge/ecs_scheduled_task"

  is_enabled = var.eventbridge.ecs_scheduled_task.is_enabled
  region     = var.region.primary

  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_stop    = var.eventbridge.ecs_scheduled_task.schedule_expression_stop
  schedule_expression_start   = var.eventbridge.ecs_scheduled_task.schedule_expression_start
  description                 = try(var.eventbridge.ecs_scheduled_task.description, null)
  create_auto_schedules       = var.eventbridge.ecs_scheduled_task.create_auto_schedules
  auto_schedules_exclude_list = var.eventbridge.ecs_scheduled_task.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.ecs_scheduled_task.auto_schedules_include_list
  schedules                   = var.eventbridge.ecs_scheduled_task.schedules
}
