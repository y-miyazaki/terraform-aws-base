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
  type        = number
  description = "(Required) AWS account ID for member account."
}
variable "config_role_name" {
  type        = string
  description = "(Required) The AWS Config role name."
}
