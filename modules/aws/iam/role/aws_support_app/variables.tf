#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      # Description of the IAM policy.
      description = optional(string)
      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
      name = string
      # Path to the role. See IAM Identifiers for more information.
      path = optional(string)
    }
  )
  description = "(Optional) Provides an IAM role."
  default = {
    description = "Role for AWS Support App."
    name        = "aws-support-app-role"
    path        = "/"
  }
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
