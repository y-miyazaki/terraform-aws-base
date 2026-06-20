#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of EBS. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region for EBS resources."
  default     = null
}

variable "is_enabled_ebs_encryption_by_default" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable default EBS encryption at the account level. Defaults false."
  default     = true
}

variable "is_enabled_ebs_public_snapshot_block_access" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable blocking public access to EBS snapshots. Defaults false."
  default     = true
}

variable "state" {
  type        = string
  description = "(Optional) The desired state of the EBS snapshot block public access settings. Valid values are: 'block-all-sharing', 'unblock'. Defaults to 'block-all-sharing'."
  default     = "block-all-sharing"
}
