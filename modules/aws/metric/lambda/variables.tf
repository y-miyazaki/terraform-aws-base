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
    # AsyncEventAge threshold (unit=Milliseconds)
    async_event_age = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # AsyncEventsDropped threshold (unit=Count)
    async_events_dropped = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # AsyncEventsReceived threshold (unit=Count)
    async_events_received = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ClaimedAccountConcurrency threshold (unit=Count)
    claimed_account_concurrency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ConcurrentExecutions threshold (unit=Count)
    concurrent_executions = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DeadLetterErrors threshold (unit=Count)
    dead_letter_errors = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DestinationDeliveryFailures threshold (unit=Count)
    destination_delivery_failures = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Duration threshold (unit=Milliseconds)
    duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Errors threshold (unit=Count)
    errors = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Invocations threshold (unit=Count)
    invocations = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # IteratorAge threshold (unit=Milliseconds)
    iterator_age = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # OffsetLag threshold (unit=Milliseconds)
    offset_lag = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    post_runtime_extensions_duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ProvisionedConcurrentExecutions threshold (unit=Count)
    provisioned_concurrent_executions = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ProvisionedConcurrencyInvocations threshold (unit=Count)
    provisioned_concurrency_invocations = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    provisioned_concurrency_spillover_invocations = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ProvisionedConcurrencyUtilization threshold (unit=Percent)
    provisioned_concurrency_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # RecursiveInvocationsDropped threshold (unit=Count)
    recursive_invocations_dropped = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Throttles threshold (unit=Count)
    throttles = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # UnreservedConcurrentExecutions threshold (unit=Count)
    unreserved_concurrent_executions = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in Lambda."
  default = {
    async_event_age                               = { enabled = true, value = 30000 }
    async_events_dropped                          = { enabled = true, value = 1 }
    async_events_received                         = { enabled = false, value = 100000 }
    claimed_account_concurrency                   = { enabled = false, value = 900 }
    concurrent_executions                         = { enabled = true, value = 500 }
    dead_letter_errors                            = { enabled = true, value = 1 }
    destination_delivery_failures                 = { enabled = true, value = 1 }
    duration                                      = { enabled = true, value = 10000 }
    errors                                        = { enabled = true, value = 1 }
    invocations                                   = { enabled = true, value = 100000 }
    iterator_age                                  = { enabled = true, value = 60000 }
    offset_lag                                    = { enabled = false, value = 100000 }
    post_runtime_extensions_duration              = { enabled = false, value = 5000 }
    provisioned_concurrent_executions             = { enabled = false, value = 500 }
    provisioned_concurrency_invocations           = { enabled = false, value = 10000 }
    provisioned_concurrency_spillover_invocations = { enabled = false, value = 100 }
    provisioned_concurrency_utilization           = { enabled = false, value = 80 }
    recursive_invocations_dropped                 = { enabled = true, value = 1 }
    throttles                                     = { enabled = true, value = 10 }
    unreserved_concurrent_executions              = { enabled = false, value = 800 }
  }
}

variable "threshold_override" {
  type = map(object({
    # AsyncEventAge threshold (unit=Milliseconds)
    async_event_age = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # AsyncEventsDropped threshold (unit=Count)
    async_events_dropped = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # AsyncEventsReceived threshold (unit=Count)
    async_events_received = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ClaimedAccountConcurrency threshold (unit=Count)
    claimed_account_concurrency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConcurrentExecutions threshold (unit=Count)
    concurrent_executions = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DeadLetterErrors threshold (unit=Count)
    dead_letter_errors = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DestinationDeliveryFailures threshold (unit=Count)
    destination_delivery_failures = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Duration threshold (unit=Milliseconds)
    duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Errors threshold (unit=Count)
    errors = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Invocations threshold (unit=Count)
    invocations = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IteratorAge threshold (unit=Milliseconds)
    iterator_age = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # OffsetLag threshold (unit=Milliseconds)
    offset_lag = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    post_runtime_extensions_duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ProvisionedConcurrentExecutions threshold (unit=Count)
    provisioned_concurrent_executions = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ProvisionedConcurrencyInvocations threshold (unit=Count)
    provisioned_concurrency_invocations = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    provisioned_concurrency_spillover_invocations = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ProvisionedConcurrencyUtilization threshold (unit=Percent)
    provisioned_concurrency_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RecursiveInvocationsDropped threshold (unit=Count)
    recursive_invocations_dropped = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Throttles threshold (unit=Count)
    throttles = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # UnreservedConcurrentExecutions threshold (unit=Count)
    unreserved_concurrent_executions = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific Lambda functions. Key is the FunctionName. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of DLQs to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of Lambda functions will be automatically registered, but at that time, specify the function name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of Lambda functions will be automatically registered, but at that time, specify the function name you want to include using partial match. If empty, all functions will be included (except excluded ones)."
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

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
