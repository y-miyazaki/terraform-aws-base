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
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Optional) Provides an EventBridge Rule resource. | <pre>object(<br>    {<br>      # The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br>      name = string<br>      # The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.<br>      schedule_expression = string<br>      # The description of the rule.<br>      description = string<br>      # Whether the rule should be enabled (defaults to true).<br>      is_enabled = bool<br>    }<br>  )</pre> | <pre>{<br>  "description": "Trusted Advisor event rule.",<br>  "is_enabled": true,<br>  "name": "trusted-advisor-cloudwatch-event-rule",<br>  "role_arn": null,<br>  "schedule_expression": "cron(*/5 * * * ? *)"<br>}</pre> | no |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) Provides an EventBridge Target resource. | <pre>object(<br>    {<br>      # (Required) The Amazon Resource Name (ARN) associated of the target.<br>      arn = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Trusted Advisor. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
<!-- END_TF_DOCS -->
