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
| [aws_config_config_rule.ebs-optimized-instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.ec2-instance-detailed-monitoring-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.ec2-instance-profile-attached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.ec2-instances-in-vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.ec2-volume-inuse-check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.restricted-common-ports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.restricted-ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_remediation_configuration.restricted-ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_disable_public_access_for_security_group"></a> [is\_disable\_public\_access\_for\_security\_group](#input\_is\_disable\_public\_access\_for\_security\_group) | (Optional) If true, it will disable the default SSH and RDP ports that are open for all IP addresses. | `bool` | `false` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable AWS Config. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Prefix of config name. | `string` | `""` | no |
| <a name="input_restricted_common_ports"></a> [restricted\_common\_ports](#input\_restricted\_common\_ports) | n/a | <pre>object(<br>    {<br>      input_parameters = map(any)<br>    }<br>  )</pre> | <pre>{<br>  "input_parameters": {<br>    "blockedPort1": "20",<br>    "blockedPort2": "21",<br>    "blockedPort3": "3389",<br>    "blockedPort4": "3306",<br>    "blockedPort5": "4333"<br>  }<br>}</pre> | no |
| <a name="input_ssm_automation_assume_role_arn"></a> [ssm\_automation\_assume\_role\_arn](#input\_ssm\_automation\_assume\_role\_arn) | (Required) AssumeRole arn in SSM Automation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
