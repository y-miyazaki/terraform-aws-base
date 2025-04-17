#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name" {
  type        = string
  description = "(Required) The resource group's name. A resource group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with AWS or aws."
}
variable "description" {
  type        = string
  description = "(Optional) A description of the resource group."
  default     = null
}
variable "resource_query" {
  type        = any
  description = "(Required) A resource_query block. Resource queries are documented below."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags"
  default     = null
}
