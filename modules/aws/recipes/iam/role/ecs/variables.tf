#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_iam_role" {
  type = object(
    {
      ecs = object({
        # Description of the role.
        description = string
        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
      ecs_tasks = object({
        # Description of the role.
        description = string
        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
      events = object({
        # Description of the role.
        description = string
        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.
        name = string
        # Path to the role. See IAM Identifiers for more information.
        path = string
        }
      )
    }
  )
  description = "(Optional) Provides an IAM role."
  default = {
    ecs = {
      description = "Role for ECS."
      name        = "ecs-role"
      path        = "/"
    }
    ecs_tasks = {
      description = "Role for ECS Task."
      name        = "ecs-tasks-role"
      path        = "/"
    }
    events = {
      description = "Role for Events."
      name        = "events-role"
      path        = "/"
    }
  }

}
variable "aws_iam_policy" {
  type = object(
    {
      events = object({
        # Description of the IAM policy.
        description = string
        # The name of the policy. If omitted, Terraform will assign a random, unique name.
        name = string
        # Path in which to create the policy. See IAM Identifiers for more information.
        path = string
        }
      )
    }
  )
  description = "(Optional) Provides an IAM policy."
  default = {
    events = {
      description = "Policy for ECS."
      name        = "ecs-policy"
      path        = "/"
    }
  }

}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value mapping of tags for the IAM role"
  default     = null
}
