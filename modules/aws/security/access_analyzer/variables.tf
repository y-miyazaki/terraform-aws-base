#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Access Analyzer. Defaults true."
  default     = true
}
variable "analyzer_name" {
  type        = string
  description = "(Required) Name of the Analyzer."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
variable "type" {
  type        = string
  description = "(Optional) Type of Analyzer. Valid values are ACCOUNT or ORGANIZATION. Defaults to ACCOUNT."
  default     = null
}
variable "region" {
  type        = string
  description = "(Optional) AWS region for the analyzer check script. If not set, uses the provider's default region."
  default     = ""
}
