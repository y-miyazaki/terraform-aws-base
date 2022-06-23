#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Synthetics Canary. Defaults true."
  default     = true
}
variable "aws_iam_role" {
  type = object(
    {
      # (Optional) Description of the role.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The aws_iam_role resource."
  default = {
    description = "Role for Synthetics Canaly."
    name        = "monitor-synthetics-canary-role"
    path        = "/"
  }
}
variable "account_id" {
  type        = string
  description = "(Optional) AWS account ID for member account. Set only if aws_synthetics_canary.execution_role_arn is not specified."
  default     = null
}
variable "region" {
  type        = string
  description = "(Optional) Specify the region in which Synthetics Canary will be run. Set only if aws_synthetics_canary.execution_role_arn is not specified."
  default     = null
}
variable "s3_bucket_arn" {
  type        = string
  description = "(Optional) Specify the ARN of the S3Bucket where the Artifact will be placed. Set only if aws_synthetics_canary.execution_role_arn is not specified."
  default     = null
}

variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for Synthetics Canaly."
    name        = "monitor-synthetics-canary-policy"
    path        = "/"
  }
}

variable "aws_synthetics_canary" {
  type = object(
    {
      # (Required) Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary.
      artifact_s3_location = string
      # (Required) ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.
      execution_role_arn = string
      # (Required) Entry point to use for the source code when running the canary. This value must end with the string .handler .
      handler = string
      # (Required) Name for this canary. Has a maximum length of 21 characters. Valid characters are lowercase alphanumeric, hyphen, or underscore.
      name = string
      # (Required) Runtime version to use for the canary. Versions change often so consult the Amazon CloudWatch documentation for the latest valid versions. Values include syn-python-selenium-1.0, syn-nodejs-puppeteer-3.0, syn-nodejs-2.2, syn-nodejs-2.1, syn-nodejs-2.0, and syn-1.0.
      runtime_version = string
      # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.
      schedule = list(any)
      # (Optional) Configuration block. Detailed below.
      vpc_config = list(any)
      # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      failure_retention_period = number
      # (Required) Configuration block for individual canary runs. Detailed below.
      run_config = list(object(
        {
          timeout_in_seconds = number
          memory_in_mb       = number
          active_tracing     = bool
        }
      ))
      # (Optional) Full bucket name which is used if your canary script is located in S3. The bucket must already exist. Specify the full bucket name including s3:// as the start of the bucket name. Conflicts with zip_file.
      s3_bucket = string
      # (Optional) S3 key of your script. Conflicts with zip_file.
      s3_key = string
      # (Optional) S3 version ID of your script. Conflicts with zip_file.
      s3_version = string
      # (Optional) Whether to run or stop the canary.
      start_canary = bool
      # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      success_retention_period = number
      # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.
      #   artifact_config = list(any)
      # (Optional) ZIP file that contains the script, if you input your canary script directly into the canary instead of referring to an S3 location. It can be up to 5 MB. Conflicts with s3_bucket, s3_key, and s3_version.
      zip_file = string
      env      = map(string)
    }
  )
  description = "(Required) aws_synthetics_canary."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = null
}
