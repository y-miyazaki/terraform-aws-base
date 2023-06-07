<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Required) Provides an EventBridge Rule resource. | <pre>object(<br>    {<br>      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br>      name = string<br>      # (Optional) The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.<br>      schedule_expression = string<br>      # (Optional) The event pattern described a JSON object. At least one of schedule_expression or event_pattern is required. See full documentation of Events and Event Patterns in EventBridge for details.<br>      event_pattern = string<br>      # (Optional) The description of the rule.<br>      description = string<br>      # (Optional) The Amazon Resource Name (ARN) associated with the role that is used for target invocation.<br>      role_arn = string<br>      # (Optional) Whether the rule should be enabled (defaults to true).<br>      is_enabled = bool<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) Provides an EventBridge Target resource. | <pre>object(<br>    {<br>      # (Optional) The event bus to associate with the rule. If you omit this, the default event bus is used.<br>      event_bus_name = string<br>      # (Optional) The unique target assignment ID. If missing, will generate a random, unique id.<br>      target_id = string<br>      # (Required) The Amazon Resource Name (ARN) associated of the target.<br>      arn = string<br>      # (Optional) Valid JSON text passed to the target. Conflicts with input_path and input_transformer.<br>      input = string<br>      # (Optional) The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input_transformer.<br>      input_path = string<br>      # (Optional) The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered. Required if ecs_target is used.<br>      role_arn = string<br>      # (Optional) Parameters used when you are using the rule to invoke Amazon EC2 Run Command. Documented below. A maximum of 5 are allowed.<br>      run_command_targets = list(any)<br>      # (Optional) Parameters used when you are using the rule to invoke Amazon ECS Task. Documented below. A maximum of 1 are allowed.<br>      ecs_target = list(any)<br>      # (Optional) Parameters used when you are using the rule to invoke an Amazon Batch Job. Documented below. A maximum of 1 are allowed.<br>      batch_target = list(any)<br>      # (Optional) Parameters used when you are using the rule to invoke an Amazon Kinesis Stream. Documented below. A maximum of 1 are allowed.<br>      kinesis_target = list(any)<br>      # (Optional) Parameters used when you are using the rule to invoke an Amazon SQS Queue. Documented below. A maximum of 1 are allowed.<br>      sqs_target = list(any)<br>      # (Optional) Parameters used when you are providing a custom input to a target based on certain event data. Conflicts with input and input_path.<br>      input_transformer = list(any)<br>      # (Optional) Parameters used when you are providing retry policies. Documented below. A maximum of 1 are allowed.<br>      retry_policy = list(any)<br>      # (Optional) Parameters used when you are providing a dead letter conifg. Documented below. A maximum of 1 are allowed.<br>      dead_letter_config = list(any)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags - (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
| <a name="output_name"></a> [name](#output\_name) | The name of the rule |
<!-- END_TF_DOCS -->
