#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_cloudwatch_event_rule" {
  type = object({
    # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.
    name = string
    # (Optional) The scheduling expression. e.g., cron(0 20 * * ? *) or rate(5 minutes). Either schedule_expression or event_pattern is required.
    schedule_expression = optional(string)
    # (Optional) JSON event pattern (string form). Either schedule_expression or event_pattern is required.
    event_pattern = optional(string)
    # (Optional) The description of the rule.
    description = optional(string)
    # (Optional) Role ARN used for target invocation. Needed for certain target types such as ECS or Batch.
    role_arn = optional(string)
    # (Optional) Rule state (ENABLED or DISABLED). Defaults to ENABLED when omitted.
    state = optional(string)
  })
  description = "(Required) EventBridge rule definition (must specify one of schedule_expression or event_pattern)."
  validation {
    condition = (
      try(var.aws_cloudwatch_event_rule.schedule_expression, null) != null ||
      try(var.aws_cloudwatch_event_rule.event_pattern, null) != null
    )
    error_message = "Either schedule_expression or event_pattern must be specified in aws_cloudwatch_event_rule."
  }
}

variable "aws_cloudwatch_event_target" {
  type = object({
    # (Optional) The event bus to associate with the rule. If omitted the default event bus is used.
    event_bus_name = optional(string)
    # (Optional) The unique target assignment ID. If missing a random unique id is generated.
    target_id = optional(string)
    # (Required) The Amazon Resource Name (ARN) of the target.
    arn = string
    # (Optional) Valid JSON text passed to the target. Conflicts with input_path and input_transformer.
    input = optional(string)
    # (Optional) JSONPath for extracting part of the matched event. Conflicts with input and input_transformer.
    input_path = optional(string)
    # (Optional) IAM role ARN for this target (required if ecs_target is used).
    role_arn = optional(string)
    # (Optional) Parameters for Amazon EC2 Run Command. Maximum 5 entries.
    run_command_targets = optional(list(any))
    # (Optional) Parameters for a single Amazon ECS Task target. Maximum 1 entry.
    ecs_target = optional(list(any))
    # (Optional) Parameters for an Amazon Batch Job target. Maximum 1 entry.
    batch_target = optional(list(any))
    # (Optional) Parameters for an Amazon Kinesis Stream target. Maximum 1 entry.
    kinesis_target = optional(list(any))
    # (Optional) Parameters for an Amazon SQS Queue target. Maximum 1 entry.
    sqs_target = optional(list(any))
    # (Optional) Input transformer parameters. Maximum 1 entry. Conflicts with input and input_path.
    input_transformer = optional(list(any))
    # (Optional) Retry policy parameters. Maximum 1 entry.
    retry_policy = optional(list(any))
    # (Optional) Dead letter config parameters. Maximum 1 entry.
    dead_letter_config = optional(list(any))
  })
  description = "(Required) EventBridge target definition (single target with optional nested configuration blocks)."
}

variable "tags" {
  type        = map(any)
  description = "tags - (Optional) A mapping of tags to assign to the resource."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
