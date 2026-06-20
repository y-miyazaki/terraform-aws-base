#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of CloudWatch Logs metric filters and alarms. Defaults true."
  default     = true
}

variable "aws_cloudwatch_log_metric_filter" {
  type        = any
  description = "(Required) aws_cloudwatch_log_metric_filter."
}

variable "aws_cloudwatch_metric_alarm" {
  type        = any
  description = "(Required) aws_cloudwatch_metric_alarm."
}

variable "create_auto_log_group_names" {
  type        = bool
  description = "(Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored."
  default     = false
}

variable "auto_log_group_names_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to true, a list of log group name will be automatically registered, but at that time, specify the log group name you want to exclude using partial match."
  default     = []
}

variable "auto_log_group_names_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included."
  default     = []
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

variable "log_group_names" {
  type        = list(string)
  description = "(Optional) If create_auto_log_group_names is set to false, The log_group_names for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "(Required) CloudWatch Filter/Alarm name prefix."
}

variable "insufficient_data_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
