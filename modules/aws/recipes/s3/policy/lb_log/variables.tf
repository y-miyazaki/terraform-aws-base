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
variable "principal_account_id" {
  type        = string
  description = "AWS root account id. default root account is ap-northeast-1 region."
  default     = "582318560864"
}
