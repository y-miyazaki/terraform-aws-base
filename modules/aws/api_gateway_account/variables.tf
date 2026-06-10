variable "name_prefix" {
  type        = string
  description = "(Required) Prefix for resource names."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags to assign to resources."
  default     = {}
}
