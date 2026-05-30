#--------------------------------------------------------------
# module outputs
#--------------------------------------------------------------
output "api_gateway_endpoint" {
  description = "The API Gateway endpoint URL for Slack webhook configuration"
  value       = aws_apigatewayv2_api.slack.api_endpoint
}
output "dynamodb_table_name" {
  description = "The name of the DynamoDB requests table"
  value       = module.dynamodb_table_requests.dynamodb_table_id
}
output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB requests table"
  value       = module.dynamodb_table_requests.dynamodb_table_arn
}
output "state_machine_arn" {
  description = "The ARN of the Step Functions state machine"
  value       = module.step_functions.state_machine_arn
}
output "lambda_function_arn" {
  description = "The ARN of the JIT Access Lambda function"
  value       = module.lambda_jit_access.lambda_function_arn
}
output "lambda_function_name" {
  description = "The name of the JIT Access Lambda function"
  value       = module.lambda_jit_access.lambda_function_name
}
output "dlq_arn" {
  description = "The ARN of the Dead Letter Queue for revoke failures"
  value       = aws_sqs_queue.dlq.arn
}
output "dlq_url" {
  description = "The URL of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.url
}
output "lambda_role_arn" {
  description = "The ARN of the Lambda execution IAM role"
  value       = aws_iam_role.lambda.arn
}
