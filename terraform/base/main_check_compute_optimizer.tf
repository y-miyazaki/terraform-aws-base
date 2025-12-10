#--------------------------------------------------------------
# AWS Compute Optimizer Configuration
#--------------------------------------------------------------
#--------------------------------------------------------------
# Enables AWS Compute Optimizer to analyze resource utilization
# and provide recommendations for optimal EC2 instance types,
# Auto Scaling groups, EBS volumes, and Lambda functions.
#
# This service helps optimize costs and performance by identifying
# underutilized or overprovisioned resources.
#--------------------------------------------------------------
module "aws_compute_optimizer" {
  source     = "../../modules/aws/compute_optimizer"
  is_enabled = var.compute_optimizer.is_enabled
}
