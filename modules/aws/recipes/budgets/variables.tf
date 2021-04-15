#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable Budgets. Defaults true."
  default     = true
}
variable "aws_budgets_budget" {
  type = object(
    {
      # (Optional) The name of a budget. Unique within accounts.
      name = string
      # (Required) Whether this budget tracks monetary cost or usage.
      budget_type = string
      # (Optional) Map of Cost Filters key/value pairs to apply to the budget.
      cost_filters = map(any)
      # (Required) The amount of cost or usage being measured for a budget.
      limit_amount = string
      # (Optional) Object containing Budget Notifications. Can be used multiple times to define more than one budget notification
      notification = list(any)
    }
  )
  description = "(Required) Provides a budgets budget resource. Budgets use the cost visualisation provided by Cost Explorer to show you the status of your budgets, to provide forecasts of your estimated costs, and to track your AWS usage, including your free tier usage."
}

variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # (Optional) The description of the rule.
      description = string
    }
  )
  description = "(Required) Provides an EventBridge Rule resource."
  default = {
    name        = "budgets-cloudwatch-event-rule"
    description = "This cloudwatch event used for Budgets."
    role_arn    = null
    is_enabled  = true
  }
}
variable "aws_cloudwatch_event_target" {
  type = object(
    {
      # (Required) The Amazon Resource Name (ARN) associated of the target.
      arn = string
    }
  )
  description = "(Required) Provides an EventBridge Target resource."
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
