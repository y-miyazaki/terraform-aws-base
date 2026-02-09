variable "is_enabled" {
  description = "Whether to enable GuardDuty organization configuration"
  type        = bool
  default     = false
}

variable "is_enabled_admin" {
  description = "Whether to enable GuardDuty organization admin account designation"
  type        = bool
  default     = false
}

variable "admin_account_id" {
  description = "AWS account ID to designate as the GuardDuty organization admin account"
  type        = string
}

variable "auto_enable_organization_members" {
  description = "Whether to auto-enable GuardDuty for new organization members"
  type        = string
  default     = "ALL"
}

variable "features" {
  description = "GuardDuty organization configuration features"
  type = map(object({
    auto_enable = string
    additional_configurations = optional(list(object({
      name        = string
      auto_enable = string
    })), [])
  }))
  default = {}
}
