#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "attach_bucket_policy" {
  type        = bool
  description = "(Optional) Controls if S3 bucket should have bucket policy attached (set to true to use value of policy as bucket policy)."
  default     = false
}
variable "bucket" {
  type        = string
  description = "(Optional) The S3 bucket name."
  default     = null
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "config_role_names" {
  type        = list(string)
  description = "(Required) List of the AWS Config role name."
}
