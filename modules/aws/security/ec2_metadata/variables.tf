#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable EC2 metadata defaults. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region for EC2 metadata resources."
  default     = null
}

variable "http_tokens" {
  type        = string
  description = "(Optional) Whether IMDSv2 is required. Valid values: required, optional, no-preference. Defaults to required."
  default     = "required"
}

variable "http_put_response_hop_limit" {
  type        = number
  description = "(Optional) The maximum number of hops that the metadata token can travel. Valid values: -1 (no-preference), 1-64. Defaults to 2."
  default     = 2
}

variable "http_endpoint" {
  type        = string
  description = "(Optional) Whether the IMDS endpoint is enabled. Valid values: enabled, disabled, no-preference. Defaults to enabled."
  default     = "enabled"
}
