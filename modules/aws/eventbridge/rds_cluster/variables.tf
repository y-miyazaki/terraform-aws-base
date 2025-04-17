#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "db_cluster_identifier" {
  type        = string
  description = "(Required) Specify the ID of the target RDS Cluster."
}
variable "description" {
  type        = string
  description = "(Optional) Brief description of the schedule."
  default     = null
}

variable "name_start_cluster" {
  type        = string
  description = "(Optional, Forces new resource) Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix."
  default     = null
}
variable "name_stop_cluster" {
  type        = string
  description = "(Optional, Forces new resource) Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix."
  default     = null
}
variable "name_prefix" {
  type        = string
  description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
  default     = null
}
variable "role_arn" {
  type        = string
  description = " (Required) ARN of the IAM role that EventBridge Scheduler will use for this target when the schedule is invoked. Read more in Set up the execution role."
}
variable "schedule_expression_stop" {
  type        = string
  description = "(Required) Defines when the schedule runs. Read more in Schedule types on EventBridge Scheduler."
  default     = null
}
variable "schedule_expression_start" {
  type        = string
  description = "(Required) Defines when the schedule runs. Read more in Schedule types on EventBridge Scheduler."
  default     = null
}
