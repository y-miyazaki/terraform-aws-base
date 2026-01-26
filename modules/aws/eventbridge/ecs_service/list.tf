#--------------------------------------------------------------
# Auto-discovery of ECS services
# Uses external script to discover ECS clusters and services when create_auto_schedules is enabled.
#--------------------------------------------------------------
data "external" "list" {
  count = var.is_enabled && var.create_auto_schedules ? 1 : 0

  program = ["bash", "${path.module}/scripts/list.sh"]
}

#--------------------------------------------------------------
# Locals - Parse discovered data into schedule map format
#--------------------------------------------------------------
locals {
  # Parse CSV data from script into map format
  # Script returns: list_ecs_cluster, list_ecs_service, list_desired_count, list_has_autoscaling, list_autoscaling_min, list_autoscaling_max (comma-separated)
  # Note: has_autoscaling flag (0 or 1) determines whether AutoScaling is configured, regardless of min/max values
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules && try(data.external.list[0].result.list_ecs_cluster, "") != "" ? {
    for idx, cluster in split(",", data.external.list[0].result.list_ecs_cluster) : "${cluster}-${split(",", data.external.list[0].result.list_ecs_service)[idx]}" => {
      ecs_cluster = cluster
      ecs_service = split(",", data.external.list[0].result.list_ecs_service)[idx]
      # Use null for desired_count so var.desired_count is used via coalesce in main.tf
      desired_count = null
      # has_autoscaling flag: 1 = AutoScaling configured, 0 = not configured
      has_autoscaling = tonumber(split(",", data.external.list[0].result.list_has_autoscaling)[idx])
      # Use discovered autoscaling values (may be 0 even when has_autoscaling=1)
      autoscaling_min_capacity = tonumber(split(",", data.external.list[0].result.list_autoscaling_min)[idx])
      autoscaling_max_capacity = tonumber(split(",", data.external.list[0].result.list_autoscaling_max)[idx])
    }
    if cluster != "" && split(",", data.external.list[0].result.list_ecs_service)[idx] != ""
  } : {}
}
