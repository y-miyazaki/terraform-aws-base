#--------------------------------------------------------------
# Data source for auto-discovery of RDS clusters
#--------------------------------------------------------------
data "aws_rds_clusters" "this" {
  count = var.is_enabled && var.create_auto_schedules ? 1 : 0

  filter {
    name = "engine"
    values = [
      "aurora-mysql",
      "aurora-postgresql"
    ]
  }
}

#--------------------------------------------------------------
# Locals - Parse discovered data into schedule map format
#--------------------------------------------------------------
locals {
  # Parse auto-discovered RDS schedules into map format for scheduler_helper
  # Key: db_cluster_identifier, Value: { db_cluster_identifier }
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules ? {
    for cluster_id in try(data.aws_rds_clusters.this[0].cluster_identifiers, []) : cluster_id => {
      db_cluster_identifier = cluster_id
    }
    if cluster_id != ""
  } : {}
}
