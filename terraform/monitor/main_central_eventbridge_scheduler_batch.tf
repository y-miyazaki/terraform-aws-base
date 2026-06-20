#--------------------------------------------------------------
# Create AWS Batch Job Queue Enable & Disable Scheduler
#--------------------------------------------------------------
module "eventbridge_batch" {
  source = "../../modules/aws/eventbridge/batch"

  is_enabled = var.eventbridge.batch.is_enabled
  region     = var.region.primary

  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_stop    = var.eventbridge.batch.schedule_expression_stop
  schedule_expression_start   = var.eventbridge.batch.schedule_expression_start
  description                 = try(var.eventbridge.batch.description, null)
  create_auto_schedules       = var.eventbridge.batch.create_auto_schedules
  auto_schedules_exclude_list = var.eventbridge.batch.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.batch.auto_schedules_include_list
  schedules                   = var.eventbridge.batch.schedules
}
