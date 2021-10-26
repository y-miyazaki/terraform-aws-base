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
      # The name of the log group. If omitted, Terraform will assign a random, unique name.
      name = string
      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.
      retention_in_days = number
    }
  )
  description = "(Optional) need to flow log, true. flow log saves cloudwatch logs."
  default = {
    name              = "vpc-flow-logs"
    retention_in_days = 30
  }
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
    description = "Role for VPC Flow log."
    name        = "vpc-flow-logs-role"
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
    description = "Policy for VPC Flow log."
    name        = "vpc-flow-logs-policy"
    path        = "/"
  }
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
