#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Compute Optimizer. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (account-level Compute Optimizer enrollment via the AWS CLI), so the value is not used."
  default     = null
}
