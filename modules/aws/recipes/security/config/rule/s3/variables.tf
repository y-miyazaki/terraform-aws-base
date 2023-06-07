#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable AWS Config. Defaults true."
  default     = true
}
variable "name_prefix" {
  type        = string
  description = "(Optional) Prefix of config name."
  default     = ""
}
variable "ssm_automation_assume_role_arn" {
  type        = string
  description = "(Required) AssumeRole arn in SSM Automation"
}

variable "is_configure_s3_bucket_public_access_block" {
  type        = bool
  description = "(Optional) If true, configures the Amazon Simple Storage Service (Amazon S3) public access block settings for an Amazon S3 bucket based on the values you specify."
  default     = false
}
variable "configure_s3_bucket_public_access_block" {
  type = object(
    {
      # If set to True, Amazon S3 blocks public access control lists (ACLs) for the S3 bucket, and objects stored in the S3 bucket you specify in the BucketName parameter.
      block_public_acls = bool
      # If set to True, Amazon S3 blocks public bucket policies for the S3 bucket you specify in the BucketName parameter.
      block_public_policy = bool
      # If set to True, Amazon S3 ignores all public ACLs for the S3 bucket you specify in the BucketName parameter.
      ignore_public_acls = bool
      # If set to True, Amazon S3 restricts public bucket policies for the S3 bucket you specify in the BucketName parameter.
      restrict_public_buckets = bool
    }
  )
  description = "(Optional) If true, configures the Amazon Simple Storage Service (Amazon S3) public access block settings for an Amazon S3 bucket based on the values you specify."
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "is_disable_s3_bucket_public_read_write" {
  type        = bool
  description = "(Optional) If true, public read/write of the S3 bucket will be disabled."
  default     = false
}
variable "is_enabled_s3_bucket_encryption" {
  type        = bool
  description = "(Optional) If true, Enable encryption for an Amazon Simple Storage Service (Amazon S3) bucket (encrypt the contents of the bucket)."
  default     = false
}
variable "enabled_s3_bucket_encryption_sse_algorithm" {
  type        = string
  description = "(Optional) Server-side encryption algorithm to use for the default encryption."
  default     = "AES256"
}
variable "is_restrict_bucket_ssl_requests_only" {
  type        = bool
  description = "(Optional) If true, bucket policy statement that explicitly denies HTTP requests to the Amazon S3 bucket you specify."
  default     = false
}
variable "is_configure_s3_bucket_versioning" {
  type        = bool
  description = "(Optional) If true, it will enable S3 bucket versioning."
  default     = false
}

# variable "restricted_common_ports" {
#   type = object(
#     {
#       input_parameters = map(any)
#     }
#   )
#   default = {
#     input_parameters = {
#       blockedPort1 = "20"
#       blockedPort2 = "21"
#       blockedPort3 = "3389"
#       blockedPort4 = "3306"
#       blockedPort5 = "4333"
#     }
#   }
# }
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
