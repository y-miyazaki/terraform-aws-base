#--------------------------------------------------------------
# Create Redshift Pause & Resume Scheduler
#--------------------------------------------------------------
module "eventbridge_redshift" {
  source = "../../modules/aws/eventbridge/redshift"

  is_enabled = var.eventbridge.redshift.is_enabled
  region     = var.region.primary

  auto_schedules_exclude_list = var.eventbridge.redshift.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.redshift.auto_schedules_include_list
  create_auto_schedules       = var.eventbridge.redshift.create_auto_schedules
  description                 = try(var.eventbridge.redshift.description, null)
  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_start   = var.eventbridge.redshift.schedule_expression_start
  schedule_expression_stop    = var.eventbridge.redshift.schedule_expression_stop
  schedules                   = var.eventbridge.redshift.schedules
}
