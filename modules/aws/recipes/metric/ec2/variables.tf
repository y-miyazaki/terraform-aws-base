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
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = number
    # (Required) MetadataNoToken threshold (unit=Count)
    metadata_no_token = number
    # (Required) CPUCreditUsage threshold (unit=Count)
    cpu_credit_usage = number
    # (Required) StatusCheckFailed threshold (unit=Count)
    status_check_failed = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in EC2."
  default = {
    cpu_utilization     = 80
    metadata_no_token   = 1
    cpu_credit_usage    = 5
    status_check_failed = 1
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
