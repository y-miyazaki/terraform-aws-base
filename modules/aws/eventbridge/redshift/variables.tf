#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Redshift cluster schedules."
  default     = true
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Creates a unique name beginning with the specified prefix."
  default     = null
}
variable "role_arn" {
  type        = string
  description = "(Required) ARN of the IAM role that EventBridge Scheduler will use for this target."
}
variable "schedule_expression_start" {
  type        = string
  description = "(Optional) Default start schedule expression. Can be overridden per schedule."
  default     = null
}
variable "schedule_expression_stop" {
  type        = string
  description = "(Optional) Default stop schedule expression. Can be overridden per schedule."
  default     = null
}
variable "description" {
  type        = string
  description = "(Optional) Default description for schedules."
  default     = null
}
variable "create_auto_schedules" {
  type        = bool
  description = "(Optional) Automatically discover Redshift clusters to create schedules. If true, schedules variable is ignored."
  default     = false
}
variable "auto_schedules_exclude_list" {
  type        = list(string)
  description = "(Optional) List of patterns to exclude from auto-discovery (partial match on cluster identifier)."
  default     = []
}
variable "auto_schedules_include_list" {
  type        = list(string)
  description = "(Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included."
  default     = []
}
variable "schedules" {
  type = map(object({
    cluster_identifier        = string
    schedule_expression_start = optional(string)
    schedule_expression_stop  = optional(string)
    description               = optional(string)
  }))
  description = "(Optional) Map of Redshift cluster schedules. Key is a unique identifier. Ignored if create_auto_schedules is true."
  default     = {}
}
variable "retry_max_age_seconds" {
  type        = number
  description = "(Optional) Maximum age of a request that EventBridge Scheduler sends to a target for processing."
  default     = 3600
}
variable "retry_max_attempts" {
  type        = number
  description = "(Optional) Maximum number of retry attempts to make before the request fails."
  default     = 3
}
