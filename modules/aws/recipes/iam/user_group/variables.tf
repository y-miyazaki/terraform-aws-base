variable "user" {
  type        = list(any)
  description = "(Required) Provides an IAM User."
  default     = []
}
variable "group" {
  type        = any
  description = "(Required) Provides an IAM Group."
  default     = null
}
variable "name_prefix" {
  type        = string
  description = "(Required) Prefix of policy name ."
  default     = ""
}
