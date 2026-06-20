#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS region where Macie resources will be deployed"
}

variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Macie account configuration. Defaults true."
  default     = true
}

variable "status" {
  type        = string
  description = "(Optional) Status for the Macie account. Valid values are ENABLED or PAUSED."
  default     = "ENABLED"
}

variable "finding_publishing_frequency" {
  type        = string
  description = "(Optional) Frequency for publishing Macie findings. Valid values are FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
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
