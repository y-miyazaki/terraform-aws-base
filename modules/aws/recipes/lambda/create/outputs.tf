output "arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = var.is_enabled ? aws_lambda_function.this[0].arn : null
}
output "function_name" {
  description = "Unique name for your Lambda Function."
  value       = var.is_enabled ? aws_lambda_function.this[0].function_name : null
}
