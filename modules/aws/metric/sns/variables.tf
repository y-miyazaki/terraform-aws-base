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
    enabled_number_of_messages_published = bool
    number_of_messages_published         = number
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    enabled_number_of_notifications_delivered = bool
    number_of_notifications_delivered         = number
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    enabled_number_of_notifications_failed = bool
    number_of_notifications_failed         = number
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    enabled_number_of_notifications_failed_to_redrive_to_dlq = bool
    number_of_notifications_failed_to_redrive_to_dlq         = number
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    enabled_number_of_notifications_filtered_out = bool
    number_of_notifications_filtered_out         = number
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_attributes = bool
    number_of_notifications_filtered_out_invalid_attributes         = number
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_message_body = bool
    number_of_notifications_filtered_out_invalid_message_body         = number
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_attributes = bool
    number_of_notifications_filtered_out_message_attributes         = number
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_body = bool
    number_of_notifications_filtered_out_message_body         = number
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_no_message_attributes = bool
    number_of_notifications_filtered_out_no_message_attributes         = number
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    enabled_number_of_notifications_redriven_to_dlq = bool
    number_of_notifications_redriven_to_dlq         = number
    # (Required) PublishSize threshold (unit=Bytes)
    enabled_publish_size = bool
    publish_size         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in SNS."
  default = {
    # (Required) NumberOfMessagesPublished threshold (unit=Count)
    enabled_number_of_messages_published = false
    number_of_messages_published         = 100000
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    enabled_number_of_notifications_delivered = false
    number_of_notifications_delivered         = 100000
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    enabled_number_of_notifications_failed = true
    number_of_notifications_failed         = 1
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    enabled_number_of_notifications_failed_to_redrive_to_dlq = true
    number_of_notifications_failed_to_redrive_to_dlq         = 1
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    enabled_number_of_notifications_filtered_out = false
    number_of_notifications_filtered_out         = 100
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_attributes = true
    number_of_notifications_filtered_out_invalid_attributes         = 1
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_message_body = true
    number_of_notifications_filtered_out_invalid_message_body         = 1
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_attributes = false
    number_of_notifications_filtered_out_message_attributes         = 100
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_body = false
    number_of_notifications_filtered_out_message_body         = 100
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_no_message_attributes = false
    number_of_notifications_filtered_out_no_message_attributes         = 100
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    enabled_number_of_notifications_redriven_to_dlq = true
    number_of_notifications_redriven_to_dlq         = 1
    # (Required) PublishSize threshold (unit=Bytes)
    enabled_publish_size = false
    publish_size         = 262144 # 256KB (max SNS message size)
  }
}
variable "threshold_override" {
  type = map(object({
    # (Optional) NumberOfMessagesPublished threshold (unit=Count)
    enabled_number_of_messages_published = optional(bool)
    number_of_messages_published         = optional(number)
    # (Optional) NumberOfNotificationsDelivered threshold (unit=Count)
    enabled_number_of_notifications_delivered = optional(bool)
    number_of_notifications_delivered         = optional(number)
    # (Optional) NumberOfNotificationsFailed threshold (unit=Count)
    enabled_number_of_notifications_failed = optional(bool)
    number_of_notifications_failed         = optional(number)
    # (Optional) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    enabled_number_of_notifications_failed_to_redrive_to_dlq = optional(bool)
    number_of_notifications_failed_to_redrive_to_dlq         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut threshold (unit=Count)
    enabled_number_of_notifications_filtered_out = optional(bool)
    number_of_notifications_filtered_out         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_attributes = optional(bool)
    number_of_notifications_filtered_out_invalid_attributes         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_message_body = optional(bool)
    number_of_notifications_filtered_out_invalid_message_body         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_attributes = optional(bool)
    number_of_notifications_filtered_out_message_attributes         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_body = optional(bool)
    number_of_notifications_filtered_out_message_body         = optional(number)
    # (Optional) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_no_message_attributes = optional(bool)
    number_of_notifications_filtered_out_no_message_attributes         = optional(number)
    # (Optional) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    enabled_number_of_notifications_redriven_to_dlq = optional(bool)
    number_of_notifications_redriven_to_dlq         = optional(number)
    # (Optional) PublishSize threshold (unit=Bytes)
    enabled_publish_size = optional(bool)
    publish_size         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the TopicName."
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
