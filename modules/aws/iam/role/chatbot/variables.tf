#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "role_name" {
  type        = string
  description = "(Required) The name of the role."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
