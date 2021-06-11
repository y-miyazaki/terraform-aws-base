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
    # (Required) Error401Rate threshold (unit=%)
    error_401_rate = number
    # (Required) Error403Rate threshold (unit=%)
    error_403_rate = number
    # (Required) Error404Rate threshold (unit=%)
    error_404_rate = number
    # (Required) Error502Rate threshold (unit=%)
    error_502_rate = number
    # (Required) Error503Rate threshold (unit=%)
    error_503_rate = number
    # (Required) Error504Rate threshold (unit=%)
    error_504_rate = number
    # (Required) CacheHitRate threshold (unit=%)
    cache_hit_rate = number
    # (Required) OriginLatency threshold (unit=Milliseconds)
    origin_latency = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in CloudFront."
  default = {
    error_401_rate = 1
    error_403_rate = 1
    error_404_rate = 1
    error_502_rate = 1
    error_503_rate = 1
    error_504_rate = 1
    cache_hit_rate = 70
    origin_latency = 10000
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
