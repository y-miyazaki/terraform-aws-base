#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of SNS. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) NumberOfMessagesPublished threshold (unit=Count)
    number_of_messages_published = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    number_of_notifications_delivered = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    number_of_notifications_failed = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    number_of_notifications_failed_to_redrive_to_dlq = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    number_of_notifications_filtered_out = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_attributes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_message_body = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_message_attributes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_message_body = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_no_message_attributes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    number_of_notifications_redriven_to_dlq = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) PublishSize threshold (unit=Bytes)
    publish_size = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in SNS."
  default = {
    # (Required) NumberOfMessagesPublished threshold (unit=Count)
    number_of_messages_published = { enabled = false, value = 100000 }
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    number_of_notifications_delivered = { enabled = false, value = 100000 }
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    number_of_notifications_failed = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    number_of_notifications_failed_to_redrive_to_dlq = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    number_of_notifications_filtered_out = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_attributes = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_message_body = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_message_attributes = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_message_body = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_no_message_attributes = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    number_of_notifications_redriven_to_dlq = { enabled = true, value = 1 }
    # (Required) PublishSize threshold (unit=Bytes)
    publish_size = { enabled = false, value = 262144 } # 256KB (max SNS message size)
  }
}

variable "threshold_override" {
  type = map(object({
    # NumberOfMessagesPublished threshold (unit=Count)
    number_of_messages_published = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsDelivered threshold (unit=Count)
    number_of_notifications_delivered = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFailed threshold (unit=Count)
    number_of_notifications_failed = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    number_of_notifications_failed_to_redrive_to_dlq = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut threshold (unit=Count)
    number_of_notifications_filtered_out = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_attributes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_message_body = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_message_attributes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_message_body = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_no_message_attributes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    number_of_notifications_redriven_to_dlq = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PublishSize threshold (unit=Bytes)
    publish_size = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the TopicName. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of SNS topics to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of SNS topics will be automatically registered, but at that time, specify the topic name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of SNS topics will be automatically registered, but at that time, specify the topic name you want to include using partial match. If empty, all topics will be included (except excluded ones)."
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
