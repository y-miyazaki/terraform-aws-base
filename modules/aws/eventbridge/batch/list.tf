#--------------------------------------------------------------
# Auto-discovery of AWS Batch job queues using external script
# Uses external script to discover job queues when create_auto_schedules is enabled.
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
  # Script returns: list_job_queue (comma-separated)
  auto_discovered_schedules = var.is_enabled && var.create_auto_schedules && try(data.external.list[0].result.list_job_queue, "") != "" ? {
    for idx, job_queue in split(",", data.external.list[0].result.list_job_queue) : job_queue => {
      job_queue = job_queue
    }
    if job_queue != ""
  } : {}
}
