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
| [aws_config_config_rule.cloudfront-accesslogs-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-associated-with-waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-custom-ssl-certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-default-root-object-configured](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-origin-access-identity-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-origin-failover-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-sni-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.cloudfront-viewer-policy-https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_remediation_configuration.cloudfront-viewer-policy-https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enable_cloudfront_viewer_policy_https"></a> [is\_enable\_cloudfront\_viewer\_policy\_https](#input\_is\_enable\_cloudfront\_viewer\_policy\_https) | (Optional) If true, it will change the viewer protocol policy to redirect-to-https. | `bool` | `false` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable AWS Config. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Prefix of config name. | `string` | `""` | no |
| <a name="input_ssm_automation_assume_role_arn"></a> [ssm\_automation\_assume\_role\_arn](#input\_ssm\_automation\_assume\_role\_arn) | (Required) AssumeRole arn in SSM Automation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
