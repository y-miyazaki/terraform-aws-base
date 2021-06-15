#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.
      schedule_expression = string
      # The event pattern described a JSON object. At least one of schedule_expression or event_pattern is required. See full documentation of Events and Event Patterns in EventBridge for details.
      event_pattern = string
      # The description of the rule.
      description = string
      # The Amazon Resource Name (ARN) associated with the role that is used for target invocation.
      role_arn = string
      # Whether the rule should be enabled (defaults to true).
      is_enabled = bool
    }
  )
  description = "(Required) Provides an EventBridge Rule resource."
}
variable "aws_cloudwatch_event_target" {
  type = object(
    {
      # The event bus to associate with the rule. If you omit this, the default event bus is used.
      event_bus_name = string
      # The unique target assignment ID. If missing, will generate a random, unique id.
      target_id = string
      # (Required) The Amazon Resource Name (ARN) associated of the target.
      arn = string
      # Valid JSON text passed to the target. Conflicts with input_path and input_transformer.
      input = string
      # The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input_transformer.
      input_path = string
      # The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used.
      role_arn = string
      # Parameters used when you are using the rule to invoke Amazon EC2 Run Command. Documented below. A maximum of 5 are allowed.
      run_command_targets = list(any)
      # Parameters used when you are using the rule to invoke Amazon ECS Task. Documented below. A maximum of 1 are allowed.
      ecs_target = list(any)
      # Parameters used when you are using the rule to invoke an Amazon Batch Job. Documented below. A maximum of 1 are allowed.
      batch_target = list(any)
      # Parameters used when you are using the rule to invoke an Amazon Kinesis Stream. Documented below. A maximum of 1 are allowed.
      kinesis_target = list(any)
      # Parameters used when you are using the rule to invoke an Amazon SQS Queue. Documented below. A maximum of 1 are allowed.
      sqs_target = list(any)
      # Parameters used when you are providing a custom input to a target based on certain event data. Conflicts with input and input_path.
      input_transformer = list(any)
      # Parameters used when you are providing retry policies. Documented below. A maximum of 1 are allowed.
      retry_policy = list(any)
      # Parameters used when you are providing a dead letter conifg. Documented below. A maximum of 1 are allowed.
      dead_letter_config = list(any)
    }
  )
  description = "(Required) Provides an EventBridge Target resource."
}

variable "event_source_token" {
  type        = string
  description = "(Optional) The Event Source Token to validate. Used with Alexa Skills."
  default     = null
}
variable "function_name" {
  type        = string
  description = "(Required) Name of the Lambda function whose resource policy you are updating"
}
# variable "principal" {
#   type        = string
#   description = "(Required) The principal who is getting this permission. e.g. s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com."
#   default     = "events.amazonaws.com"
# }
variable "qualifier" {
  type        = string
  description = "(Optional) Query parameter to specify function version or alias name. The permission will then apply to the specific qualified ARN. e.g. arn:aws:lambda:aws-region:acct-id:function:function-name:2"
  default     = null
}
variable "source_account" {
  type        = string
  description = "(Optional) This parameter is used for S3 and SES. The AWS account ID (without a hyphen) of the source owner."
  default     = null
}
# variable "source_arn" {
#   type        = string
#   description = "(Optional) When granting Amazon S3 or CloudWatch Events permission to invoke your function, you should specify this field with the Amazon Resource Name (ARN) for the S3 Bucket or CloudWatch Events Rule as its value. This ensures that only events generated from the specified bucket or rule can invoke the function. API Gateway ARNs have a unique structure described here."
#   default     = null
# }
variable "statement_id" {
  type        = string
  description = "(Optional) A unique statement identifier. By default generated by Terraform."
  default     = null
}
# variable "statement_id_prefix" {
#   type        = string
#   description = "(Optional) A statement identifier prefix. Terraform will generate a unique suffix. Conflicts with statement_id."
#   default     = null
# }
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
