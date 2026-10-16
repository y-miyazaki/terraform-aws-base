#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of EventBridge Scheduler. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # InvocationAttemptCount threshold (unit=Count)
    # Monitor total invocation attempts (typically disabled for regular monitoring)
    invocation_attempt_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # TargetErrorCount threshold (unit=Count)
    # Alert on target execution errors (recommended: 1 for immediate notification)
    target_error_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # TargetErrorThrottledCount threshold (unit=Count)
    # Alert on throttling errors from target services
    target_error_throttled_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # InvocationThrottleCount threshold (unit=Count)
    # Alert on scheduler throttling due to rate limits
    invocation_throttle_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # InvocationDroppedCount threshold (unit=Count)
    # Alert on dropped invocations due to system issues
    invocation_dropped_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in EventBridge Scheduler."
  default = {
    invocation_attempt_count     = { enabled = false, value = 0 }
    target_error_count           = { enabled = true, value = 10 }
    target_error_throttled_count = { enabled = true, value = 1 }
    invocation_throttle_count    = { enabled = true, value = 1 }
    invocation_dropped_count     = { enabled = true, value = 1 }
  }
}

variable "threshold_override" {
  type = map(object({
    # InvocationAttemptCount threshold (unit=Count)
    # Monitor total invocation attempts (typically disabled for regular monitoring)
    invocation_attempt_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetErrorCount threshold (unit=Count)
    # Alert on target execution errors (recommended: 1 for immediate notification)
    target_error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TargetErrorThrottledCount threshold (unit=Count)
    # Alert on throttling errors from target services
    target_error_throttled_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # InvocationThrottleCount threshold (unit=Count)
    # Alert on scheduler throttling due to rate limits
    invocation_throttle_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # InvocationDroppedCount threshold (unit=Count)
    # Alert on dropped invocations due to system issues
    invocation_dropped_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Per-schedule-group threshold overrides. Key is the schedule group name. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
  default     = []
}
#--------------------------------------------------------------
# Auto-discovery variables
#--------------------------------------------------------------
variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Create dimensions automatically from EventBridge Scheduler schedule groups."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) List of schedule group names to exclude from auto-discovered dimensions."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) List of schedule group names to include in auto-discovered dimensions. If empty, all discovered schedule groups are included."
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
