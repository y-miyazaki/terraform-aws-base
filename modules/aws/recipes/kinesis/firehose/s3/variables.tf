#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_kinesis_firehose_delivery_stream" {
  type = list(object(
    {
      # A name to identify the stream. This is unique to the AWS account and region the Stream is created in.
      name = string
      # Encrypt at rest options. Server-side encryption should not be enabled when a kinesis stream is configured as the source of the firehose delivery stream.
      server_side_encryption = list(any)
      # Enhanced configuration options for the s3 destination. More details are given below.
      extended_s3_configuration = list(any)
    }
  ))
  description = "(Required) The resource of aws_kinesis_firehose_delivery_stream."
}
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_role."
  default = {
    description = "Role for Kinesis Firehose to S3."
    name        = "firehose-s3-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = string
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Optional) The resource of aws_iam_policy."
  default = {
    description = "Policy for Kinesis Firehose to S3."
    name        = "firehose-s3-policy"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
