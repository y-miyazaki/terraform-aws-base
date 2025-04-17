#--------------------------------------------------------------
# Create RDS Stop & Start Scheduler
#--------------------------------------------------------------
module "eventbridge_rds_cluster" {
  count                     = var.eventbridge.rds_cluster.is_enabled ? 1 : 0
  source                    = "../../modules/aws/eventbridge/rds_cluster"
  name_prefix               = var.name_prefix
  schedule_expression_stop  = var.eventbridge.rds_cluster.schedule_expression_stop
  schedule_expression_start = var.eventbridge.rds_cluster.schedule_expression_start
  role_arn                  = module.aws_iam_role_eventbrdige.arn
  db_cluster_identifier     = var.eventbridge.rds_cluster.db_cluster_identifier
}
