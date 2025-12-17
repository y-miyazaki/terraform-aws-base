# EventBridge Scheduler schedule groups list data source
# Provides auto-discovery of schedule groups for dimension-based metrics

data "external" "list" {
  count = var.create_auto_dimensions ? 1 : 0

  program = ["bash", "${path.module}/scripts/list.sh"]
}

locals {
  # Split the comma-separated list into a list of schedule group names
  list_schedule_group = var.create_auto_dimensions && length(data.external.list) > 0 ? (
    data.external.list[0].result.list_schedule_group != "" ? split(",", data.external.list[0].result.list_schedule_group) : []
  ) : []
}
