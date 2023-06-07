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
  default     = null
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of policy name ."
  default     = ""
}
