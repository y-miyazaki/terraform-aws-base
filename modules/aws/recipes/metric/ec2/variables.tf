#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of EC2. Defaults true."
  default     = true
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # MetadataNoToken threshold (unit=Count)
    enabled_metadata_no_token = bool
    metadata_no_token         = number
    # CPUCreditUsage threshold (unit=Count)
    enabled_cpu_credit_usage = bool
    cpu_credit_usage         = number
    # StatusCheckFailed threshold (unit=Count)
    enabled_status_check_failed = bool
    status_check_failed         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in EC2."
  default = {
    enabled_cpu_utilization     = true
    cpu_utilization             = 80
    enabled_metadata_no_token   = true
    metadata_no_token           = 1
    enabled_cpu_credit_usage    = true
    cpu_credit_usage            = 5
    enabled_status_check_failed = true
    status_check_failed         = 1
  }
}
variable "dimensions" {
  type        = list(map(any))
  description = "(Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
}
variable "name_prefix" {
  type        = string
  description = "(Required) Center for Internet Security CloudWatch Filter/Alarm name prefix."
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
