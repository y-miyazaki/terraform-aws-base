#--------------------------------------------------------------
# Variables for eventbridge_scheduler_helper internal module
#--------------------------------------------------------------

variable "is_enabled" {
  description = "Master switch to enable/disable the entire module"
  type        = bool
  default     = true
}

variable "create_auto_schedules" {
  description = "Whether to create auto-discovered schedules (true) or use manual schedules (false)"
  type        = bool
  default     = false
}

variable "source_schedules" {
  description = "Source schedules map to filter (from caller's data processing logic)"
  type        = map(any)
  default     = {}
}

variable "auto_schedules_include_list" {
  description = "Include filter list (empty = include all)"
  type        = list(string)
  default     = []
}

variable "auto_schedules_exclude_list" {
  description = "Exclude filter list"
  type        = list(string)
  default     = []
}

variable "manual_schedules" {
  description = "Manual schedules map (when create_auto_schedules = false)"
  type        = map(any)
  default     = {}
}

variable "schedule_expression_start" {
  description = "Default start schedule expression to apply when a schedule omits it"
  type        = string
  default     = null
}

variable "schedule_expression_stop" {
  description = "Default stop schedule expression to apply when a schedule omits it"
  type        = string
  default     = null
}

variable "primary_key" {
  description = "The primary key name to use for filtering (e.g., 'instance_id' for EC2, 'db_cluster_identifier' for RDS, 'ecs_service' for ECS)"
  type        = string
}
