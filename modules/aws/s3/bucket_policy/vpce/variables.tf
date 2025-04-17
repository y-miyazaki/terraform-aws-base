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
  description = "(Required) The S3 bucket name."
}
variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID."
}
