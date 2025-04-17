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

variable "elb_account_id" {
  type        = string
  description = "(Required) set elb_account_id with the ID of the AWS account for Elastic Load Balancing for your Region."
}
