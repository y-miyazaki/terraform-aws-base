#--------------------------------------------------------------
# Data source for auto-discovery of Redshift clusters
#--------------------------------------------------------------
data "external" "list" {
  count = var.is_enabled && var.create_auto_schedules ? 1 : 0

  program = ["bash", "${path.module}/scripts/list.sh"]
}

#--------------------------------------------------------------
# Locals - Parse discovered data into schedule map format
#--------------------------------------------------------------
locals {
  # Parse cluster identifiers from external data source
  discovered_cluster_identifiers = var.is_enabled && var.create_auto_schedules && length(data.external.list) > 0 ? split(",", data.external.list[0].result.list) : []

  # Parse auto-discovered Redshift schedules into map format for scheduler_helper
  # Key: cluster_identifier, Value: { cluster_identifier }
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules ? {
    for cluster_id in local.discovered_cluster_identifiers : cluster_id => {
      cluster_identifier = cluster_id
    }
    if cluster_id != ""
  } : {}
}
