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

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
