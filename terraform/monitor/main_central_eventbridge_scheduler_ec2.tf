#--------------------------------------------------------------
# Create EC2 Instance Stop & Start Scheduler (Example)
#--------------------------------------------------------------
module "eventbridge_ec2" {
  source = "../../modules/aws/eventbridge/ec2"

  is_enabled = var.eventbridge.ec2.is_enabled
  region     = var.region.primary

  name_prefix                 = var.name_prefix
  role_arn                    = module.aws_iam_role_eventbridge.arn
  schedule_expression_stop    = var.eventbridge.ec2.schedule_expression_stop
  schedule_expression_start   = var.eventbridge.ec2.schedule_expression_start
  description                 = try(var.eventbridge.ec2.description, null)
  create_auto_schedules       = var.eventbridge.ec2.create_auto_schedules
  auto_schedules_exclude_list = var.eventbridge.ec2.auto_schedules_exclude_list
  auto_schedules_include_list = var.eventbridge.ec2.auto_schedules_include_list
  schedules                   = var.eventbridge.ec2.schedules
}
