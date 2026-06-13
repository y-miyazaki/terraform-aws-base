#--------------------------------------------------------------
# Module: aws/budgets/create
# Purpose: Create an AWS Budgets cost or usage budget with optional filters, cost types, and notifications.
# Notes: Supports multiple notification blocks; no tagging (service not taggable); future improvement: add support for usage and RI/SP types validation.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides a budgets budget resource. Budgets use the cost visualisation provided by Cost Explorer to show you the status of your budgets, to provide forecasts of your estimated costs, and to track your AWS usage, including your free tier usage.
#--------------------------------------------------------------
resource "aws_budgets_budget" "this" {
  count = var.is_enabled ? 1 : 0

  name        = var.aws_budgets_budget.name
  budget_type = coalesce(var.aws_budgets_budget.budget_type, "COST")

  // Cost filters
  dynamic "cost_filter" {
    for_each = var.aws_budgets_budget.cost_filter == null ? [] : var.aws_budgets_budget.cost_filter

    content {
      name   = cost_filter.value.name
      values = cost_filter.value.values
    }
  }

  // Cost types (optional list, usually single element)
  dynamic "cost_types" {
    for_each = var.aws_budgets_budget.cost_types == null ? [] : var.aws_budgets_budget.cost_types

    content {
      include_credit             = coalesce(cost_types.value.include_credit, true)
      include_discount           = coalesce(cost_types.value.include_discount, true)
      include_other_subscription = coalesce(cost_types.value.include_other_subscription, true)
      include_recurring          = coalesce(cost_types.value.include_recurring, true)
      include_refund             = coalesce(cost_types.value.include_refund, true)
      include_subscription       = coalesce(cost_types.value.include_subscription, true)
      include_support            = coalesce(cost_types.value.include_support, true)
      include_tax                = coalesce(cost_types.value.include_tax, true)
      include_upfront            = coalesce(cost_types.value.include_upfront, true)
      use_amortized              = coalesce(cost_types.value.use_amortized, false)
      use_blended                = coalesce(cost_types.value.use_blended, false)
    }
  }

  limit_amount      = var.aws_budgets_budget.limit_amount
  limit_unit        = coalesce(var.aws_budgets_budget.limit_unit, "USD")
  time_period_end   = coalesce(var.aws_budgets_budget.time_period_end, "2050-12-31_00:00")
  time_period_start = coalesce(var.aws_budgets_budget.time_period_start, "2021-01-01_00:00")
  time_unit         = coalesce(var.aws_budgets_budget.time_unit, "MONTHLY")

  // Notifications
  dynamic "notification" {
    for_each = var.aws_budgets_budget.notification == null ? [] : var.aws_budgets_budget.notification

    content {
      comparison_operator        = coalesce(notification.value.comparison_operator, "GREATER_THAN")
      threshold                  = coalesce(notification.value.threshold, 80)
      threshold_type             = coalesce(notification.value.threshold_type, "PERCENTAGE")
      notification_type          = coalesce(notification.value.notification_type, "ACTUAL")
      subscriber_email_addresses = try(notification.value.subscriber_email_addresses, null)
      subscriber_sns_topic_arns  = try(notification.value.subscriber_sns_topic_arns, null)
    }
  }
}
