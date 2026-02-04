#--------------------------------------------------------------
# Auto-discovery of EventBridge rules targeting ECS tasks using external script
# Uses external script to discover EventBridge rules when create_auto_schedules is enabled.
#--------------------------------------------------------------
data "external" "scheduler_list" {
  # Always run if module is enabled, as we need discovery to resolve rule names from Cluster/Task
  count = var.is_enabled ? 1 : 0

  program = ["bash", "${path.module}/scripts/list.sh"]
}

#--------------------------------------------------------------
# Locals - Parse discovered data into schedule map format
#--------------------------------------------------------------
locals {
  # The external script returns a map where:
  # Key: "ClusterName/TaskDefinitionFamily"
  # Value: "RuleName1,RuleName2" (comma-separated)
  # Handle empty result safely
  discovered_rules_map = var.is_enabled ? data.external.scheduler_list[0].result : {}

  # Generate auto-discovered schedules map if enabled
  # Key: "ClusterName/TaskDefinitionFamily"
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules ? {
    for key, rule_names in local.discovered_rules_map : key => {
      ecs_cluster     = try(split("/", key)[0], "")
      task_definition = try(split("/", key)[1], "")
    }
    if length(split("/", key)) == 2
  } : {}
}
