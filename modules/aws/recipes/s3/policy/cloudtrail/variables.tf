#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "bucket" {
  type        = string
  description = "(Required) The S3 Bucket ID."
}
variable "bucket_arn" {
  type        = string
  description = "(Required) The S3 bucket arn."
}
variable "account_id" {
  type        = number
  description = "(Required) AWS account ID for member account."
}
