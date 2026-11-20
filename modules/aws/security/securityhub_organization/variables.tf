#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable the Security Hub central configuration. Defaults true."
  default     = true
}

variable "is_enabled_admin" {
  description = "(Optional) Enable Security Hub organization admin account designation."
  type        = bool
  default     = false
}

variable "is_enabled_finding_aggregator" {
  description = "(Optional) Enable Security Hub finding aggregator."
  type        = bool
  default     = false
}

variable "admin_account_id" {
  description = "(Optional) Account ID to designate as Security Hub organization admin. Defaults to caller account if is_enabled_admin."
  type        = string
  default     = ""
}

variable "configuration_policy_description" {
  description = "(Optional) Configuration policy description"
  type        = string
  default     = "Central Security Hub CSPM policy for organizations"
}

variable "configuration_policy_name" {
  description = "(Optional) Configuration policy name"
  type        = string
  default     = ""
}

variable "configuration_policy" {
  description = "(Optional) Configuration policy settings"
  type = object({
    service_enabled       = bool
    enabled_standard_arns = optional(list(string))
    security_controls_configuration = optional(object({
      disabled_control_identifiers = optional(list(string))
    }))
  })
  default = {
    service_enabled       = false
    enabled_standard_arns = []
    security_controls_configuration = {
      disabled_control_identifiers = []
    }
  }
}

variable "linked_regions" {
  description = "(Optional) Linked regions of the finding aggregator, excluding the home region (the region of this module). Configuration policies take effect in the home region and in these regions only, so list only regions that are enabled for the account (a disabled opt-in region makes the policy association fail)."
  type        = list(string)
  default     = []
}

variable "target_id" {
  description = "(Required) Target ID for the configuration policy association"
  type        = string
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
