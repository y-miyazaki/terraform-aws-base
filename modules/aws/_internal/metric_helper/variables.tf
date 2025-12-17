#--------------------------------------------------------------
# Variables for metric_helper internal module
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

variable "dimension_key" {
  description = "The primary dimension key name (e.g., 'QueueName' for SQS, 'DBClusterIdentifier' for RDS)"
  type        = string
}

variable "base_threshold" {
  description = "Base threshold object containing default values for all metrics"
  type        = any
}

variable "threshold_override" {
  description = "Map of resource name to threshold overrides. Key is the dimension value (exact match), value is an object with optional threshold attributes to override."
  type        = any
  default     = {}
}
