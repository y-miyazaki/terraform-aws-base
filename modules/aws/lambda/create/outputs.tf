output "arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = var.is_enabled ? aws_lambda_function.this[0].arn : null
}
output "invoke_arn" {
  description = "ARN to be used for invoking Lambda Function from API Gateway - to be used in aws_api_gateway_integration's uri."
  value       = var.is_enabled ? aws_lambda_function.this[0].invoke_arn : null
}
output "function_name" {
  description = "Unique name for your Lambda Function."
  value       = var.is_enabled ? aws_lambda_function.this[0].function_name : null
}
