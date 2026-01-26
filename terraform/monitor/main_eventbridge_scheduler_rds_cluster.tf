#--------------------------------------------------------------
# Create RDS Stop & Start Scheduler
#--------------------------------------------------------------
module "eventbridge_rds_cluster" {
  source = "../../modules/aws/eventbridge/rds_cluster"

  is_enabled                  = var.eventbridge.rds_cluster.is_enabled
  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_stop    = var.eventbridge.rds_cluster.schedule_expression_stop
  schedule_expression_start   = var.eventbridge.rds_cluster.schedule_expression_start
  description                 = try(var.eventbridge.rds_cluster.description, null)
  create_auto_schedules       = var.eventbridge.rds_cluster.create_auto_schedules
  auto_schedules_exclude_list = var.eventbridge.rds_cluster.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.rds_cluster.auto_schedules_include_list
  schedules                   = var.eventbridge.rds_cluster.schedules
}
