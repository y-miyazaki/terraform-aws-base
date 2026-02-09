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
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    enabled_memory_utilization = bool
    memory_utilization         = number
    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)
    enabled_network_rx_bytes = bool
    network_rx_bytes         = number
    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)
    enabled_network_tx_bytes = bool
    network_tx_bytes         = number
    # (Optional) StorageReadBytes threshold (unit=Bytes)
    enabled_storage_read_bytes = bool
    storage_read_bytes         = number
    # (Optional) StorageWriteBytes threshold (unit=Bytes)
    enabled_storage_write_bytes = bool
    storage_write_bytes         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in ECS Container Insights."
  default = {
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    enabled_memory_utilization = true
    memory_utilization         = 80
    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)
    enabled_network_rx_bytes = false
    network_rx_bytes         = 10485760 # 10 MB/s
    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)
    enabled_network_tx_bytes = false
    network_tx_bytes         = 10485760 # 10 MB/s
    # (Optional) StorageReadBytes threshold (unit=Bytes)
    enabled_storage_read_bytes = false
    storage_read_bytes         = 104857600 # 100 MB
    # (Optional) StorageWriteBytes threshold (unit=Bytes)
    enabled_storage_write_bytes = false
    storage_write_bytes         = 104857600 # 100 MB
  }
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
