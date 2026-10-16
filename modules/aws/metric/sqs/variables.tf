#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of SQS. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    approximate_age_of_oldest_message = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    approximate_age_of_oldest_message_in_quiet_groups = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    approximate_number_of_groups_with_inflight_messages = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    approximate_number_of_messages_delayed = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_delayed_in_quiet_groups = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    approximate_number_of_messages_not_visible = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_not_visible_in_quiet_groups = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    approximate_number_of_messages_visible = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_visible_in_quiet_groups = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_noisy_groups = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    number_of_deduplicated_sent_messages = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    number_of_empty_receives = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    number_of_messages_deleted = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    number_of_messages_received = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    number_of_messages_sent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) SentMessageSize threshold (unit=Bytes)
    sent_message_size = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in SQS."
  default = {
    # (Required) ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    approximate_age_of_oldest_message = { enabled = true, value = 3600 } # 1 hour
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    approximate_age_of_oldest_message_in_quiet_groups = { enabled = false, value = 3600 } # 1 hour
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    approximate_number_of_groups_with_inflight_messages = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    approximate_number_of_messages_delayed = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_delayed_in_quiet_groups = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    approximate_number_of_messages_not_visible = { enabled = false, value = 10000 }
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_not_visible_in_quiet_groups = { enabled = false, value = 10000 }
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    approximate_number_of_messages_visible = { enabled = true, value = 1000 }
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_visible_in_quiet_groups = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_noisy_groups = { enabled = false, value = 1 }
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    number_of_deduplicated_sent_messages = { enabled = false, value = 100 }
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    number_of_empty_receives = { enabled = false, value = 10000 }
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    number_of_messages_deleted = { enabled = false, value = 100000 }
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    number_of_messages_received = { enabled = false, value = 100000 }
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    number_of_messages_sent = { enabled = false, value = 100000 }
    # (Required) SentMessageSize threshold (unit=Bytes)
    sent_message_size = { enabled = false, value = 262144 } # 256KB (max SQS message size)
  }
}

variable "threshold_override" {
  type = map(object({
    # ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    approximate_age_of_oldest_message = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    approximate_age_of_oldest_message_in_quiet_groups = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    approximate_number_of_groups_with_inflight_messages = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    approximate_number_of_messages_delayed = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_delayed_in_quiet_groups = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    approximate_number_of_messages_not_visible = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_not_visible_in_quiet_groups = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesVisible threshold (unit=Count)
    approximate_number_of_messages_visible = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_messages_visible_in_quiet_groups = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    approximate_number_of_noisy_groups = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    number_of_deduplicated_sent_messages = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfEmptyReceives threshold (unit=Count)
    number_of_empty_receives = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfMessagesDeleted threshold (unit=Count)
    number_of_messages_deleted = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfMessagesReceived threshold (unit=Count)
    number_of_messages_received = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfMessagesSent threshold (unit=Count)
    number_of_messages_sent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SentMessageSize threshold (unit=Bytes)
    sent_message_size = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override threshold settings for specific queues. Key is QueueName (exact match), value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of SQS queues to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of SQS queues will be automatically registered, but at that time, specify the queue name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of SQS queues will be automatically registered, but at that time, specify the queue name you want to include using partial match. If empty, all queues will be included (except excluded ones)."
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
