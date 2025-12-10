#--------------------------------------------------------------
# Create RDS Stop & Start Scheduler
#--------------------------------------------------------------
module "eventbridge_rds_cluster" {
  for_each = var.eventbridge.rds_cluster.is_enabled ? var.eventbridge.rds_cluster.schedules : {}

  source = "../../modules/aws/eventbridge/rds_cluster"

  name_prefix               = "${var.name_prefix}${each.key}-"
  schedule_expression_stop  = each.value.schedule_expression_stop
  schedule_expression_start = each.value.schedule_expression_start
  role_arn                  = module.aws_iam_role_eventbridge.arn
  db_cluster_identifier     = each.value.db_cluster_identifier
}
