variable "is_enabled" {
  type        = bool
  description = "(Optional) Whether to create IAM resources. Set to false to disable the entire module."
  default     = true
}
variable "user" {
  type = map(object({
    is_console_access = bool
    is_access_key     = bool
  }))
  description = "(Optional) Provides an IAM User."
  default     = {}
}
variable "group" {
  type        = any
  description = "(Optional) Provides an IAM Group."
  default     = {}
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of policy name ."
  default     = ""
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
