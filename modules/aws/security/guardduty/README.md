<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_invite_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_invite_accepter) | resource |
| [aws_guardduty_member.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_member) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_guardduty_detector"></a> [aws\_guardduty\_detector](#input\_aws\_guardduty\_detector) | (Required) The resource of aws\_guardduty\_detector. | <pre>object(<br>    {<br>      enable                       = bool<br>      finding_publishing_frequency = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_guardduty_member"></a> [aws\_guardduty\_member](#input\_aws\_guardduty\_member) | (Required) The resource of aws\_guardduty\_member. | <pre>list(object(<br>    {<br>      account_id                 = string<br>      email                      = string<br>      invite                     = bool<br>      invitation_message         = string<br>      disable_email_notification = bool<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of GuardDuty. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The AWS account ID of the GuardDuty detector |
| <a name="output_id"></a> [id](#output\_id) | The ID of the GuardDuty detector |
<!-- END_TF_DOCS -->
