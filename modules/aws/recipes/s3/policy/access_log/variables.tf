#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "attach_bucket_policy" {
  type        = bool
  description = "(Optional) Specify true to attach to S3BucketPolicy."
  default     = false
}
variable "bucket" {
  type        = string
  description = "(Optional) The S3 bucket name."
  default     = null
}
variable "bucket_arn" {
  type        = string
  description = "(Required) The S3 bucket arn."
}
