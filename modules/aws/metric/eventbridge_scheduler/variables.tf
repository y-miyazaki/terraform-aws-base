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
    enabled_invocation_attempt_count = bool
    invocation_attempt_count         = number
    # TargetErrorCount threshold (unit=Count)
    enabled_target_error_count = bool
    target_error_count         = number
    # TargetErrorThrottledCount threshold (unit=Count)
    enabled_target_error_throttled_count = bool
    target_error_throttled_count         = number
    # InvocationThrottleCount threshold (unit=Count)
    enabled_invocation_throttle_count = bool
    invocation_throttle_count         = number
    # InvocationDroppedCount threshold (unit=Count)
    enabled_invocation_dropped_count = bool
    invocation_dropped_count         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in EventBridge Scheduler."
  default = {
    enabled_invocation_attempt_count     = false
    invocation_attempt_count             = 0
    enabled_target_error_count           = true
    target_error_count                   = 10
    enabled_target_error_throttled_count = true
    target_error_throttled_count         = 1
    enabled_invocation_throttle_count    = true
    invocation_throttle_count            = 1
    enabled_invocation_dropped_count     = true
    invocation_dropped_count             = 1
  }
}
variable "dimensions" {
  type        = list(map(any))
  description = "(Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
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
