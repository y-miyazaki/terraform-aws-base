#--------------------------------------------------------------
# Module: aws/metric/elb
# Purpose: Provide CloudWatch metric alarms for Elastic Load Balancers (ALB/NLB) with optional auto-discovery.
# Notes: Unified tagging; thresholds configurable; auto discovery filters via include/exclude lists; supports both ALB and NLB.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Auto-discovery filter module
#--------------------------------------------------------------
module "helper" {
  source     = "../../_internal/metric_helper"
  is_enabled = var.is_enabled

  create_auto        = var.create_auto_dimensions
  source_list        = data.aws_lbs.this.arns
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
  dimension_key      = "LoadBalancer"
  base_threshold     = var.threshold
  threshold_override = var.threshold_override
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  url = "https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html"

  # Use filtered results from helper module
  list                 = module.helper.list
  effective_thresholds = module.helper.effective_thresholds
}
