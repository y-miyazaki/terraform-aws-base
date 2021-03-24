#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "analyzer_name" {
  type        = string
  description = "(Required) Name of the Analyzer."
  default     = null
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
