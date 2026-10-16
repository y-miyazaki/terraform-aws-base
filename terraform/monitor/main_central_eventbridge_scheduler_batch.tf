#--------------------------------------------------------------
# Create AWS Batch Job Queue Enable & Disable Scheduler
#--------------------------------------------------------------
module "eventbridge_batch" {
  source = "../../modules/aws/eventbridge/batch"

  is_enabled = var.eventbridge.batch.is_enabled
  region     = var.region.primary

  auto_schedules_exclude_list = var.eventbridge.batch.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.batch.auto_schedules_include_list
  create_auto_schedules       = var.eventbridge.batch.create_auto_schedules
  description                 = try(var.eventbridge.batch.description, null)
  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_start   = var.eventbridge.batch.schedule_expression_start
  schedule_expression_stop    = var.eventbridge.batch.schedule_expression_stop
  schedules                   = var.eventbridge.batch.schedules
}
