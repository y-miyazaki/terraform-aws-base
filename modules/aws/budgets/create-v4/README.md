<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
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
| [aws_budgets_budget.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_budgets_budget"></a> [aws\_budgets\_budget](#input\_aws\_budgets\_budget) | (Required) AWS Budgets configuration object. Only 'name' and 'limit\_amount' are mandatory; all other attributes are optional. | <pre>object({<br/>    # (Required) The name of a budget. Unique within account.<br/>    name = string<br/>    # (Required) The amount of cost or usage being measured for the budget (AWS API expects string format).<br/>    limit_amount = string<br/><br/>    # (Optional) Budget type; defaults handled in main (COST | USAGE | RI_UTILIZATION | RI_COVERAGE | SAVINGS_PLANS_UTILIZATION | SAVINGS_PLANS_COVERAGE).<br/>    budget_type = optional(string)<br/>    # (Optional) Currency unit (e.g. USD); default handled in main.<br/>    limit_unit = optional(string)<br/>    # (Optional) Budget start time (YYYY-MM-DD_HH:MM); default handled in main.<br/>    time_period_start = optional(string)<br/>    # (Optional) Budget end time (YYYY-MM-DD_HH:MM); default handled in main.<br/>    time_period_end = optional(string)<br/>    # (Optional) Time unit (MONTHLY | QUARTERLY | ANNUALLY); default handled in main.<br/>    time_unit = optional(string)<br/><br/>    # (Optional) List of cost filters.<br/>    cost_filter = optional(list(object({<br/>      # (Required) Cost filter dimension name.<br/>      name = string<br/>      # (Required) List of values for the cost filter dimension.<br/>      values = list(string)<br/>    })))<br/><br/>    # (Optional) Cost types override list (normally one element).<br/>    cost_types = optional(list(object({<br/>      # (Optional) Include credit line items.<br/>      include_credit = optional(bool)<br/>      # (Optional) Include discounts.<br/>      include_discount = optional(bool)<br/>      # (Optional) Include other subscription costs.<br/>      include_other_subscription = optional(bool)<br/>      # (Optional) Include recurring costs.<br/>      include_recurring = optional(bool)<br/>      # (Optional) Include refunds.<br/>      include_refund = optional(bool)<br/>      # (Optional) Include subscription costs.<br/>      include_subscription = optional(bool)<br/>      # (Optional) Include support charges.<br/>      include_support = optional(bool)<br/>      # (Optional) Include taxes.<br/>      include_tax = optional(bool)<br/>      # (Optional) Include upfront charges.<br/>      include_upfront = optional(bool)<br/>      # (Optional) Use amortized costs instead of blended costs where applicable.<br/>      use_amortized = optional(bool)<br/>      # (Optional) Use blended costs.<br/>      use_blended = optional(bool)<br/>    })))<br/><br/>    # (Optional) Notification definitions list.<br/>    notification = optional(list(object({<br/>      # (Optional) Comparison operator (GREATER_THAN | LESS_THAN | EQUAL_TO).<br/>      comparison_operator = optional(string)<br/>      # (Optional) Numeric threshold; main defaults to 80.<br/>      threshold = optional(number)<br/>      # (Optional) Threshold type (PERCENTAGE | ABSOLUTE_VALUE).<br/>      threshold_type = optional(string)<br/>      # (Optional) Notification evaluation basis (ACTUAL | FORECASTED).<br/>      notification_type = optional(string)<br/>      # (Optional) Email subscriber list.<br/>      subscriber_email_addresses = optional(list(string))<br/>      # (Optional) SNS topic ARNs list.<br/>      subscriber_sns_topic_arns = optional(list(string))<br/>    })))<br/>  })</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Budgets. Defaults true. | `bool` | `true` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_budget_arn"></a> [budget\_arn](#output\_budget\_arn) | The ARN of the budget. |
| <a name="output_budget_name"></a> [budget\_name](#output\_budget\_name) | The name of the budget. |
<!-- END_TF_DOCS -->
