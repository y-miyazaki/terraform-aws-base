#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of config name."
  default     = ""
}
variable "restricted_common_ports" {
  type = object(
    {
      input_parameters = map(any)
    }
  )
  default = {
    input_parameters = {
      blockedPort1 = "20"
      blockedPort2 = "21"
      blockedPort3 = "3389"
      blockedPort4 = "3306"
      blockedPort5 = "4333"
    }
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
