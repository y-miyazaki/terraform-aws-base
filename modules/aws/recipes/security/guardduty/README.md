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
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_invite_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_invite_accepter) | resource |
| [aws_guardduty_member.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_member) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Optional) Provides an EventBridge Rule resource. | <pre>object(<br>    {<br>      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br>      name = string<br>      # (Optional) The description of the rule.<br>      description = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "This cloudwatch event used for GuardDuty.",<br>  "is_enabled": true,<br>  "name": "security-guarduty-cloudwatch-event-rule",<br>  "role_arn": null<br>}</pre> | no |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) Provides an EventBridge Target resource. | <pre>object(<br>    {<br>      # (Required) The Amazon Resource Name (ARN) associated of the target.<br>      arn = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_guardduty_detector"></a> [aws\_guardduty\_detector](#input\_aws\_guardduty\_detector) | (Required) The resource of aws\_guardduty\_detector. | <pre>object(<br>    {<br>      enable                       = bool<br>      finding_publishing_frequency = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_guardduty_member"></a> [aws\_guardduty\_member](#input\_aws\_guardduty\_member) | (Required) The resource of aws\_guardduty\_member. | <pre>list(object(<br>    {<br>      account_id                 = string<br>      email                      = string<br>      invite                     = bool<br>      invitation_message         = string<br>      disable_email_notification = bool<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID of the GuardDuty detector |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
| <a name="output_id"></a> [id](#output\_id) | The ID of the GuardDuty detector |
<!-- END_TF_DOCS -->
