#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "bucket" {
  type        = string
  description = "The S3 Bucket ID."
  default     = null
}
variable "bucket_arn" {
  type        = string
  description = "The S3 bucket arn."
  default     = null
}
variable "account_id" {
  type        = number
  description = "(Required) AWS account ID for member account."
  default     = null
}
