#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_event_rule" {
  type = object(
    {
      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
      name = string
      # (Optional) The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.
      schedule_expression = string
      # (Optional) The event pattern described a JSON object. At least one of schedule_expression or event_pattern is required. See full documentation of Events and Event Patterns in EventBridge for details.
      event_pattern = string
      # (Optional) The description of the rule.
      description = string
      # (Optional) The Amazon Resource Name (ARN) associated with the role that is used for target invocation.
      role_arn = string
      # (Optional) Whether the rule should be enabled (defaults to true).
      is_enabled = bool
    }
  )
  description = "(Required) Provides an EventBridge Rule resource."
}
variable "aws_cloudwatch_event_target" {
  type = object(
    {
      # (Optional) The event bus to associate with the rule. If you omit this, the default event bus is used.
      event_bus_name = string
      # (Optional) The unique target assignment ID. If missing, will generate a random, unique id.
      target_id = string
      # (Required) The Amazon Resource Name (ARN) associated of the target.
      arn = string
      # (Optional) Valid JSON text passed to the target. Conflicts with input_path and input_transformer.
      input = string
      # (Optional) The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input_transformer.
      input_path = string
      # (Optional) The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used.
      role_arn = string
      # (Optional) Parameters used when you are using the rule to invoke Amazon EC2 Run Command. Documented below. A maximum of 5 are allowed.
      run_command_targets = list(any)
      # (Optional) Parameters used when you are using the rule to invoke Amazon ECS Task. Documented below. A maximum of 1 are allowed.
      ecs_target = list(any)
      # (Optional) Parameters used when you are using the rule to invoke an Amazon Batch Job. Documented below. A maximum of 1 are allowed.
      batch_target = list(any)
      # (Optional) Parameters used when you are using the rule to invoke an Amazon Kinesis Stream. Documented below. A maximum of 1 are allowed.
      kinesis_target = list(any)
      # (Optional) Parameters used when you are using the rule to invoke an Amazon SQS Queue. Documented below. A maximum of 1 are allowed.
      sqs_target = list(any)
      # (Optional) Parameters used when you are providing a custom input to a target based on certain event data. Conflicts with input and input_path.
      input_transformer = list(any)
      # (Optional) Parameters used when you are providing retry policies. Documented below. A maximum of 1 are allowed.
      retry_policy = list(any)
      # (Optional) Parameters used when you are providing a dead letter conifg. Documented below. A maximum of 1 are allowed.
      dead_letter_config = list(any)
    }
  )
  description = "(Required) Provides an EventBridge Target resource."
}
variable "tags" {
  type        = map(any)
  description = "tags - (Optional) A mapping of tags to assign to the resource."
  default     = null
}
