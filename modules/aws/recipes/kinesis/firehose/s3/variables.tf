#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_kinesis_firehose_delivery_stream" {
  type = list(object(
    {
      name                      = string
      server_side_encryption    = list(any)
      extended_s3_configuration = list(any)
    }
  ))
  description = "(Required) The resource of aws_kinesis_firehose_delivery_stream."
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
  description = "(Required) The resource of aws_iam_role."
  default = {
    description = null
    name        = "firehose-s3-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # (Optional) Description of the IAM policy.
      description = string
      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # (Optional) Path to the role. See IAM Identifiers for more information.
      path = string
    }
  )
  description = "(Required) The resource of aws_iam_policy."
  default = {
    description = null
    name        = "firehose-s3-policy"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
