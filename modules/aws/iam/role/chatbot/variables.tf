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
