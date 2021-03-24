#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "bucket_id" {
  type        = string
  description = "The S3 Bucket ID."
  default     = null
}
variable "vpc_id" {
  type        = string
  description = "The VPC ID."
  default     = null
}
variable "bucket_arn" {
  type        = string
  description = "The S3 bucket arn."
  default     = null
}
