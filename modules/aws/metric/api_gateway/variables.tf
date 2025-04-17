#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of API Gateway. Defaults true."
  default     = true
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # 4XXerror threshold (unit=%)
    enabled_error4XX = bool
    error4XX         = number
    # 5XXerror threshold (unit=%)
    enabled_error5XX = bool
    error5XX         = number
    # Latency threshold (unit=Milliseconds)
    enabled_latency = bool
    latency         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in API Gateway."
  default = {
    enabled_error4XX = true
    error4XX         = 1
    enabled_error5XX = true
    error5XX         = 1
    enabled_latency  = true
    latency          = 10000
  }
}
variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of API Gateways to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}
variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of API Gateways will be automatically registered, but at that time, specify the API Gateway name you want to exclude using partial match."
  default     = []
}
variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) If create_auto_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
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
  default     = []
}
variable "insufficient_data_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
