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
variable "principal_account_id" {
  type        = string
  description = "(Required) AWS root account id. default root account is ap-northeast-1 region."
}
