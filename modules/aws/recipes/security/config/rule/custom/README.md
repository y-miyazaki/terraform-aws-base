<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_config_config_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_config_config_rule"></a> [aws\_config\_config\_rule](#input\_aws\_config\_config\_rule) | (Required) Provides an AWS Config Rule. | <pre>list(object(<br>    {<br>      # (Required) The name of the rule<br>      name = string<br>      # (Optional) Description of the rule<br>      description = string<br>      # (Optional) A string in JSON format that is passed to the AWS Config rule Lambda function.<br>      input_parameters = string<br>      # (Optional) The maximum frequency with which AWS Config runs evaluations for a rule.<br>      maximum_execution_frequency = string<br>      # (Optional) Scope defines which resources can trigger an evaluation for the rule as documented below.<br>      scope = any<br>      # (Required) Source specifies the rule owner, the rule identifier, and the notifications that cause the function to evaluate your AWS resources as documented below.<br>      source = any<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable AWS Config. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
