#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      # Description of the role.
      description = optional(string)
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = optional(string)
    }
  )
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Role for Kinesis Firehose."
    name        = "kinesis-firehose-role"
    path        = "/"
  }
}
variable "aws_iam_policy" {
  type = object(
    {
      # Description of the IAM policy.
      description = optional(string)
      # The name of the policy. If omitted, Terraform will assign a random, unique name.
      name = string
      # Path in which to create the policy. See IAM Identifiers for more information.
      path = optional(string)
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    description = "Policy for Kinesis Firehose."
    name        = "kinesis-firehose-policy"
    path        = "/"
  }
}
variable "bucket_arn" {
  type        = string
  description = "(Required) The s3 bucket arn."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
