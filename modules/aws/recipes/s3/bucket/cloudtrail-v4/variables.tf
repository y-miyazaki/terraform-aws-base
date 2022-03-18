#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_random_name_suffix" {
  type        = bool
  description = "(Optional) The random name suffix of the bucket."
  default     = false
}
variable "account_id" {
  type        = string
  description = "(Required) AWS account ID for member account."
}
variable "aws_s3_bucket" {
  type = object(
    {
      # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here.
      bucket = string
      # (Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable.
      force_destroy = bool
      # (Optional) A configuration of S3 object locking. See Object Lock Configuration below.
      object_lock_configuration = list(object(
        {
          object_lock_enabled = string
        }
      ))
    }
  )
}
variable "aws_s3_bucket_acl" {
  type = object(
    {
      acl                   = string
      access_control_policy = list(any)
      expected_bucket_owner = string

  })
  description = "(Optional) Provides an S3 bucket ACL resource."
  default = {
    acl                   = "log-delivery-write"
    access_control_policy = []
    expected_bucket_owner = null
  }
}
variable "aws_s3_bucket_versioning" {
  type = object(
    {
      versioning_configuration = list(any)
  })
  description = "(Optional) Configuration block for the versioning parameters."
  default = {
    versioning_configuration = [
      {
        status     = "Disabled"
        mfa_delete = "Disabled"
      }
    ]
  }
}
variable "aws_s3_bucket_server_side_encryption_configuration" {
  type = object(
    {
      # (Optional, Forces new resource) The account ID of the expected bucket owner.
      expected_bucket_owner = string
      # (Required) Set of server-side encryption configuration rules. documented below. Currently, only a single rule is supported.
      rule = list(any)
    }
  )
  description = "(Optional) Provides a S3 bucket server-side encryption configuration resource."
  default = {
    expected_bucket_owner = null

    rule = [
      {
        apply_server_side_encryption_by_default = [
          {
            sse_algorithm     = "AES256"
            kms_master_key_id = null
          }
        ]
      }
    ]
  }
}
variable "aws_s3_bucket_logging" {
  type = object(
    {
      # (Optional, Forces new resource) The account ID of the expected bucket owner.
      expected_bucket_owner = string
      # (Required) The bucket where you want Amazon S3 to store server access logs.
      target_bucket = string
      # (Required) A prefix for all log object keys.
      target_prefix = string
      # (Optional) Set of configuration blocks with information for granting permissions documented below.
      target_grant = list(any)
  })
  description = "(Optional) Provides a S3 bucket logging resource."
  default     = null
}
variable "aws_s3_bucket_lifecycle_configuration" {
  type = object(
    {
      # (Optional) The account ID of the expected bucket owner. If the bucket is owned by a different account, the request will fail with an HTTP 403 (Access Denied) error.
      expected_bucket_owner = string
      # (Required) List of configuration blocks describing the rules managing the replication documented below.
      rule = list(object(
        {

          abort_incomplete_multipart_upload_days = list(any)
          expiration                             = list(any)
          filter                                 = list(any)
          id                                     = string
          noncurrent_version_expiration          = list(any)
          noncurrent_version_transition          = list(any)
          prefix                                 = string
          status                                 = string
          transition                             = list(any)
        }
        )
      )
    }
  )
  description = "(Optional) Provides an independent configuration resource for S3 bucket lifecycle configuration."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = null
}
