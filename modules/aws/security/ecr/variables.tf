variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable ECR account settings. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
