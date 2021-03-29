#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable settings of EBS. Defaults true."
  default     = true
}
