#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Athena. Defaults true."
  default     = true
}
variable "workgroup" {
  type        = string
  description = "(Option) Name of the WorkGroup(primary)."
  default     = "primary"
}
