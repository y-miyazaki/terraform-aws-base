output "budget_name" {
  description = "The name of the budget."
  value       = try(aws_budgets_budget.this[0].name, null)
}

output "budget_arn" {
  description = "The ARN of the budget."
  value       = try(aws_budgets_budget.this[0].arn, null)
}
