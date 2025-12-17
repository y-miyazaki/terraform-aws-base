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
    enabled_approximate_age_of_oldest_message = bool
    approximate_age_of_oldest_message         = number
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    enabled_approximate_age_of_oldest_message_in_quiet_groups = bool
    approximate_age_of_oldest_message_in_quiet_groups         = number
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    enabled_approximate_number_of_groups_with_inflight_messages = bool
    approximate_number_of_groups_with_inflight_messages         = number
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    enabled_approximate_number_of_messages_delayed = bool
    approximate_number_of_messages_delayed         = number
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_delayed_in_quiet_groups = bool
    approximate_number_of_messages_delayed_in_quiet_groups         = number
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_not_visible = bool
    approximate_number_of_messages_not_visible         = number
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_not_visible_in_quiet_groups = bool
    approximate_number_of_messages_not_visible_in_quiet_groups         = number
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_visible = bool
    approximate_number_of_messages_visible         = number
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_visible_in_quiet_groups = bool
    approximate_number_of_messages_visible_in_quiet_groups         = number
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_noisy_groups = bool
    approximate_number_of_noisy_groups         = number
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    enabled_number_of_deduplicated_sent_messages = bool
    number_of_deduplicated_sent_messages         = number
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    enabled_number_of_empty_receives = bool
    number_of_empty_receives         = number
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    enabled_number_of_messages_deleted = bool
    number_of_messages_deleted         = number
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    enabled_number_of_messages_received = bool
    number_of_messages_received         = number
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    enabled_number_of_messages_sent = bool
    number_of_messages_sent         = number
    # (Required) SentMessageSize threshold (unit=Bytes)
    enabled_sent_message_size = bool
    sent_message_size         = number
  })
  description = "(Optional) Set the threshold for each Metric in SQS."
  default = {
    # (Required) ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    enabled_approximate_age_of_oldest_message = true
    approximate_age_of_oldest_message         = 3600 # 1 hour
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    enabled_approximate_age_of_oldest_message_in_quiet_groups = false
    approximate_age_of_oldest_message_in_quiet_groups         = 3600 # 1 hour
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    enabled_approximate_number_of_groups_with_inflight_messages = false
    approximate_number_of_groups_with_inflight_messages         = 1000
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    enabled_approximate_number_of_messages_delayed = false
    approximate_number_of_messages_delayed         = 1000
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_delayed_in_quiet_groups = false
    approximate_number_of_messages_delayed_in_quiet_groups         = 1000
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_not_visible = false
    approximate_number_of_messages_not_visible         = 10000
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_not_visible_in_quiet_groups = false
    approximate_number_of_messages_not_visible_in_quiet_groups         = 10000
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_visible = true
    approximate_number_of_messages_visible         = 1000
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_visible_in_quiet_groups = false
    approximate_number_of_messages_visible_in_quiet_groups         = 1000
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_noisy_groups = false
    approximate_number_of_noisy_groups         = 1
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    enabled_number_of_deduplicated_sent_messages = false
    number_of_deduplicated_sent_messages         = 100
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    enabled_number_of_empty_receives = false
    number_of_empty_receives         = 10000
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    enabled_number_of_messages_deleted = false
    number_of_messages_deleted         = 100000
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    enabled_number_of_messages_received = false
    number_of_messages_received         = 100000
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    enabled_number_of_messages_sent = false
    number_of_messages_sent         = 100000
    # (Required) SentMessageSize threshold (unit=Bytes)
    enabled_sent_message_size = false
    sent_message_size         = 262144 # 256KB (max SQS message size)
  }
}
variable "threshold_override" {
  type = map(object({
    # ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    enabled_approximate_age_of_oldest_message = optional(bool)
    approximate_age_of_oldest_message         = optional(number)
    # ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds) - Fair Queues
    enabled_approximate_age_of_oldest_message_in_quiet_groups = optional(bool)
    approximate_age_of_oldest_message_in_quiet_groups         = optional(number)
    # ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count) - FIFO only
    enabled_approximate_number_of_groups_with_inflight_messages = optional(bool)
    approximate_number_of_groups_with_inflight_messages         = optional(number)
    # ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    enabled_approximate_number_of_messages_delayed = optional(bool)
    approximate_number_of_messages_delayed         = optional(number)
    # ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_delayed_in_quiet_groups = optional(bool)
    approximate_number_of_messages_delayed_in_quiet_groups         = optional(number)
    # ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_not_visible = optional(bool)
    approximate_number_of_messages_not_visible         = optional(number)
    # ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_not_visible_in_quiet_groups = optional(bool)
    approximate_number_of_messages_not_visible_in_quiet_groups         = optional(number)
    # ApproximateNumberOfMessagesVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_visible = optional(bool)
    approximate_number_of_messages_visible         = optional(number)
    # ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_messages_visible_in_quiet_groups = optional(bool)
    approximate_number_of_messages_visible_in_quiet_groups         = optional(number)
    # ApproximateNumberOfNoisyGroups threshold (unit=Count) - Fair Queues
    enabled_approximate_number_of_noisy_groups = optional(bool)
    approximate_number_of_noisy_groups         = optional(number)
    # NumberOfDeduplicatedSentMessages threshold (unit=Count) - FIFO only
    enabled_number_of_deduplicated_sent_messages = optional(bool)
    number_of_deduplicated_sent_messages         = optional(number)
    # NumberOfEmptyReceives threshold (unit=Count)
    enabled_number_of_empty_receives = optional(bool)
    number_of_empty_receives         = optional(number)
    # NumberOfMessagesDeleted threshold (unit=Count)
    enabled_number_of_messages_deleted = optional(bool)
    number_of_messages_deleted         = optional(number)
    # NumberOfMessagesReceived threshold (unit=Count)
    enabled_number_of_messages_received = optional(bool)
    number_of_messages_received         = optional(number)
    # NumberOfMessagesSent threshold (unit=Count)
    enabled_number_of_messages_sent = optional(bool)
    number_of_messages_sent         = optional(number)
    # SentMessageSize threshold (unit=Bytes)
    enabled_sent_message_size = optional(bool)
    sent_message_size         = optional(number)
  }))
  description = "(Optional) Override threshold settings for specific queues. Key is QueueName (exact match), value contains optional threshold attributes to override."
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
