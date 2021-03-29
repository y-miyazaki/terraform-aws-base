#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "enabled" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable Dafault VPC. Defaults true."
  default     = true
}
variable "enable_vpc_end_point" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable VPC Endpoint for [EC2.10]. Defaults false."
  default     = false
}
variable "enable_flow_logs" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable Flow Log. Defaults true."
  default     = true
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
variable "region" {
  type        = string
  description = "(Required) The region name."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
