#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "(Optional) Name prefix of all resources."
  default     = ""
}
variable "aws_api_gateway_rest_api_id" {
  type        = string
  description = "(Required) ID of the REST API."
}
variable "aws_api_gateway_rest_api_root_resource_id" {
  type        = string
  description = "(Required) Resource ID of the REST API's root."
}
variable "aws_api_gateway_rest_api_execution_arn" {
  type        = string
  description = "(Required) Execution ARN part to be used in lambda_permission's source_arn when allowing API Gateway to invoke a Lambda function."
}
variable "role_arn" {
  type        = string
  description = "(Required) IAM Role arn used by Lambda."
}
variable "vpc_config" {
  type        = list(any)
  description = "(Optional) aws_lambda_function Configuration block."
  default     = []
}
variable "lambda_function_aws_cloudwatch_log_group" {
  type = object(
    {
      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.
      retention_in_days = number
      # The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
      kms_key_id = string
    }
  )
  description = "(Optional) The aws_cloudwatch_log_group."
  default = {
    retention_in_days = 14
    kms_key_id        = null
  }
}
variable "lambda_function_environment" {
  type        = map(string)
  description = "(Optional) Configuration block."
  default     = {}
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags for the workgroup. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = null
}
variable "access_log_settings" {
  type        = map(any)
  description = "(Optional)"
  default     = {}
}
