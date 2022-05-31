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
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "config_role_names" {
  type        = list(string)
  description = "(Required) List of the AWS Config role name."
}
