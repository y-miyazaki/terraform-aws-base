#--------------------------------------------------------------
# For RDS Cluster metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_rds_cluster" {
  source                       = "../../modules/aws/metric/rds_cluster"
  is_enabled                   = var.metric_resource_rds_cluster.is_enabled
  is_aurora                    = var.metric_resource_rds_cluster.is_aurora
  is_mysql                     = var.metric_resource_rds_cluster.is_mysql
  is_postgresql                = var.metric_resource_rds_cluster.is_postgresql
  period                       = var.metric_resource_rds_cluster.period
  create_auto_dimensions       = var.metric_resource_rds_cluster.create_auto_dimensions
  auto_dimensions_exclude_list = var.metric_resource_rds_cluster.auto_dimensions_exclude_list
  dimensions                   = var.metric_resource_rds_cluster.dimensions
  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  name_prefix                  = var.name_prefix
  tags                         = var.tags
}
