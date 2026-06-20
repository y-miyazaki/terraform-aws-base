#--------------------------------------------------------------
# Local Variables
#--------------------------------------------------------------
locals {
  # Whether global region differs from primary (need separate global resources)
  is_enabled_global = var.region.global != var.region.primary

  # Regions where monitor infrastructure (KMS, VPC, Lambda, DynamoDB, Delivery) is deployed.
  # When primary == global, only one set is created.
  monitor_regions = local.is_enabled_global ? {
    primary = var.region.primary
    global  = var.region.global
    } : {
    primary = var.region.primary
  }
}
