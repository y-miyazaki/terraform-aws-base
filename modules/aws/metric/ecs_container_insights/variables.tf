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
    }
  )
  description = "(Optional) Set the threshold for each Metric in Lambda."
  default = {
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    enabled_memory_utilization = true
    memory_utilization         = 80
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
