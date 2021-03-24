#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      ecs = object({
        # (Optional) Description of the role.
        description = string
        # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # (Optional) Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
      ecs_tasks = object({
        # (Optional) Description of the role.
        description = string
        # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # (Optional) Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
      events = object({
        # (Optional) Description of the role.
        description = string
        # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # (Optional) Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
    }
  )
  description = "(Required) Provides an IAM role."
  default = {
    ecs = {
      description = null
      name        = "ecs-role"
      path        = "/"
    }
    ecs_tasks = {
      description = null
      name        = "ecs-tasks-role"
      path        = "/"
    }
    events = {
      description = null
      name        = "events-role"
      path        = "/"
    }
  }

}
variable "aws_iam_policy" {
  type = object(
    {
      events = object({
        # (Optional, Forces new resource) Description of the IAM policy.
        description = string
        # (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name.
        name = string
        # (Optional, default "/") Path in which to create the policy. See IAM Identifiers for more information.
        path = string
        }
      )
    }
  )
  description = "(Required) Provides an IAM policy."
  default = {
    events = {
      description = null
      name        = "ecs-policy"
      path        = "/"
    }
  }

}
variable "tags" {
  type        = map(any)
  description = "Key-value mapping of tags for the IAM role"
  default     = null
}
