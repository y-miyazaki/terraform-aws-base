variable "user" {
  type        = list(any)
  description = "(Required) Provides an IAM User."
  default     = []
}
variable "group" {
  type        = map(any)
  description = "(Required) Provides an IAM Group."
  default     = {}
}
variable "name_prefix" {
  type        = string
  description = "(Required) Prefix of policy name ."
  default     = null
}
