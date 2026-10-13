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
    description = "IAM role for Monitoring RDS."
    name        = "monitoring-rds-role"
    path        = "/"
  }
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (IAM), so the value is not used."
  default     = null
}
