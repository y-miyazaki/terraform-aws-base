#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix of all resources."
  default     = ""
}
variable "workgroup_name" {
  type        = string
  description = "(Required) Name of the workgroup."
}
variable "workgroup_configuration" {
  type        = any
  description = "(Optional) Configuration block with various settings for the workgroup. Documented below."
  default     = {}
}
variable "workgroup_description" {
  type        = string
  description = "(Optional) Description of the workgroup."
  default     = null
}
variable "workgroup_state" {
  type        = string
  description = "(Optional) State of the workgroup. Valid values are DISABLED or ENABLED. Defaults to ENABLED."
  default     = "ENABLED"
}
variable "database_bucket" {
  type        = string
  description = "(Required) Name of S3 bucket to save the results of the query execution."
}
variable "database_name" {
  type        = string
  description = "(Required) Name of the database to create."
}
variable "database_acl_configuration" {
  type        = any
  description = "(Optional) That an Amazon S3 canned ACL should be set to control ownership of stored query results. See ACL Configuration below."
  default     = {}
}
variable "database_comment" {
  type        = string
  description = "(Optional) Description of the database."
  default     = null
}
variable "database_encryption_configuration" {
  type        = any
  description = "(Optional) Encryption key block AWS Athena uses to decrypt the data in S3, such as an AWS Key Management Service (AWS KMS) key. See Encryption Configuration below."
  default     = {}
}
variable "database_expected_bucket_owner" {
  type        = string
  description = "(Optional) AWS account ID that you expect to be the owner of the Amazon S3 bucket."
  default     = null
}
variable "database_properties" {
  type        = any
  description = "(Optional) Key-value map of custom metadata properties for the database definition."
  default     = null
}
variable "enabled_cloudfront" {
  type        = bool
  description = "(Optional) To check CloudFront logs with Athena, specify true."
  default     = false
}
variable "cloudfront_table_name" {
  type        = string
  description = "(Optional) Specify the name of the CloudFront table to be created in Athena."
  default     = "cloudfront_logs"
}
variable "cloudfront_log_bucket" {
  type        = string
  description = "(Required) Specify the bucket where the CloudFront logs are located. s3://{bucket name}/{bucket prefix}"
}
variable "enabled_ses" {
  type        = bool
  description = "(Optional) To check SES logs with Athena, specify true."
  default     = false
}
variable "ses_table_name" {
  type        = string
  description = "(Optional) Specify the name of the SES table to be created in Athena."
  default     = "ses_logs"
}
variable "ses_log_bucket" {
  type        = string
  description = "(Required) Specify the bucket where the SES logs are located. s3://{bucket name}/{bucket prefix}"
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags for the workgroup. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = null
}
