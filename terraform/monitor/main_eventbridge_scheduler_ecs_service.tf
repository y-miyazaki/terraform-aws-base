#--------------------------------------------------------------
# Create ECS Service Stop & Start Scheduler
#--------------------------------------------------------------
module "eventbridge_ecs_service" {
  source = "../../modules/aws/eventbridge/ecs_service"

  is_enabled                  = var.eventbridge.ecs_service.is_enabled
  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_stop    = var.eventbridge.ecs_service.schedule_expression_stop
  schedule_expression_start   = var.eventbridge.ecs_service.schedule_expression_start
  description                 = try(var.eventbridge.ecs_service.description, null)
  create_auto_schedules       = var.eventbridge.ecs_service.create_auto_schedules
  auto_schedules_exclude_list = var.eventbridge.ecs_service.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.ecs_service.auto_schedules_include_list
  autoscaling_min_capacity    = var.eventbridge.ecs_service.autoscaling_min_capacity
  autoscaling_max_capacity    = var.eventbridge.ecs_service.autoscaling_max_capacity
  desired_count               = var.eventbridge.ecs_service.desired_count
  schedules                   = var.eventbridge.ecs_service.schedules
}
