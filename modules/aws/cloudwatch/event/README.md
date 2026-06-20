<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Required) EventBridge rule definition (must specify one of schedule\_expression or event\_pattern). | <pre>object({<br/>    # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br/>    name = string<br/>    # (Optional) The scheduling expression. e.g., cron(0 20 * * ? *) or rate(5 minutes). Either schedule_expression or event_pattern is required.<br/>    schedule_expression = optional(string)<br/>    # (Optional) JSON event pattern (string form). Either schedule_expression or event_pattern is required.<br/>    event_pattern = optional(string)<br/>    # (Optional) The description of the rule.<br/>    description = optional(string)<br/>    # (Optional) Role ARN used for target invocation. Needed for certain target types such as ECS or Batch.<br/>    role_arn = optional(string)<br/>    # (Optional) Rule state (ENABLED or DISABLED). Defaults to ENABLED when omitted.<br/>    state = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) EventBridge target definition (single target with optional nested configuration blocks). | <pre>object({<br/>    # (Optional) The event bus to associate with the rule. If omitted the default event bus is used.<br/>    event_bus_name = optional(string)<br/>    # (Optional) The unique target assignment ID. If missing a random unique id is generated.<br/>    target_id = optional(string)<br/>    # (Required) The Amazon Resource Name (ARN) of the target.<br/>    arn = string<br/>    # (Optional) Valid JSON text passed to the target. Conflicts with input_path and input_transformer.<br/>    input = optional(string)<br/>    # (Optional) JSONPath for extracting part of the matched event. Conflicts with input and input_transformer.<br/>    input_path = optional(string)<br/>    # (Optional) IAM role ARN for this target (required if ecs_target is used).<br/>    role_arn = optional(string)<br/>    # (Optional) Parameters for Amazon EC2 Run Command. Maximum 5 entries.<br/>    run_command_targets = optional(list(any))<br/>    # (Optional) Parameters for a single Amazon ECS Task target. Maximum 1 entry.<br/>    ecs_target = optional(list(any))<br/>    # (Optional) Parameters for an Amazon Batch Job target. Maximum 1 entry.<br/>    batch_target = optional(list(any))<br/>    # (Optional) Parameters for an Amazon Kinesis Stream target. Maximum 1 entry.<br/>    kinesis_target = optional(list(any))<br/>    # (Optional) Parameters for an Amazon SQS Queue target. Maximum 1 entry.<br/>    sqs_target = optional(list(any))<br/>    # (Optional) Input transformer parameters. Maximum 1 entry. Conflicts with input and input_path.<br/>    input_transformer = optional(list(any))<br/>    # (Optional) Retry policy parameters. Maximum 1 entry.<br/>    retry_policy = optional(list(any))<br/>    # (Optional) Dead letter config parameters. Maximum 1 entry.<br/>    dead_letter_config = optional(list(any))<br/>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags - (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
| <a name="output_name"></a> [name](#output\_name) | The name of the rule |
<!-- END_TF_DOCS -->
