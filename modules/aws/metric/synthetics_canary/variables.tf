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
    http_2xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) 4xx threshold (unit=Count)
    http_4xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) 5xx threshold (unit=Count)
    http_5xx = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Duration threshold (unit=Milliseconds)
    duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DurationDryRun threshold (unit=Milliseconds)
    duration_dry_run = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Failed threshold (unit=Count)
    failed = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) FailedRequests threshold (unit=Count)
    failed_requests = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) SuccessPercent threshold (unit=Percent)
    success_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) SuccessPercentDryRun threshold (unit=Percent)
    success_percent_dry_run = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) SuccessPercentWithRetries threshold (unit=Percent)
    success_percent_with_retries = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
    visual_monitoring_success_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in Synthetics."
  default = {
    # (Required) 2xx threshold (unit=Count)
    http_2xx = { enabled = false, value = 100 }
    # (Required) 4xx threshold (unit=Count)
    http_4xx = { enabled = true, value = 1 }
    # (Required) 5xx threshold (unit=Count)
    http_5xx = { enabled = true, value = 1 }
    # (Required) Duration threshold (unit=Milliseconds)
    duration = { enabled = true, value = 30000 }
    # (Required) DurationDryRun threshold (unit=Milliseconds)
    duration_dry_run = { enabled = false, value = 30000 }
    # (Required) Failed threshold (unit=Count)
    failed = { enabled = true, value = 1 }
    # (Required) FailedRequests threshold (unit=Count)
    failed_requests = { enabled = false, value = 1 }
    # (Required) SuccessPercent threshold (unit=Percent)
    success_percent = { enabled = true, value = 99 }
    # (Required) SuccessPercentDryRun threshold (unit=Percent)
    success_percent_dry_run = { enabled = false, value = 99 }
    # (Required) SuccessPercentWithRetries threshold (unit=Percent)
    success_percent_with_retries = { enabled = false, value = 99 }
    # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
    visual_monitoring_success_percent = { enabled = false, value = 99 }
  }
}

variable "threshold_override" {
  type = map(object({
    # 2xx threshold (unit=Count)
    http_2xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # 4xx threshold (unit=Count)
    http_4xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # 5xx threshold (unit=Count)
    http_5xx = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Duration threshold (unit=Milliseconds)
    duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DurationDryRun threshold (unit=Milliseconds)
    duration_dry_run = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Failed threshold (unit=Count)
    failed = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # FailedRequests threshold (unit=Count)
    failed_requests = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SuccessPercent threshold (unit=Percent)
    success_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SuccessPercentDryRun threshold (unit=Percent)
    success_percent_dry_run = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SuccessPercentWithRetries threshold (unit=Percent)
    success_percent_with_retries = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # VisualMonitoringSuccessPercent threshold (unit=Percent)
    visual_monitoring_success_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Map of resource name to threshold overrides. Key is CanaryName (exact match), value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
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

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
