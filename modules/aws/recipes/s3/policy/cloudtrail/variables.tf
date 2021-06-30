#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "bucket" {
  type        = string
  description = "(Required) The S3 bucket name."
}
variable "bucket_arn" {
  type        = string
  description = "(Required) The S3 bucket arn."
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
