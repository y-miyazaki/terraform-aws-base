#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  description = "(Optional) Module-level toggle. Default false to prevent accidental org-wide enablement."
  type        = bool
  default     = true
}

variable "is_enabled_delegated_admin" {
  description = "(Optional) Enable delegated admin account configuration for Inspector2."
  type        = bool
  default     = false
}

variable "is_enabled_configuration" {
  description = "(Optional) Enable organization-level configurations for auto-enabling new accounts."
  type        = bool
  default     = false
}

variable "delegated_admin_account_id" {
  description = "(Optional) Account ID to designate as delegated admin for Inspector2. Leave empty to skip."
  type        = string
  default     = ""
}

variable "enabler" {
  description = "(Optional) Map of enabler configurations for specified accounts and resource types."
  type = map(object({
    account_ids    = list(string)
    resource_types = list(string)
  }))
  default = {}
}

variable "configuration" {
  description = "(Optional) Map of auto-enable configurations for new accounts."
  type = object({
    auto_enable_ec2             = bool
    auto_enable_ecr             = bool
    auto_enable_lambda          = bool
    auto_enable_lambda_code     = bool
    auto_enable_code_repository = bool
  })
  default = {
    # (Required) Auto-enable EC2 scanning for new accounts
    auto_enable_ec2 = false
    # (Required) Auto-enable ECR scanning for new accounts
    auto_enable_ecr = false
    # (Required) Auto-enable Lambda scanning for new accounts
    auto_enable_lambda = false
    # (Required) Auto-enable Lambda code scanning for new accounts
    auto_enable_lambda_code = false
    # (Required) Auto-enable code repository scanning for new accounts
    auto_enable_code_repository = false
  }
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
