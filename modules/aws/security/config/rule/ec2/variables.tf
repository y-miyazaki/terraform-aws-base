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
variable "ssm_automation_assume_role_arn" {
  type        = string
  description = "(Required) AssumeRole arn in SSM Automation"
}
variable "is_disable_public_access_for_security_group" {
  type        = bool
  description = "(Optional) If true, it will disable the default SSH and RDP ports that are open for all IP addresses."
  default     = false
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
