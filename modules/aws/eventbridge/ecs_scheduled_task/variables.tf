#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable ECS Scheduled Task schedules."
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
  description = "(Optional) Default start (enable) schedule expression. Can be overridden per schedule."
  default     = null
}
variable "schedule_expression_stop" {
  type        = string
  description = "(Optional) Default stop (disable) schedule expression. Can be overridden per schedule."
  default     = null
}
variable "description" {
  type        = string
  description = "(Optional) Default description for schedules."
  default     = null
}
variable "create_auto_schedules" {
  type        = bool
  description = "(Optional) Automatically discover EventBridge rules targeting ECS tasks to create schedules. If true, schedules variable is ignored."
  default     = false
}
variable "auto_schedules_exclude_list" {
  type        = list(string)
  description = "(Optional) List of patterns to exclude from auto-discovery (partial match on rule name)."
  default     = []
}
variable "auto_schedules_include_list" {
  type        = list(string)
  description = "(Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included."
  default     = []
}
variable "schedules" {
  type = map(object({
    ecs_cluster               = string
    task_definition           = string
    schedule_expression_start = optional(string)
    schedule_expression_stop  = optional(string)
    description               = optional(string)
  }))
  description = "(Optional) Map of ECS Scheduled Task schedules. Key is a unique identifier. Ignored if create_auto_schedules is true."
  default     = {}
}
