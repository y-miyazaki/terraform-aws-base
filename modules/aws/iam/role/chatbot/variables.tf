#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) Name of all resources."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (IAM), so the value is not used."
  default     = null
}
