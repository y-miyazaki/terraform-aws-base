#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable Budgets. Defaults true."
  default     = true
}

variable "aws_budgets_budget" {
  type = object({
    # (Required) The name of a budget. Unique within account.
    name = string
    # (Required) The amount of cost or usage being measured for the budget (AWS API expects string format).
    limit_amount = string

    # (Optional) Budget type; defaults handled in main (COST | USAGE | RI_UTILIZATION | RI_COVERAGE | SAVINGS_PLANS_UTILIZATION | SAVINGS_PLANS_COVERAGE).
    budget_type = optional(string)
    # (Optional) Currency unit (e.g. USD); default handled in main.
    limit_unit = optional(string)
    # (Optional) Budget start time (YYYY-MM-DD_HH:MM); default handled in main.
    time_period_start = optional(string)
    # (Optional) Budget end time (YYYY-MM-DD_HH:MM); default handled in main.
    time_period_end = optional(string)
    # (Optional) Time unit (MONTHLY | QUARTERLY | ANNUALLY); default handled in main.
    time_unit = optional(string)

    # (Optional) List of cost filters.
    cost_filter = optional(list(object({
      # (Required) Cost filter dimension name.
      name = string
      # (Required) List of values for the cost filter dimension.
      values = list(string)
    })))

    # (Optional) Cost types override list (normally one element).
    cost_types = optional(list(object({
      # (Optional) Include credit line items.
      include_credit = optional(bool)
      # (Optional) Include discounts.
      include_discount = optional(bool)
      # (Optional) Include other subscription costs.
      include_other_subscription = optional(bool)
      # (Optional) Include recurring costs.
      include_recurring = optional(bool)
      # (Optional) Include refunds.
      include_refund = optional(bool)
      # (Optional) Include subscription costs.
      include_subscription = optional(bool)
      # (Optional) Include support charges.
      include_support = optional(bool)
      # (Optional) Include taxes.
      include_tax = optional(bool)
      # (Optional) Include upfront charges.
      include_upfront = optional(bool)
      # (Optional) Use amortized costs instead of blended costs where applicable.
      use_amortized = optional(bool)
      # (Optional) Use blended costs.
      use_blended = optional(bool)
    })))

    # (Optional) Notification definitions list.
    notification = optional(list(object({
      # (Optional) Comparison operator (GREATER_THAN | LESS_THAN | EQUAL_TO).
      comparison_operator = optional(string)
      # (Optional) Numeric threshold; main defaults to 80.
      threshold = optional(number)
      # (Optional) Threshold type (PERCENTAGE | ABSOLUTE_VALUE).
      threshold_type = optional(string)
      # (Optional) Notification evaluation basis (ACTUAL | FORECASTED).
      notification_type = optional(string)
      # (Optional) Email subscriber list.
      subscriber_email_addresses = optional(list(string))
      # (Optional) SNS topic ARNs list.
      subscriber_sns_topic_arns = optional(list(string))
    })))
  })
  description = "(Required) AWS Budgets configuration object. Only 'name' and 'limit_amount' are mandatory; all other attributes are optional."
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
