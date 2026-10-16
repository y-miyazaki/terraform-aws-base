#--------------------------------------------------------------
# For RDS Cluster metric
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a CloudWatch Alarm resource.
#--------------------------------------------------------------
module "aws_metric_rds_cluster" {
  source = "../../modules/aws/metric/rds_cluster"

  is_enabled = var.metric_resource_rds_cluster.is_enabled
  region     = var.region.primary

  alarm_actions                = [module.aws_sns_subscription_lambda_metric.arn]
  auto_dimensions_exclude_list = var.metric_resource_rds_cluster.auto_dimensions_exclude_list
  auto_dimensions_include_list = var.metric_resource_rds_cluster.auto_dimensions_include_list
  create_auto_dimensions       = var.metric_resource_rds_cluster.create_auto_dimensions
  dimensions                   = var.metric_resource_rds_cluster.dimensions
  is_aurora                    = var.metric_resource_rds_cluster.is_aurora
  is_mysql                     = var.metric_resource_rds_cluster.is_mysql
  is_postgresql                = var.metric_resource_rds_cluster.is_postgresql
  name_prefix                  = var.name_prefix
  ok_actions                   = [module.aws_sns_subscription_lambda_metric.arn]
  period                       = var.metric_resource_rds_cluster.period
  threshold                    = var.metric_resource_rds_cluster.threshold
  threshold_override           = var.metric_resource_rds_cluster.threshold_override

  tags = var.tags
}
