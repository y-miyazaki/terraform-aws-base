#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Lambda. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    memory_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)
    network_rx_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)
    network_tx_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Optional) StorageReadBytes threshold (unit=Bytes)
    storage_read_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Optional) StorageWriteBytes threshold (unit=Bytes)
    storage_write_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in ECS Container Insights."
  default = {
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    memory_utilization = { enabled = true, value = 80 }
    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)
    network_rx_bytes = { enabled = false, value = 10485760 } # 10 MB/s
    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)
    network_tx_bytes = { enabled = false, value = 10485760 } # 10 MB/s
    # (Optional) StorageReadBytes threshold (unit=Bytes)
    storage_read_bytes = { enabled = false, value = 104857600 } # 100 MB
    # (Optional) StorageWriteBytes threshold (unit=Bytes)
    storage_write_bytes = { enabled = false, value = 104857600 } # 100 MB
  }
}

variable "threshold_override" {
  type = map(object({
    # CpuUtilized/CpuReserved threshold (unit=Percent)
    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MemoryUtilized/MemoryReserved threshold (unit=Percent)
    memory_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkRxBytes threshold (unit=Bytes/Second)
    network_rx_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkTxBytes threshold (unit=Bytes/Second)
    network_tx_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StorageReadBytes threshold (unit=Bytes)
    storage_read_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StorageWriteBytes threshold (unit=Bytes)
    storage_write_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Per-TaskDefinitionFamily threshold overrides. Key is the TaskDefinitionFamily (exact match), or the reserved key \"default\" when dimensions is empty. NOTE: do not use \"default\" as an actual TaskDefinitionFamily in dimensions; it would be indistinguishable from the reserved key. Value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "(Required) CloudWatch Filter/Alarm name prefix."
}

variable "alarm_actions" {
  type        = list(string)
  description = "(Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
