#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "alarm_actions" {
  type        = list(string)
  description = "(Required) ARNs notified when the alarm fires."
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable the filter and alarm. Defaults true."
  default     = true
}

variable "log_group_name" {
  type        = string
  description = "(Required) Name of the CloudTrail log group the metric filter reads."
}

variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of the filter, metric and alarm names."
  default     = ""
}

variable "region" {
  type        = string
  description = "(Required) AWS region of the log group and the alarm."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
