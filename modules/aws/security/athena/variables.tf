#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Athena. Defaults true."
  default     = true
}

variable "region" {
  type        = string
  description = "(Optional) AWS region for Athena resources."
  default     = null
}

variable "workgroup" {
  type        = string
  description = "(Option) Name of the WorkGroup(primary)."
  default     = "primary"
}

variable "output_location" {
  type        = string
  description = "(Optional) The location in Amazon S3 where your query results are stored, such as s3://path/to/query/bucket/."
  default     = null
}
