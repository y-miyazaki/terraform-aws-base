#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Synthetics Canary. Defaults true."
  default     = true
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # (Required) 2xx threshold (unit=Count)
    enabled_2xx = bool
    http_2xx    = number
    # (Required) 4xx threshold (unit=Count)
    enabled_4xx = bool
    http_4xx    = number
    # (Required) 5xx threshold (unit=Count)
    enabled_5xx = bool
    http_5xx    = number
    # (Required) Duration threshold (unit=Milliseconds)
    enabled_duration = bool
    duration         = number
    # (Required) DurationDryRun threshold (unit=Milliseconds)
    enabled_duration_dry_run = bool
    duration_dry_run         = number
    # (Required) Failed threshold (unit=Count)
    enabled_failed = bool
    failed         = number
    # (Required) FailedRequests threshold (unit=Count)
    enabled_failed_requests = bool
    failed_requests         = number
    # (Required) SuccessPercent threshold (unit=Percent)
    enabled_success_percent = bool
    success_percent         = number
    # (Required) SuccessPercentDryRun threshold (unit=Percent)
    enabled_success_percent_dry_run = bool
    success_percent_dry_run         = number
    # (Required) SuccessPercentWithRetries threshold (unit=Percent)
    enabled_success_percent_with_retries = bool
    success_percent_with_retries         = number
    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
    enabled_visual_monitoring_success_percent = bool
    visual_monitoring_success_percent         = number
  })
  description = "(Optional) Set the threshold for each Metric in Synthetics."
  default = {
    # (Required) 2xx threshold (unit=Count)
    enabled_2xx = false
    http_2xx    = 100
    # (Required) 4xx threshold (unit=Count)
    enabled_4xx = true
    http_4xx    = 1
    # (Required) 5xx threshold (unit=Count)
    enabled_5xx = true
    http_5xx    = 1
    # (Required) Duration threshold (unit=Milliseconds)
    enabled_duration = true
    duration         = 30000
    # (Required) DurationDryRun threshold (unit=Milliseconds)
    enabled_duration_dry_run = false
    duration_dry_run         = 30000
    # (Required) Failed threshold (unit=Count)
    enabled_failed = true
    failed         = 1
    # (Required) FailedRequests threshold (unit=Count)
    enabled_failed_requests = false
    failed_requests         = 1
    # (Required) SuccessPercent threshold (unit=Percent)
    enabled_success_percent = true
    success_percent         = 99
    # (Required) SuccessPercentDryRun threshold (unit=Percent)
    enabled_success_percent_dry_run = false
    success_percent_dry_run         = 99
    # (Required) SuccessPercentWithRetries threshold (unit=Percent)
    enabled_success_percent_with_retries = false
    success_percent_with_retries         = 99
    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
    enabled_visual_monitoring_success_percent = false
    visual_monitoring_success_percent         = 99
  }
}
variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of Synthetics Canaries to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}
variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, specify the canary names you want to exclude using partial match."
  default     = []
}
variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, specify the canary names you want to include using partial match. If empty, all canaries will be included (except excluded ones)."
  default     = []
}
variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) If create_auto_dimensions is set to false, the dimensions for the alarm's associated metric. Required when create_auto_dimensions=false."
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
