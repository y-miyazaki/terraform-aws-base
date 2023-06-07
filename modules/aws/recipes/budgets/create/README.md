<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.76.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_budgets_budget"></a> [aws\_budgets\_budget](#input\_aws\_budgets\_budget) | (Required) Provides a budgets budget resource. Budgets use the cost visualisation provided by Cost Explorer to show you the status of your budgets, to provide forecasts of your estimated costs, and to track your AWS usage, including your free tier usage. | <pre>object(<br>    {<br>      # The name of a budget. Unique within accounts.<br>      name = string<br>      # Whether this budget tracks monetary cost or usage.<br>      budget_type = string<br>      # Map of Cost Filters key/value pairs to apply to the budget.<br>      cost_filters = map(any)<br>      # The amount of cost or usage being measured for a budget.<br>      limit_amount = string<br>      # Object containing Budget Notifications. Can be used multiple times to define more than one budget notification<br>      notification = list(any)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Optional) Provides an EventBridge Rule resource. | <pre>object(<br>    {<br>      # The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br>      name = string<br>      # The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus.<br>      schedule_expression = string<br>      # The description of the rule.<br>      description = string<br>      # Whether the rule should be enabled (defaults to true).<br>      is_enabled = bool<br>    }<br>  )</pre> | <pre>{<br>  "description": "This cloudwatch event used for Budgets.",<br>  "is_enabled": true,<br>  "name": "budgets-cloudwatch-event-rule",<br>  "schedule_expression": "cron(0 9 * * ? *)"<br>}</pre> | no |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) Provides an EventBridge Target resource. | <pre>object(<br>    {<br>      # The Amazon Resource Name (ARN) associated of the target.<br>      arn = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Budgets. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
<!-- END_TF_DOCS -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
