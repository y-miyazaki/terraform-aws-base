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
    enabled_async_event_age = bool
    async_event_age         = number
    # AsyncEventsDropped threshold (unit=Count)
    enabled_async_events_dropped = bool
    async_events_dropped         = number
    # AsyncEventsReceived threshold (unit=Count)
    enabled_async_events_received = bool
    async_events_received         = number
    # ClaimedAccountConcurrency threshold (unit=Count)
    enabled_claimed_account_concurrency = bool
    claimed_account_concurrency         = number
    # ConcurrentExecutions threshold (unit=Count)
    enabled_concurrent_executions = bool
    concurrent_executions         = number
    # DeadLetterErrors threshold (unit=Count)
    enabled_dead_letter_errors = bool
    dead_letter_errors         = number
    # DestinationDeliveryFailures threshold (unit=Count)
    enabled_destination_delivery_failures = bool
    destination_delivery_failures         = number
    # Duration threshold (unit=Milliseconds)
    enabled_duration = bool
    duration         = number
    # Errors threshold (unit=Count)
    enabled_errors = bool
    errors         = number
    # Invocations threshold (unit=Count)
    enabled_invocations = bool
    invocations         = number
    # IteratorAge threshold (unit=Milliseconds)
    enabled_iterator_age = bool
    iterator_age         = number
    # OffsetLag threshold (unit=Milliseconds)
    enabled_offset_lag = bool
    offset_lag         = number
    # PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    enabled_post_runtime_extensions_duration = bool
    post_runtime_extensions_duration         = number
    # ProvisionedConcurrentExecutions threshold (unit=Count)
    enabled_provisioned_concurrent_executions = bool
    provisioned_concurrent_executions         = number
    # ProvisionedConcurrencyInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_invocations = bool
    provisioned_concurrency_invocations         = number
    # ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_spillover_invocations = bool
    provisioned_concurrency_spillover_invocations         = number
    # ProvisionedConcurrencyUtilization threshold (unit=Percent)
    enabled_provisioned_concurrency_utilization = bool
    provisioned_concurrency_utilization         = number
    # RecursiveInvocationsDropped threshold (unit=Count)
    enabled_recursive_invocations_dropped = bool
    recursive_invocations_dropped         = number
    # Throttles threshold (unit=Count)
    enabled_throttles = bool
    throttles         = number
    # UnreservedConcurrentExecutions threshold (unit=Count)
    enabled_unreserved_concurrent_executions = bool
    unreserved_concurrent_executions         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in Lambda."
  default = {
    enabled_async_event_age                               = true
    async_event_age                                       = 30000
    enabled_async_events_dropped                          = true
    async_events_dropped                                  = 1
    enabled_async_events_received                         = false
    async_events_received                                 = 100000
    enabled_claimed_account_concurrency                   = false
    claimed_account_concurrency                           = 900
    enabled_concurrent_executions                         = true
    concurrent_executions                                 = 500
    enabled_dead_letter_errors                            = true
    dead_letter_errors                                    = 1
    enabled_destination_delivery_failures                 = true
    destination_delivery_failures                         = 1
    enabled_duration                                      = true
    duration                                              = 10000
    enabled_errors                                        = true
    errors                                                = 1
    enabled_invocations                                   = true
    invocations                                           = 100000
    enabled_iterator_age                                  = true
    iterator_age                                          = 60000
    enabled_offset_lag                                    = false
    offset_lag                                            = 100000
    enabled_post_runtime_extensions_duration              = false
    post_runtime_extensions_duration                      = 5000
    enabled_provisioned_concurrent_executions             = false
    provisioned_concurrent_executions                     = 500
    enabled_provisioned_concurrency_invocations           = false
    provisioned_concurrency_invocations                   = 10000
    enabled_provisioned_concurrency_spillover_invocations = false
    provisioned_concurrency_spillover_invocations         = 100
    enabled_provisioned_concurrency_utilization           = false
    provisioned_concurrency_utilization                   = 80
    enabled_recursive_invocations_dropped                 = true
    recursive_invocations_dropped                         = 1
    enabled_throttles                                     = true
    throttles                                             = 10
    enabled_unreserved_concurrent_executions              = false
    unreserved_concurrent_executions                      = 800
  }
}

variable "threshold_override" {
  type = map(object({
    # AsyncEventAge threshold (unit=Milliseconds)
    enabled_async_event_age = optional(bool)
    async_event_age         = optional(number)
    # AsyncEventsDropped threshold (unit=Count)
    enabled_async_events_dropped = optional(bool)
    async_events_dropped         = optional(number)
    # AsyncEventsReceived threshold (unit=Count)
    enabled_async_events_received = optional(bool)
    async_events_received         = optional(number)
    # ClaimedAccountConcurrency threshold (unit=Count)
    enabled_claimed_account_concurrency = optional(bool)
    claimed_account_concurrency         = optional(number)
    # ConcurrentExecutions threshold (unit=Count)
    enabled_concurrent_executions = optional(bool)
    concurrent_executions         = optional(number)
    # DeadLetterErrors threshold (unit=Count)
    enabled_dead_letter_errors = optional(bool)
    dead_letter_errors         = optional(number)
    # DestinationDeliveryFailures threshold (unit=Count)
    enabled_destination_delivery_failures = optional(bool)
    destination_delivery_failures         = optional(number)
    # Duration threshold (unit=Milliseconds)
    enabled_duration = optional(bool)
    duration         = optional(number)
    # Errors threshold (unit=Count)
    enabled_errors = optional(bool)
    errors         = optional(number)
    # Invocations threshold (unit=Count)
    enabled_invocations = optional(bool)
    invocations         = optional(number)
    # IteratorAge threshold (unit=Milliseconds)
    enabled_iterator_age = optional(bool)
    iterator_age         = optional(number)
    # OffsetLag threshold (unit=Milliseconds)
    enabled_offset_lag = optional(bool)
    offset_lag         = optional(number)
    # PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    enabled_post_runtime_extensions_duration = optional(bool)
    post_runtime_extensions_duration         = optional(number)
    # ProvisionedConcurrentExecutions threshold (unit=Count)
    enabled_provisioned_concurrent_executions = optional(bool)
    provisioned_concurrent_executions         = optional(number)
    # ProvisionedConcurrencyInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_invocations = optional(bool)
    provisioned_concurrency_invocations         = optional(number)
    # ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_spillover_invocations = optional(bool)
    provisioned_concurrency_spillover_invocations         = optional(number)
    # ProvisionedConcurrencyUtilization threshold (unit=Percent)
    enabled_provisioned_concurrency_utilization = optional(bool)
    provisioned_concurrency_utilization         = optional(number)
    # RecursiveInvocationsDropped threshold (unit=Count)
    enabled_recursive_invocations_dropped = optional(bool)
    recursive_invocations_dropped         = optional(number)
    # Throttles threshold (unit=Count)
    enabled_throttles = optional(bool)
    throttles         = optional(number)
    # UnreservedConcurrentExecutions threshold (unit=Count)
    enabled_unreserved_concurrent_executions = optional(bool)
    unreserved_concurrent_executions         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific Lambda functions. Key is the FunctionName."
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
