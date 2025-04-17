#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix of all resources."
  default     = ""
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true."
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) KMS key ID to set for SNS Topic."
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  type        = string
  description = "(Optional) KMS key ID to set for CloudWatch log group."
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "(Required) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
