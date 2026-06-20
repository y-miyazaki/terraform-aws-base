variable "is_enabled" {
  description = "Whether to enable Macie organization configuration"
  type        = bool
  default     = false
}

variable "is_enabled_admin" {
  description = "Whether to enable Macie organization admin account designation"
  type        = bool
  default     = false
}

variable "admin_account_id" {
  description = "AWS account ID to designate as the Macie organization admin account"
  type        = string
}

variable "auto_enable" {
  description = "Whether to enable Macie automatically for new organization members"
  type        = bool
  default     = true
}

variable "status" {
  description = "Status for the Macie account. Valid values are ENABLED or PAUSED."
  type        = string
  default     = "ENABLED"
}

variable "finding_publishing_frequency" {
  description = "Frequency for publishing Macie findings. Valid values are FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "classification_jobs" {
  type        = any
  description = "(Optional) List of classification job configurations. Each item requires name, job_type, and s3_job_definition."
  default     = []
}

variable "findings_filters" {
  type        = any
  description = "(Optional) List of findings filter configurations. Each item requires name, action, and finding_criteria."
  default     = []
}

variable "tags" {
  description = "Tags to apply to classification jobs and findings filters"
  type        = map(string)
  default     = {}
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
