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
  default     = null
}

variable "archive_rules" {
  type = map(object({
    filters = map(object({
      contains = optional(list(string))
      eq       = optional(list(string))
      exists   = optional(bool)
      neq      = optional(list(string))
    }))
  }))
  description = "(Optional) Archive rules keyed by rule name. Each rule's filters are keyed by IAM Access Analyzer filter key (for example principal.Federated) and are ANDed. Findings matching a rule are archived automatically. Rules are created only when this module creates the analyzer."
  default     = {}

  validation {
    condition = alltrue([
      for rule in values(var.archive_rules) : length(rule.filters) > 0 && alltrue([
        for f in values(rule.filters) : f.contains != null || f.eq != null || f.exists != null || f.neq != null
      ])
    ])
    error_message = "Each archive rule must have at least one filter, and each filter must set at least one of contains, eq, exists or neq."
  }
}
