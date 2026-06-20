<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.22.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_securityhub_configuration_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy) | resource |
| [aws_securityhub_configuration_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_configuration_policy_association) | resource |
| [aws_securityhub_finding_aggregator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator) | resource |
| [aws_securityhub_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) | resource |
| [aws_securityhub_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_account_id"></a> [admin\_account\_id](#input\_admin\_account\_id) | (Optional) Account ID to designate as Security Hub organization admin. Defaults to caller account if is\_enabled\_admin. | `string` | `""` | no |
| <a name="input_configuration_policy"></a> [configuration\_policy](#input\_configuration\_policy) | (Optional) Configuration policy settings | <pre>object({<br/>    service_enabled       = bool<br/>    enabled_standard_arns = optional(list(string))<br/>    security_controls_configuration = optional(object({<br/>      disabled_control_identifiers = optional(list(string))<br/>    }))<br/>  })</pre> | <pre>{<br/>  "enabled_standard_arns": [],<br/>  "security_controls_configuration": {<br/>    "disabled_control_identifiers": []<br/>  },<br/>  "service_enabled": false<br/>}</pre> | no |
| <a name="input_configuration_policy_description"></a> [configuration\_policy\_description](#input\_configuration\_policy\_description) | (Optional) Configuration policy description | `string` | `"Central Security Hub CSPM policy for organizations"` | no |
| <a name="input_configuration_policy_name"></a> [configuration\_policy\_name](#input\_configuration\_policy\_name) | (Optional) Configuration policy name | `string` | `""` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable the Security Hub central configuration. Defaults true. | `bool` | `true` | no |
| <a name="input_is_enabled_admin"></a> [is\_enabled\_admin](#input\_is\_enabled\_admin) | (Optional) Enable Security Hub organization admin account designation. | `bool` | `false` | no |
| <a name="input_is_enabled_finding_aggregator"></a> [is\_enabled\_finding\_aggregator](#input\_is\_enabled\_finding\_aggregator) | (Optional) Enable Security Hub finding aggregator. | `bool` | `false` | no |
| <a name="input_linking_mode"></a> [linking\_mode](#input\_linking\_mode) | (Optional) The finding aggregator linking mode. Valid values are ALL\_REGIONS and SINGLE\_REGION. Default is ALL\_REGIONS. | `string` | `"ALL_REGIONS"` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | (Required) Target ID for the configuration policy association | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_admin_account_id"></a> [admin\_account\_id](#output\_admin\_account\_id) | Administrator account id associated if created |
| <a name="output_configuration_policy_id"></a> [configuration\_policy\_id](#output\_configuration\_policy\_id) | ID of created configuration policy (if created) |
| <a name="output_organization_configuration_id"></a> [organization\_configuration\_id](#output\_organization\_configuration\_id) | ID of Security Hub organization configuration resource (if created) |
<!-- END_TF_DOCS -->
