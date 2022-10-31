#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Lambda. Defaults true."
  default     = true
}
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.
      retention_in_days = number
      # The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
      kms_key_id = string
    }
  )
  description = "(Optional) The aws_cloudwatch_log_group."
  default = {
    retention_in_days = 14
    kms_key_id        = null
  }
}
variable "aws_lambda_function" {
  type = object(
    {
      # Unique name for your Lambda Function.
      function_name = string
      # Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources.
      role = string
      # Path to the function's deployment package within the local filesystem. Conflicts with image_uri, s3_bucket, s3_key, and s3_object_version.
      filename = string
      # S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. This bucket must reside in the same AWS region where you are creating the Lambda function.
      s3_bucket = string
      # S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri.
      s3_key = string
      # Object version containing the function's deployment package. Conflicts with filename and image_uri.
      s3_object_version = string
      # Configuration block.
      dead_letter_config = list(any)
      # Function entrypoint in your code.
      handler = string
      # Description of what your Lambda Function does.
      description = string
      # List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. See Lambda Layers
      layers = list(any)
      # Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. See Limits
      memory_size = number
      # Identifier of the function's runtime. See Runtimes for valid values.
      runtime = string
      # Amount of time your Lambda Function has to run in seconds. Defaults to 3. See Limits.
      timeout = number
      # Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See Managing Concurrency
      reserved_concurrent_executions = string
      # Whether to publish creation/change as new Lambda Function Version. Defaults to false.
      publish = bool
      # Configuration block.
      vpc_config = list(any)
      # Configuration block.
      environment = map(any)
      # Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key. If this configuration is provided when environment variables are not in use, the AWS Lambda API does not save this configuration and Terraform will show a perpetual difference of adding the key. To fix the perpetual difference, remove this configuration.
      kms_key_arn = string
      # Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key. The usual way to set this is filebase64sha256("file.zip") (Terraform 0.11.12 and later) or base64sha256(file("file.zip")) (Terraform 0.11.11 and earlier), where "file.zip" is the local filename of the lambda function source archive.
      source_code_hash = string
    }
  )
  description = "(Required) The aws_lambda_function."
}
variable "aws_lambda_permission" {
  type = object(
    {
      action             = string
      event_source_token = string
      # function_name       = string
      principal           = string
      qualifier           = string
      source_account      = string
      source_arn          = string
      statement_id        = string
      statement_id_prefix = string
    }
  )
  description = "(Optional) The aws_lambda_permission."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
