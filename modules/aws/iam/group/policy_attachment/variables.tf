#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_group_policy_attachment" {
  type = list(object(
    {
      # The group the policy should be applied to
      group = string
      # The ARN of the policy you want to apply
      policy_arn = string
    }
    )
  )
  description = "(Required) - Attaches a Managed IAM Policy to an IAM group"
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (IAM), so the value is not used."
  default     = null
}
