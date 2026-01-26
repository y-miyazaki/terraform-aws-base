#--------------------------------------------------------------
# Data source for auto-discovery of EC2 instances
#--------------------------------------------------------------
data "aws_instances" "this" {
  instance_state_names = [
    "pending",
    "running",
    "stopped",
    "stopping",
  ]
}

data "aws_instance" "this" {
  for_each = var.is_enabled && var.create_auto_schedules ? toset(data.aws_instances.this.ids) : []

  instance_id = each.value
}

#--------------------------------------------------------------
# Locals - Parse discovered data into schedule map format
#--------------------------------------------------------------
locals {
  # Parse auto-discovered EC2 schedules into map format for scheduler_helper
  # Key: instance_id, Value: { instance_id, instance_name }
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules ? {
    for id in data.aws_instances.this.ids : id => {
      instance_id   = id
      instance_name = try(data.aws_instance.this[id].tags["Name"], null)
    }
    if id != ""
  } : {}
}
