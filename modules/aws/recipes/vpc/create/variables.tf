#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a tag name beginning with the specified prefix."
}
variable "cidr_block" {
  type        = string
  description = "(Required) The CIDR block for the VPC."
}
variable "availability_zone" {
  type        = list(any)
  description = "(Required) The AZ for the subnet."
}
variable "nat_cidr_block" {
  type        = list(any)
  description = "(Required) The CIDR block for the nat gateway subnet."
}
variable "igw_cidr_block" {
  type        = list(any)
  description = "(Required) The CIDR block for the internet gateway subnet."
}
variable "aws_cloudwatch_log_group" {
  type = object(
    {
      name_prefix       = string
      retention_in_days = number
    }
  )
  description = "(Optional) need to flow log, true. flow log saves cloudwatch logs."
  default = {
    name_prefix       = "vpc-flow-log-"
    retention_in_days = 30
  }
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
    name        = "vpc-flow-log-role"
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
    name        = "vpc-flow-log-policy"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
