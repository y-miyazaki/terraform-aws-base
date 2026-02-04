#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable ECS service schedules."
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
  description = "(Optional) Automatically discover ECS services to create schedules. If true, schedules variable is ignored."
  default     = false
}
variable "auto_schedules_exclude_list" {
  type        = list(string)
  description = "(Optional) List of patterns to exclude from auto-discovery (partial match on cluster or service name)."
  default     = []
}
variable "auto_schedules_include_list" {
  type        = list(string)
  description = "(Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included."
  default     = []
}
variable "desired_count" {
  type        = number
  description = "(Optional) Default desired count for starting ECS services when not specified in schedules."
  default     = 1
}
variable "autoscaling_min_capacity" {
  type        = number
  description = "(Optional) Default minimum capacity for Application Auto Scaling when starting ECS services. Set to 0 to skip autoscaling adjustment."
  default     = 1
}
variable "autoscaling_max_capacity" {
  type        = number
  description = "(Optional) Default maximum capacity for Application Auto Scaling when starting ECS services. Set to 0 to skip autoscaling adjustment."
  default     = 0
}
variable "schedules" {
  type = map(object({
    ecs_cluster               = string
    ecs_service               = string
    desired_count             = optional(number)
    has_autoscaling           = optional(number)
    autoscaling_min_capacity  = optional(number)
    autoscaling_max_capacity  = optional(number)
    schedule_expression_start = optional(string)
    schedule_expression_stop  = optional(string)
    description               = optional(string)
  }))
  description = "(Optional) Map of ECS service schedules. Key is a unique identifier. Ignored if create_auto_schedules is true."
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
