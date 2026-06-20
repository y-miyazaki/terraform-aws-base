#--------------------------------------------------------------
# Variables for auto_discovery_filter internal module
#--------------------------------------------------------------
variable "is_enabled" {
  description = "Master switch to enable/disable the entire module"
  type        = bool
  default     = true
}

variable "create_auto" {
  description = "Whether to create auto-discovered resources (true) or use manual dimensions (false)"
  type        = bool
  default     = false
}

variable "source_list" {
  description = "Source list to filter (from data source or external script)"
  type        = list(string)
  default     = []
}

variable "include_list" {
  description = "Include filter list (empty = include all)"
  type        = list(string)
  default     = []
}

variable "exclude_list" {
  description = "Exclude filter list"
  type        = list(string)
  default     = []
}

variable "manual_dimensions" {
  description = "Manual dimensions list (when create_auto = false)"
  type        = any
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
