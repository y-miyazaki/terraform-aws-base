#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "enabled" {
  type        = bool
  description = "(Optional) Whether or not default EBS encryption is enabled. Valid values are true or false. Defaults to true."
  default     = true
}
